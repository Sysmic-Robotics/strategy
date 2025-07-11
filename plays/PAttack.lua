local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local kick = require("skills.kick_to_point")
local capture = require("skills.SCaptureBall")
local move = require("skills.SMove")
local coordinated_pass = require("tactics.TCoordinatedPass")
local Vector2D = require("sysmickit.vector2D")

local PAttack = {}
PAttack.__index = PAttack

local GOAL_POS = { x = 4.5, y = 0 }

local function who_has_ball(team)
    local allies = api.get_allies(team)
    local ball = api.get_ball_state()
    if not ball then return nil end
    for _, robot in ipairs(allies) do
        if utils.has_captured_ball(robot, ball) then
            return robot.id
        end
    end
    return nil
end

local function is_path_clear(from_pos, to_pos, opponents)
    local EPSILON = 0.2
    local a = Vector2D.new(from_pos.x, from_pos.y)
    local b = Vector2D.new(to_pos.x, to_pos.y)
    local ab = b - a
    for _, opp in ipairs(opponents) do
        local p = Vector2D.new(opp.x, opp.y)
        local ap = p - a
        local t = math.max(0, math.min(1, ap:dot(ab) / ab:length_squared()))
        local closest = a + ab * t
        if (closest - p):length() < EPSILON then
            return false
        end
    end
    return true
end

function PAttack.new()
    return setmetatable({
        name = "PAttack",
        roles = {},
        phase = "capture",
        last_striker_id = nil
    }, PAttack)
end

function PAttack:assign_roles(role_ids)
    self.roles = role_ids or {}
    self.last_striker_id = role_ids.striker
end

function PAttack:is_applicable(game_state)
    return game_state.in_offense and not game_state.aborted
end

function PAttack:is_done(game_state)
    local team = game_state.team or 0
    if utils.team_has_ball(team) then return false end

    local striker_id = self.roles.striker
    local robot = api.get_robot_state(striker_id, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return true end

    local dx = robot.x - ball.x
    local dy = robot.y - ball.y
    return math.sqrt(dx * dx + dy * dy) > 0.5
end

function PAttack:process(game_state)
    local team = game_state.team
    local ball = api.get_ball_state()
    local opponents = api.get_opponents(team)
    if not ball or not opponents then return end

    local possessor_id = who_has_ball(team)
    if possessor_id and possessor_id ~= self.last_striker_id then
        self.roles.striker = possessor_id
        self.last_striker_id = possessor_id
        self.phase = "capture"
        print("[PAttack] Nuevo atacante detectado: R" .. possessor_id)
    end

    local striker_id = self.roles.striker
    if not striker_id then return end
    local striker = api.get_robot_state(striker_id, team)
    if not striker then return end

    local distance_to_ball = math.sqrt((striker.x - ball.x)^2 + (striker.y - ball.y)^2)

    -- CAPTURE
    if self.phase == "capture" then
        if utils.has_captured_ball(striker, ball) then
            if is_path_clear(ball, GOAL_POS, opponents) then
                self.phase = "kick"
                print("[PAttack] Captura + camino libre → fase kick")
            else
                self.phase = "pass"
                print("[PAttack] Captura pero camino bloqueado → fase pase")
            end
        else
            print("[PAttack] Capturando pelota...")
            capture.process(striker_id, team)
        end
        return
    end

    -- KICK
    if self.phase == "kick" then
        print("[PAttack] Fase kick activa...")
        if utils.is_ready_to_kick(striker, ball, GOAL_POS) then
            if kick.process(striker_id, team, GOAL_POS) then
                print("[PAttack] Disparo ejecutado → fase espera")
                self.phase = "wait_for_reacquire"
            end
        else
            print("[PAttack] Reajustando antes de disparar...")
            move.process(striker_id, team, GOAL_POS)
        end
        return
    end

    -- PASS
    if self.phase == "pass" then
        local support1_id = self.roles.support1
        local support2_id = self.roles.support2
        local support1 = api.get_robot_state(support1_id, team)
        local support2 = api.get_robot_state(support2_id, team)

        if not support1 or not support2 then
            print("[PAttack] Robots de soporte no encontrados.")
            return
        end

        local striker_pos = Vector2D.new(striker.x, striker.y)
        local s1_pos = Vector2D.new(support1.x, support1.y)
        local s2_pos = Vector2D.new(support2.x, support2.y)

        local d1 = (s1_pos - striker_pos):length()
        local d2 = (s2_pos - striker_pos):length()

        local receiver_id, advance_id
        if d1 < d2 then
            receiver_id = support1_id
            advance_id = support2_id
        else
            receiver_id = support2_id
            advance_id = support1_id
        end

        print("[PAttack] Ejecutando pase a R" .. receiver_id .. ", R" .. advance_id .. " se adelanta.")
        -- solo para test
        move.process(receiver_id, team, {x = striker.x + 0.5, y = striker.y})

        self.pass_tactic = self.pass_tactic or coordinated_pass.new()
        local region = { x_min = -6, x_max = 6, y_min = -4.5, y_max = 4.5 }
        self.pass_tactic:process(striker_id, receiver_id, team, region)

        -- 🚨 Aquí está la línea corregida:
        local target_pos = { x = GOAL_POS.x - 1.0, y = 1.5 }
        move.process(advance_id, team, target_pos)

        return
    end

    -- WAIT
    if self.phase == "wait_for_reacquire" then
        if distance_to_ball > 0.5 then
            print("[PAttack] Esperando nueva captura...")
        end
        return
    end
end

return PAttack


