local api = require("sysmickit.lua_api")
local Vector2D = require("sysmickit.vector2D")
local SMove = require("skills.SMove")

local M = {}

-- Parámetros configurables
local RADIUS = 0.15   -- Radio de giro en metros
local ANGULAR_SPEED = 0.012 -- Velocidad angular (radianes por frame)

-- Estado por robot
local states = {}

function M.process(robotId, team, direction)
    local ball = api.get_ball_state()
    if not ball then return false end

    local key = robotId .. ":" .. team
    if not states[key] then
        states[key] = {
            angle = 0  -- Ángulo inicial en la circunferencia
        }
    end

    local state = states[key]
    state.angle = state.angle + ANGULAR_SPEED
    if state.angle > 2 * math.pi then
        state.angle = state.angle - 2 * math.pi
    end

    -- Calcular posición objetivo sobre la circunferencia
    local x = ball.x + RADIUS * math.cos(state.angle)*direction
    local y = ball.y + RADIUS * math.sin(state.angle)
    local target = { x = x, y = y }

    -- Mover hacia el punto
    SMove.process(robotId, team, target)

    -- Mirar hacia el centro (pelota)
    api.face_to(robotId, team, { x = ball.x, y = ball.y }, 4, 0.7, 0.0)

    return false -- No termina, gira continuamente
end

return M
