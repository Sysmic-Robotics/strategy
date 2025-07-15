local Engine          = require("sysmickit.engine")
local utils           = require("sysmickit.utils")
local SCaptureBall    = require("skills.SCaptureBall")
local TKickToGoal     = require("tactics.TKickToGoal")
local TCoordinatedPass= require("tactics.TCoordinatedPass")

local PAttack = {}
PAttack.__index = PAttack

-- Puedes ajustar la región de pase a lo que quieras
local PASS_REGION = {
    x_min = -4.5,
    x_max = 6.0,
    y_min = -3.0,
    y_max = 3.0
}

local GOAL_POS = { x = 4.5, y = 0 }
local MAX_SHOT_DISTANCE = 2.7   -- metros desde el arco

local ATTACK_TIMEOUT_FRAMES = 240  -- 4 segundos si el loop corre a 60 Hz

function PAttack.new()
    return setmetatable({
        state = "prepare",
        role_ids = {},
        _last_ball_pos = nil,
        _last_ball_speed = 0,
        pass_tactic = nil,
        kick_tactic = nil,
        attack_start_frame = nil,  -- Nuevo: contador de frames en estado "attack"
    }, PAttack)
end

function PAttack:assign_roles(roles)
    self.role_ids = roles
end

function PAttack:is_done(game_state)
    return self.state == "done"
end

-- Asume que tienes una función global frame_count() que retorna el ciclo actual (puedes cambiarlo por os.clock() si quieres en segundos)
local global_frame = 0
function frame_count()
    global_frame = global_frame + 1
    return global_frame
end

function PAttack:process(game_state)
    local team = game_state.team or 0
    local kicker_id = self.role_ids[0]
    local support_id = self.role_ids[1]

    if not kicker_id or not support_id then
        print("[PAttack] Roles no definidos.")
        self.state = "done"
        return
    end

    local kicker = Engine.get_robot_state(kicker_id, team)
    local support = Engine.get_robot_state(support_id, team)
    local ball = Engine.get_ball_state()
    if not kicker or not support or not ball then
        print("[PAttack] Estados inválidos de robots o pelota.")
        self.state = "done"
        return
    end

    -- Estado 1: Preparar/capturar pelota
    if self.state == "prepare" then
        self.attack_start_frame = nil -- Reinicia el timeout
        if utils.has_captured_ball(kicker, ball) then
            print("[PAttack] Pelota capturada → ataque")
            self.state = "attack"
            return
        end
        local dist = utils.distance(kicker, ball)
        if dist < 3.8 then -- Ajusta el rango de captura según tu robot
            if SCaptureBall.process(kicker_id, team) then
                print("[PAttack] Capturé la pelota → ataque")
                self.state = "attack"
            end
            return
        else
            print("[PAttack] Lejos de la pelota, termino play.")
            self.state = "done"
            return
        end
    end

    -- Estado 2: Ataque (con timeout)
    if self.state == "attack" then
        -- Iniciar el contador solo la primera vez que entra a este estado
        if not self.attack_start_frame then
            self.attack_start_frame = frame_count()
        end

        -- Si se pasa del timeout, terminar la play
        local current_frame = frame_count()
        if current_frame - self.attack_start_frame > ATTACK_TIMEOUT_FRAMES then
            print("[PAttack] ¡Timeout de ataque! Reiniciando play por seguridad.")
            self.state = "done"
            return
        end

        if not utils.has_captured_ball(kicker, ball) then
            print("[PAttack] Perdí la pelota, termino play.")
            self.state = "done"
            return
        end

        -- Revisar si puedo disparar directo
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3 -- Ajusta según tamaño robot
        local shot_distance = utils.distance(ball, GOAL_POS)
        if utils.is_path_clear(ball, GOAL_POS, obstacles, clearance)
           and shot_distance <= MAX_SHOT_DISTANCE then
            print(string.format("[PAttack] Camino libre y a %.2f m del arco, intento gol", shot_distance))
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new()
            end
            if self.kick_tactic:process(kicker_id, team) then
                print("[PAttack] Disparo realizado, termino play.")
                self.state = "done"
            end
            return
        else
            print(string.format("[PAttack] Camino bloqueado o lejos (%.2f m), ejecuto pase a R%d", shot_distance, support_id))
            if not self.pass_tactic then
                self.pass_tactic = TCoordinatedPass.new(kicker_id, support_id, team, PASS_REGION)
            end
            if self.pass_tactic:process() then
                print("[PAttack] Pase realizado, termino play.")
                self.state = "done"
            end
            return
        end
    end
end

return PAttack
