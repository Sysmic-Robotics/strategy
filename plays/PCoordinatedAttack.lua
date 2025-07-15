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
local ATTACK_TIMEOUT_FRAMES = 240  -- 4 segundos a 60Hz

function PCoordinatedAttack.new()
    return setmetatable({
        state = "prepare",
        role_ids = {},
        pass_tactic = nil,
        kick_tactic = nil,
        attack_start_frame = nil,
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

function PCoordinatedAttack:process(game_state)
    local team = game_state.team or 0
    local kicker_id = self.role_ids[0]
    local support_ids = {}
    -- Todos los demás roles (IDs 1–4): supporters
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

    -- Estado 1: Preparar/capturar pelota
    if self.state == "prepare" then
        self.attack_start_frame = nil -- Reinicia timeout
        if utils.has_captured_ball(kicker, ball) then
            print("[PCoordinatedAttack] Pelota capturada → ataque")
            self.state = "attack"
            return
        end
        local dist = utils.distance(kicker, ball)
        if dist < 0.8 then -- Ajusta el rango de captura según tu robot
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

    -- Estado 2: Ataque (con timeout)
    if self.state == "attack" then
        if not self.attack_start_frame then
            self.attack_start_frame = frame_count()
        end

        local current_frame = frame_count()
        if current_frame - self.attack_start_frame > ATTACK_TIMEOUT_FRAMES then
            print("[PCoordinatedAttack] Timeout ataque! Reiniciando play.")
            self.state = "done"
            return
        end

        if not utils.has_captured_ball(kicker, ball) then
            print("[PCoordinatedAttack] Perdí la pelota, termino play.")
            self.state = "done"
            return
        end

        -- 1. Disparo directo
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

        -- 2. Pase coordinado: elige un support random (puedes usar math.random)
        local support_id = support_ids[math.random(1, #support_ids)]
        if not self.pass_tactic then
            self.pass_tactic = TCoordinatedPass.new(kicker_id, support_id, team, PASS_REGION)
        end
        if self.pass_tactic:process() then
            print(string.format("[PCoordinatedAttack] Pase realizado de %d a %d, termino play.", kicker_id, support_id))
            self.state = "done"
        end
        return
    end
end

return PCoordinatedAttack
