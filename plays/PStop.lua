local Engine = require("sysmickit.engine")
local utils  = require("sysmickit.utils")

local PStop = {}
PStop.__index = PStop

-- Parámetros oficiales
local SAFE_DIST = 0.5  -- Distancia mínima al balón (m)
local RETREAT_DIST = 0.6  -- Hasta dónde retroceder si está muy cerca

-- Instancia la play (dummy)
function PStop.new()
    return setmetatable({}, PStop)
end

function PStop:assign_roles(roles) end -- No hace nada, pero mantiene convención

function PStop:is_done(game_state)
    return false  -- Nunca termina sola (el árbitro controla STOP)
end

function PStop:process(game_state)
    local team = game_state.team or 0
    local ball = Engine.get_ball_state()
    if not ball then return end

    for robot_id = 0, 5 do
        local robot = Engine.get_robot_state(robot_id, team)
        if robot then
            local dist = utils.distance(robot, ball)
            if dist < SAFE_DIST then
                -- Muy cerca: retrocede un poco alejándose del balón
                local dx = robot.x - ball.x
                local dy = robot.y - ball.y
                local len = math.sqrt(dx * dx + dy * dy)
                local retreat
                if len > 1e-3 then
                    local scale = RETREAT_DIST / len
                    retreat = {
                        x = ball.x + dx * scale,
                        y = ball.y + dy * scale
                    }
                else
                    -- Muy cerca o encima: mueve a una posición segura (por ej, un lateral)
                    retreat = { x = robot.x + 0.7, y = robot.y }
                end
                Engine.move_to(robot_id, team, retreat)
            else
                -- Detén el robot (sin avanzar)
                Engine.stop_robot(robot_id, team)
            end
        end
    end
end

return PStop
