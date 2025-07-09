-- skills/SPivotKickFSM.lua
local api        = require("sysmickit.lua_api")
local utils      = require("sysmickit.utils")
local SMove      = require("skills.SMove")
local SMoveDirect= require("skills.SMoveDirect")
local SKick      = require("skills.SKick")
local Vector2D   = require("sysmickit.vector2D")

local M = {}

local PIVOT_DIST = 0.13
local PIVOT_THRESHOLD = 0.07
local BALL_CAPTURE_DIST = 0.06
local ALIGN_THRESHOLD = 0.1
local ROTATE_ONLY_THRESHOLD = 0.25  -- Si el error angular es mayor, solo rota

-- Calcula el punto de pivote alineado con el target
local function get_pivot_point(ball, target)
    local ball_pos = Vector2D.new(ball.x, ball.y)
    local target_pos = Vector2D.new(target.x, target.y)
    local direction = (ball_pos - target_pos):normalized()
    local pivot = ball_pos + direction * PIVOT_DIST
    return { x = pivot.x, y = pivot.y }
end

local function get_alignment_error(robot, ball, target)
    local to_ball = math.atan(ball.y - robot.y, ball.x - robot.x)
    local to_target = math.atan(target.y - ball.y, target.x - ball.y)
    return utils.angle_diff(to_ball, to_target)
end

function M.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    local ball  = api.get_ball_state()
    if not robot or not ball or not target then return false end

    -- 1. Calcular punto de pivote alineado con target
    local pivot = get_pivot_point(ball, target)
    local dist_to_pivot = utils.distance(robot, pivot)
    local dist_to_ball = utils.distance(robot, ball)
    local align_error = math.abs(get_alignment_error(robot, ball, target))

    -- 1. Si no está bien posicionado detrás de la pelota, moverse al pivote (avanza aunque no esté perfectamente alineado)
    if dist_to_pivot > PIVOT_THRESHOLD then
        -- Solo gira en el lugar si está extremadamente desalineado (>1 rad)
        if align_error > 1.0 then
            api.face_to(robotId, team, ball)
        end
        -- Siempre avanza al pivote
        SMove.process(robotId, team, pivot)
        return false
    end

    -- 2. Si está bien posicionado y alineado, acercarse directo a la pelota para capturar
    if dist_to_ball > BALL_CAPTURE_DIST then
        if align_error < ROTATE_ONLY_THRESHOLD then
            SMoveDirect.process(robotId, team, ball)
            api.dribbler(robotId, team, 10)
        else
            api.face_to(robotId, team, ball)
        end
        return false
    end

    -- 3. Si tiene la pelota, verificar alineación y disparar si corresponde
    if utils.has_captured_ball(robot, ball) then
        api.dribbler(robotId, team, 10)
        if align_error < ALIGN_THRESHOLD then
            SKick.process(robotId, team)
            return true
        else
            api.face_to(robotId, team, target)
            return false
        end
    end

    -- 4. Si está muy cerca pero aún no la capturó, seguir con dribbler y corregir orientación
    api.dribbler(robotId, team, 10)
    if align_error > ALIGN_THRESHOLD then
        api.face_to(robotId, team, target)
    end
    return false
end

return M

