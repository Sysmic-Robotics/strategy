local Engine = require("sysmickit.engine")

local robot_id = 0
local team = 0

-- Define the test area boundaries
local xmin, xmax = -1.5, 1.5
local ymin, ymax = -2.0, 2.0

-- Velocity limits
local MAX_VELOCITY = 3.0
local MAX_ROTATION = math.pi

-- Current behavior state: "test" or "returning"
local state = "test"

-- Frame counter and current velocity
local frames = 0
local current_vx, current_vy, current_vtetha = 0, 0, 0

-- Random seed
math.randomseed(os.time())

function get_random_velocity()
    local vx = (math.random() * 2 - 1) * MAX_VELOCITY
    local vy = (math.random() * 2 - 1) * MAX_VELOCITY
    local vtetha = (math.random() * 2 - 1) * MAX_ROTATION
    return vx, vy, vtetha
end

function is_out_of_bounds(x, y)
    return x < xmin or x > xmax or y < ymin or y > ymax
end

function is_at_origin(x, y, tolerance)
    tolerance = tolerance or 0.1
    return math.abs(x) < tolerance and math.abs(y) < tolerance
end

function process()
    local robot_state = Engine.get_robot_state(robot_id, team)
    local x = robot_state.x
    local y = robot_state.y
    if state == "test" then
        if is_out_of_bounds(x, y) then
            state = "returning"
        else
            if frames >= 20 then
                current_vx, current_vy, current_vtetha = get_random_velocity()
                frames = 0
            end
            Engine.send_velocity(robot_id, team, current_vx, current_vy, current_vtetha)
            frames = frames + 1
        end

    elseif state == "returning" then
        if is_at_origin(x, y) then
            state = "test"
        else
            Engine.move_to(robot_id, team, {x = 0, y = 0})
        end
    end
end
