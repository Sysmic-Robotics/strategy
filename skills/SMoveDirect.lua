local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local SAim = require("skills.SAim")
local MoveDirect = {}

local DEFAULT_POSITION_THRESHOLD = 0.001
local DEFAULT_ANGLE_THRESHOLD = 0.9 -- Radianes (0.5rad = ~28.6 grados), ajusta según necesidad
--- @param id number Robot id
--- @param team number Robot team
--- @param target table {x, y}
function MoveDirect.process(id, team, target)
    local state = Engine.get_robot_state(id,team)
    local dist = utils.distance(state, target)
    if dist <= DEFAULT_POSITION_THRESHOLD then
        return true
    end
        -- Calcular ángulo deseado y diferencia con orientación actual
    local dx = target.x - state.x
    local dy = target.y - state.y
    local desired_angle = math.atan(dy, dx)
    local angle_diff = utils.angle_diff(state.orientation, desired_angle)

    if math.abs(angle_diff) > DEFAULT_ANGLE_THRESHOLD then
        -- Apuntar primero antes de moverse
        if math.abs(angle_diff) > math.pi/2 then -- 0.3 radianes de tolerancia (~17°)
             local opposite_angle = (desired_angle + math.pi) % (2 * math.pi)
            -- Puedes crear un "punto opuesto" lejos en esa dirección
            local r = 1 -- distancia arbitraria
            local opposite_point = {
                x = state.x + r * math.cos(opposite_angle),
                y = state.y + r * math.sin(opposite_angle)
            }
            SAim.process(id, team, opposite_point)
        else
            SAim.process(id, team, target)
        end
    end

    Engine.move_direct(id, team, target)
    return false
end

return MoveDirect
