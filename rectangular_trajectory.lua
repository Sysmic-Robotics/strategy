local Engine = require("sysmickit.engine")

local robot_id = 0
local team = 0

-- Parameters
local NUM_POINTS = 18          -- Number of waypoints on the circle
local RADIUS = 1.0             -- Radius of the circle
local CENTER = {x = 0.0, y = 0.0}
local TOLERANCE = 0.1

-- Internal state
local path = {}
local current_target = 1

-- Generate circular path
local function generate_circular_path(center, radius, num_points)
    local circle = {}
    for i = 0, num_points - 1 do
        local angle = (2 * math.pi * i) / num_points
        local x = center.x + radius * math.cos(angle)
        local y = center.y + radius * math.sin(angle)
        table.insert(circle, {x = x, y = y})
    end
    return circle
end

-- Tolerance-based position check
local function is_at_point(x, y, point, tolerance)
    return math.abs(x - point.x) < tolerance and math.abs(y - point.y) < tolerance
end

-- Init path once
path = generate_circular_path(CENTER, RADIUS, NUM_POINTS)

function process()
    local robot_state = Engine.get_robot_state(robot_id, team)
    local x, y = robot_state.x, robot_state.y
    local target = path[current_target]

    -- Move to the current circular waypoint
    Engine.move_to(robot_id, team, {x = target.x, y = target.y})
    Engine.face_to(robot_id, team, target, 2.0, 0.01, 0)
    -- Advance to the next point if reached
    if is_at_point(x, y, target, TOLERANCE) then
        current_target = (current_target % #path) + 1
    end
end
