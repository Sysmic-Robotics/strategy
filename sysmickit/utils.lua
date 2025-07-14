
local Vector2D = require("sysmickit.vector2D")
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


--- Check if the robot has the ball on its dribbler (distance + facing angle)
function utils.has_captured_ball(robot, ball)
    local robot_pos = Vector2D.new(robot.x, robot.y)
    local ball_pos = Vector2D.new(ball.x, ball.y)

    -- Robot forward and right vectors
    local forward = Vector2D.new(math.cos(robot.orientation), math.sin(robot.orientation))
    local right   = Vector2D.new(-forward.y, forward.x) -- perpendicular vector

    -- Transform ball position into robot's local coordinate frame
    local to_ball = ball_pos - robot_pos
    local x_local = to_ball:dot(forward) -- forward component
    local y_local = to_ball:dot(right)   -- sideways component

    -- Parameters for the rectangular capture zone
    local robot_radius = 0.09
    local offset       = robot_radius       -- where the rectangle starts
    local length       = 0.03               -- how far forward from offset
    local half_width   = 0.05               -- ± sideways from center

    -- Check if the ball is inside the forward rectangle
    if x_local >= offset and x_local <= (offset + length) and math.abs(y_local) <= half_width then
        return true
    end

    return false
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


return utils
