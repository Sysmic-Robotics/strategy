local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local kick = require("skills.kick_to_point")
local capture = require("skills.SCaptureBall")
local Vector2D = require("sysmickit.vector2D")

local PAttack = {}
PAttack.__index = PAttack

local GOAL_POS = { x = 4.5, y = 0 }

-- Función auxiliar local para saber quién tiene la pelota
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

-- Función para detectar si el camino al arco está libre
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

    if utils.team_has_ball(team) then
        return false -- seguimos la play porque tenemos la pelota
    end

    -- Si no tenemos la pelota, veamos si el striker puede recuperarla
    local striker_id = self.roles.striker
    local robot = api.get_robot_state(striker_id, team)
    local ball = api.get_ball_state()

    if not robot or not ball then
        return true -- no podemos hacer nada sin info, terminamos la play
    end

    local dx = robot.x - ball.x
    local dy = robot.y - ball.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 0.5 then
        return false -- el striker está cerca, que intente capturar
    end

    return true -- pelota muy lejos
end

function PAttack:process(game_state)
    local team = game_state.team
    local ball = api.get_ball_state()
    local opponents = api.get_opponents(team)

    if not ball or not opponents then
        print("[PAttack] Error: faltan datos de percepción.")
        return
    end

    -- Actualizar rol si otro aliado capturó la pelota
    local possessor_id = who_has_ball(team)
    if possessor_id and possessor_id ~= self.last_striker_id then
        print("[PAttack] Nuevo atacante detectado: R" .. possessor_id)
        self.roles.striker = possessor_id
        self.last_striker_id = possessor_id
        self.phase = "capture"
    end

    local striker_id = self.roles.striker
    if not striker_id then
        print("[PAttack] Sin atacante asignado.")
        return
    end

    local striker = api.get_robot_state(striker_id, team)
    if not striker then
        print("[PAttack] Error: striker no está disponible.")
        return
    end

    local distance_to_ball = math.sqrt((striker.x - ball.x)^2 + (striker.y - ball.y)^2)

    -- FASE: captura
    if self.phase == "capture" then
        if utils.has_captured_ball(striker, ball) then
            if is_path_clear(ball, GOAL_POS, opponents) then
                print("[PAttack] Captura + camino libre → fase kick")
                self.phase = "kick"
            else
                print("[PAttack] Captura pero camino bloqueado.")
            end
        else
            print("[PAttack] Capturando pelota...")
            capture.process(striker_id, team)
        end
        return
    end

    -- FASE: disparo
    if self.phase == "kick" then
        print("[PAttack] Fase kick activa...")
        local robot = api.get_robot_state(striker_id, team)

        if utils.is_ready_to_kick(robot, ball, GOAL_POS) then
            print("[PAttack] Robot listo para disparar. Ejecutando kick...")
            local success = kick.process(striker_id, team, GOAL_POS)
            if success then
                print("[PAttack] Disparo ejecutado → fase espera")
                self.phase = "wait_for_reacquire"
            else
                print("[PAttack] Kick aún en proceso, esperando confirmación...")
            end
        else
            print("[PAttack] Reajustando orientación y posición antes de disparar...")
            aim.run_once(striker_id, team, { target = GOAL_POS })  -- ← ❌ esta línea causa el error
            return
        end

        return
    end



    -- FASE: espera de re-captura
    if self.phase == "wait_for_reacquire" then
        if distance_to_ball > 0.5 then
            print("[PAttack] Pelota fuera de alcance → esperando recuperación...")
        else
            print("[PAttack] Aún cerca de la pelota, sin cambios.")
        end
        return
    end
end

return PAttack
