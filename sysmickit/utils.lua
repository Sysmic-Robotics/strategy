
local Vector2D = require("sysmickit.vector2D")
local api = require("sysmickit.lua_api")

-- utils.lua
local utils = {}


function utils.is_ready_to_kick(robot, ball, target)
    local SAFE_DISTANCE    = 0.18
    local ANGLE_TOLERANCE  = 0.15

    local robot_pos = Vector2D.new(robot.x, robot.y)
    local ball_pos = Vector2D.new(ball.x, ball.y)
    local target_pos = Vector2D.new(target.x, target.y)
    
    if (ball_pos - robot_pos):length() > SAFE_DISTANCE then
        return false
    end
    local desired_dir = (ball - robot_pos):normalized()
    local robot_dir = Vector2D.new(math.cos(robot.orientation), math.sin(robot.orientation))
    local angle_diff = desired_dir:angle_to(robot_dir)
    if math.abs(angle_diff) > ANGLE_TOLERANCE then
        
        return false
    end
    
    return true
end


function utils.has_captured_ball(robot, ball)
    if not robot or not robot.orientation then
        return false
    end

    local dx = ball.x - robot.x
    local dy = ball.y - robot.y
    local angle_to_ball = math.atan(dy, dx)
    local angle_diff = angle_to_ball - robot.orientation
    local aligned = math.abs(math.cos(angle_diff)) > 0.95

    local distance = math.sqrt(dx * dx + dy * dy)
    return aligned and distance < 0.2
end



--- Compute the angle (in radians) between two points.
-- The angle is from point a to point b, measured counter-clockwise from the x-axis.
-- @param a table {x, y}
-- @param b table {x, y}
-- @return number angle in radians
function utils.angle_between_points(a, b)
    return math.atan(b.y - a.y, b.x - a.x)
end

--- Euclidean distance between two points.
-- @param a table {x, y}
-- @param b table {x, y}
-- @return number
function utils.distance(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

--- Minimal absolute difference between two angles (in radians).
-- @param a number
-- @param b number
-- @return number
function utils.angle_diff(a, b)
    local diff = a - b
    while diff > math.pi do diff = diff - 2 * math.pi end
    while diff < -math.pi do diff = diff + 2 * math.pi end
    return math.abs(diff)
end


--- Get the ID of the robot closest to a specific point
--- @param robots table { [id] = {x = number, y = number}, ... }
--- @param point table {x = number, y = number}
--- @return number|nil closest_id
function utils.get_closest_robot_to_point(robots, point)
    local closest_id = nil
    local closest_dist_sq = math.huge

    for id, pos in pairs(robots) do
        if pos and pos.x and pos.y then
            local dx = pos.x - point.x
            local dy = pos.y - point.y
            local dist_sq = dx * dx + dy * dy

            if dist_sq < closest_dist_sq then
                closest_id = id
                closest_dist_sq = dist_sq
            end
        end
    end

    return closest_id
end

function utils.random_between(min, max)
    return min + math.random() * (max - min)
end

-- Devuelve 1 si antihorario, -1 si horario
function utils.rotation_direction(ball, robot, pivot)
    local center = Vector2D.new(ball.x, ball.y)
    local pos_robot = Vector2D.new(robot.x, robot.y) - center
    local pos_pivot = Vector2D.new(pivot.x, pivot.y) - center
    local cross = pos_robot:cross(pos_pivot)
    if cross > 0 then
        return 1 -- antihorario
    else
        return -1 -- horario
    end
end


--- Verifica si el camino entre dos puntos está libre de obstáculos.
-- @param start table {x, y}
-- @param goal table {x, y}
-- @param obstacles table array de {x, y}
-- @param clearance number distancia mínima para considerar libre el camino
-- @return boolean
function utils.is_path_clear(start, goal, obstacles, clearance)
    for _, obs in pairs(obstacles) do
        -- Proyección del obstáculo sobre la recta start-goal
        local dx = goal.x - start.x
        local dy = goal.y - start.y
        local length = math.sqrt(dx * dx + dy * dy)
        if length == 0 then return false end
        local t = ((obs.x - start.x) * dx + (obs.y - start.y) * dy) / (length * length)
        t = math.max(0, math.min(1, t))
        local closest = {
            x = start.x + t * dx,
            y = start.y + t * dy
        }
        local dist_sq = (obs.x - closest.x)^2 + (obs.y - closest.y)^2
        if dist_sq < clearance * clearance then
            return false
        end
    end
    return true
end


function utils.team_has_ball(team)
    local robots = api.get_allies(team)
    local ball = api.get_ball_state()
    if not ball then return false end

    for _, robot in ipairs(robots) do
        if utils.has_captured_ball(robot, ball) then
            return true
        end
    end
    return false
end




return utils
