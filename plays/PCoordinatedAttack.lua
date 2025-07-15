local Engine          = require("sysmickit.engine")
local utils           = require("sysmickit.utils")
local SCaptureBall    = require("skills.SCaptureBall")
local TKickToGoal     = require("tactics.TKickToGoal")
local TCoordinatedPass= require("tactics.TCoordinatedPass")

local PCoordinatedAttack = {}
PCoordinatedAttack.__index = PCoordinatedAttack

local PASS_REGION = {
    x_min = -4.5,
    x_max = 6.0,
    y_min = -3.0,
    y_max = 3.0
}

local GOAL_POS = { x = 4.5, y = 0 }
local MAX_SHOT_DISTANCE = 2.7   -- metros desde el arco
local ATTACK_TIMEOUT_FRAMES = 240  -- 4 segundos si el loop corre a 60 Hz
local SUPPORT_READY_DIST = 0.25    -- cuán cerca debe estar el support a su destino para recibir el pase
local ADVANCE_OFFSET = 0.8
local FORMATION_WIDTH = 2.5

function PCoordinatedAttack.new()
    return setmetatable({
        state = "prepare",
        role_ids = {},
        pass_tactic = nil,
        kick_tactic = nil,
        attack_start_frame = nil,
        _chosen_support = nil,
        _support_positions = {},
    }, PCoordinatedAttack)
end

function PCoordinatedAttack:assign_roles(roles)
    self.role_ids = roles
end

function PCoordinatedAttack:is_done(game_state)
    return self.state == "done"
end

local global_frame = 0
function frame_count()
    global_frame = global_frame + 1
    return global_frame
end

-- Calcula posiciones ideales para los supports y los mueve hacia allá (abanico adelante del kicker)
local function set_support_positions(kicker, support_ids, team)
    local positions = {}
    local num_supports = #support_ids
    for i=1, num_supports do
        local frac = (num_supports > 1) and (i-1)/(num_supports-1) or 0.5
        local y_pos = kicker.y - FORMATION_WIDTH/2 + frac * FORMATION_WIDTH
        local x_pos = kicker.x + ADVANCE_OFFSET
        if team == 1 then x_pos = kicker.x - ADVANCE_OFFSET end
        positions[i] = {x = x_pos, y = y_pos}
    end
    for i, id in ipairs(support_ids) do
        local robot = Engine.get_robot_state(id, team)
        if robot then
            require("skills.SMove").process(id, team, positions[i])
        end
    end
    return positions
end

function PCoordinatedAttack:process(game_state)
    local team = game_state.team or 0
    local kicker_id = self.role_ids[0]
    local support_ids = {}
    for i = 1, 4 do
        if self.role_ids[i] ~= kicker_id then
            table.insert(support_ids, self.role_ids[i])
        end
    end

    if not kicker_id or #support_ids == 0 then
        print("[PCoordinatedAttack] Roles no definidos correctamente.")
        self.state = "done"
        return
    end

    local kicker = Engine.get_robot_state(kicker_id, team)
    local ball = Engine.get_ball_state()
    if not kicker or not ball then
        print("[PCoordinatedAttack] Estado inválido de robots o pelota.")
        self.state = "done"
        return
    end

    -- Estado 1: Preparar/capturar pelota (idéntico al PAttack clásico)
    if self.state == "prepare" then
        self.attack_start_frame = nil
        self._chosen_support = nil
        self._support_positions = {}
        if utils.has_captured_ball(kicker, ball) then
            print("[PCoordinatedAttack] Pelota capturada → ataque")
            self.state = "attack"
            return
        end
        local dist = utils.distance(kicker, ball)
        if dist < 0.8 then
            if SCaptureBall.process(kicker_id, team) then
                print("[PCoordinatedAttack] Capturé la pelota → ataque")
                self.state = "attack"
            end
            return
        else
            print("[PCoordinatedAttack] Lejos de la pelota, termino play.")
            self.state = "done"
            return
        end
    end

    -- Estado 2: Ataque (idéntico a la lógica dos robots, pero con supports)
    if self.state == "attack" then
        if not self.attack_start_frame then
            self.attack_start_frame = frame_count()
        end

        local current_frame = frame_count()
        if current_frame - self.attack_start_frame > ATTACK_TIMEOUT_FRAMES then
            print("[PCoordinatedAttack] ¡Timeout de ataque! Reiniciando play por seguridad.")
            self.state = "done"
            return
        end

        if not utils.has_captured_ball(kicker, ball) then
            print("[PCoordinatedAttack] Perdí la pelota, termino play.")
            self.state = "done"
            return
        end

        -- 1. INTENTA SIEMPRE EL DISPARO PRIMERO (tal como PAttack original)
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3
        local shot_distance = utils.distance(ball, GOAL_POS)
        if utils.is_path_clear(ball, GOAL_POS, obstacles, clearance)
           and shot_distance <= MAX_SHOT_DISTANCE then
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new()
            end
            if self.kick_tactic:process(kicker_id, team) then
                print("[PCoordinatedAttack] Disparo realizado, termino play.")
                self.state = "done"
            end
            return
        end

        -- 2. TODOS LOS SUPPORTS AVANZAN INMEDIATO AL ENTRAR EN ATTACK
        self._support_positions = set_support_positions(kicker, support_ids, team)

        -- 3. Elige un support random SOLO UNA VEZ por play
        if not self._chosen_support then
            self._chosen_support = support_ids[math.random(1, #support_ids)]
        end

        -- 4. Espera que el support elegido esté "cerca" de su posición antes de ejecutar el pase
        local idx = nil
        for i, id in ipairs(support_ids) do
            if id == self._chosen_support then idx = i end
        end
        if idx then
            local support_robot = Engine.get_robot_state(self._chosen_support, team)
            local target_pos = self._support_positions[idx]
            if not support_robot or not target_pos or utils.distance(support_robot, target_pos) > SUPPORT_READY_DIST then
                -- Sigue avanzando hasta que el receptor esté listo
                return
            end
        end

        -- 5. Ejecuta el pase exactamente igual que en PAttack original
        if not self.pass_tactic then
            self.pass_tactic = TCoordinatedPass.new(kicker_id, self._chosen_support, team, PASS_REGION)
        end
        if self.pass_tactic:process() then
            print(string.format("[PCoordinatedAttack] Pase realizado de %d a %d, termino play.", kicker_id, self._chosen_support))
            self.state = "done"
        end
        return
    end
end

return PCoordinatedAttack
