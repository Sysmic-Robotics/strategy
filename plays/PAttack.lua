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

-- Goal position para equipo azul (team = 0)
local GOAL_POS = { x = 4.5, y = 0 }

function PAttack.new()
    return setmetatable({
        state = "prepare",
        role_ids = {},
        _last_ball_pos = nil,
        _last_ball_speed = 0,
        pass_tactic = nil,
        kick_tactic = nil,
    }, PAttack)
end

function PAttack:assign_roles(roles)
    self.role_ids = roles
end

function PAttack:is_done(game_state)
    return self.state == "done"
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
        if utils.has_captured_ball(kicker, ball) then
            print("[PAttack] Pelota capturada → ataque")
            self.state = "attack"
            return
        end
        local dist = utils.distance(kicker, ball)
        if dist < 0.9 then
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

    -- Estado 2: Ataque
    if self.state == "attack" then
        if not utils.has_captured_ball(kicker, ball) then
            print("[PAttack] Perdí la pelota, termino play.")
            self.state = "done"
            return
        end

        -- Revisar si puedo disparar directo
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3 -- Ajusta según tamaño robot
        if utils.is_path_clear(ball, GOAL_POS, obstacles, clearance) then
            print("[PAttack] Camino libre, intento gol")
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new()
            end
            if self.kick_tactic:process(kicker_id, team) then
                print("[PAttack] Disparo realizado, termino play.")
                self.state = "done"
            end
            return
        else
            print("[PAttack] Camino bloqueado, ejecuto pase a R" .. support_id)
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