-- utils.lua
local M = {}

--- Euclidean distance between two points.
-- @param a table {x, y}
-- @param b table {x, y}
-- @return number
function M.distance(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

--- Minimal absolute difference between two angles (in radians).
-- @param a number
-- @param b number
-- @return number
function M.angle_diff(a, b)
    local diff = a - b
    while diff > math.pi do diff = diff - 2 * math.pi end
    while diff < -math.pi do diff = diff + 2 * math.pi end
    return math.abs(diff)
end


--- Distancia desde el punto C al segmento AB
-- @param ax number
-- @param ay number
-- @param bx number
-- @param by number
-- @param cx number
-- @param cy number
-- @return number
function M.distance_to_segment(ax, ay, bx, by, cx, cy)
    local abx, aby = bx - ax, by - ay
    local acx, acy = cx - ax, cy - ay
    local ab_len_sq = abx * abx + aby * aby
    if ab_len_sq == 0 then return math.sqrt((cx - ax)^2 + (cy - ay)^2) end
    local t = math.max(0, math.min(1, (acx * abx + acy * aby) / ab_len_sq))
    local proj_x = ax + t * abx
    local proj_y = ay + t * aby
    local dx = proj_x - cx
    local dy = proj_y - cy
    return math.sqrt(dx * dx + dy * dy)
end

--- Verifica si hay obstáculos entre dos puntos (robots contrarios)
-- @param passer table {x, y}
-- @param receiver table {x, y}
-- @param team number (0 o 1)
-- @param radius number tolerancia
-- @return boolean
function M.has_obstacle_between(passer, receiver, team, radius)
    radius = radius or 0.25
    for id = 0, 10 do
        local other = require("sysmickit.lua_api").get_robot_state(id, 1 - team)
        if other and other.active then
            local d = M.distance_to_segment(passer.x, passer.y, receiver.x, receiver.y, other.x, other.y)
            if d < radius then
                print("[Obstacle] Robot " .. id .. " bloquea la línea de pase 🚧")
                return true
            end
        end
    end
    return false
end

return M
