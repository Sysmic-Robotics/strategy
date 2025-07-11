local TCoordinatePass = require("tactics.TCoordinatedPass")
local TKickToGoal     = require("tactics.TKickToGoal")
local api             = require("sysmickit.lua_api")
local utils           = require("sysmickit.utils")
local capture         = require("skills.SCaptureBall")
local Play            = {}
Play.__index          = Play

local GOAL_POS = { x = 4.5, y = 0 }

local PASS_REGION = {
    x_min = -6.0,
    x_max = 6.0,
    y_min = -4.5,
    y_max = 4.5
}

function Play.new()
    return setmetatable({
        name        = "PAttack",
        role_ids    = {},
        state       = "init",
        successful  = false,
    }, Play)
end

function Play:is_applicable(game_state)
    return game_state.in_offense and not game_state.aborted
end

function Play:is_done(game_state)
    return not game_state.in_offense or game_state.aborted or self.successful
end

function Play:assign_roles(roles)
    self.role_ids = roles
end

function Play:process(game_state)
    local team = game_state.team or 0
    local id0 = self.role_ids[0]
    local id1 = self.role_ids[1]
    if not id0 or not id1 then return end

    if self.state == "init" then
        self.pass_tactic  = TCoordinatePass.new()
        self.shoot_tactic = TKickToGoal.new()
        self.state = "attack"
    end

    local attacker = api.get_robot_state(id0, team)
    local ball = api.get_ball_state()
    if not attacker or not ball then return end

    -- Captura lógica: solo si está muy cerca de la pelota
    local dist_to_ball = utils.distance(attacker, ball)
    local capture_threshold = 0.12 -- más pequeño para evitar que el kicker persiga la pelota tras patear
    if dist_to_ball < capture_threshold and not utils.has_captured_ball(attacker, ball) then
        print("[PAttack] Aún no se captura la pelota → ejecutando SCaptureBall")
        capture.process(id0, team)
        return
    end

    -- Disparo directo si posible
    if utils.has_captured_ball(attacker, ball) and utils.is_ready_to_kick(attacker, ball, GOAL_POS) then
        local from = {x = ball.x, y = ball.y}
        local to = {x = GOAL_POS.x, y = GOAL_POS.y}
        local clearance = 0.2 -- typical robot radius clearance
        if utils.is_path_clear(from, to, api.get_opponents(team), clearance) then
            print("[PAttack] Disparando directo al arco")
            local success = self.shoot_tactic:process(id0, team, GOAL_POS)
            if success then
                self.successful = true
            end
            return
        end
    end

    -- Pase coordinado si no puede disparar
    print("[PAttack] Camino bloqueado → ejecutando pase a R" .. id1)
    local pass_done = self.pass_tactic:process(id0, id1, team, PASS_REGION)
    if pass_done then
        print("[PAttack] Pase completado → cambiando roles y repitiendo ciclo")
        self.role_ids[0], self.role_ids[1] = self.role_ids[1], self.role_ids[0]
        self.pass_tactic  = TCoordinatePass.new()
        self.shoot_tactic = TKickToGoal.new()
        -- El ciclo se repite hasta que se logre el disparo
    end
end


return Play
