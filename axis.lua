local Engine = require("sysmickit.engine")

local robot_id = 0
local team = 0

-- Define test area boundaries
local xmin, xmax = -1.5, 1.5
local ymin, ymax = -2.0, 2.0


-- Duration per test step in frames
local TEST_DURATION = 120


-- Generates evenly spaced values between min and max (inclusive)
local function linspace(min, max, count)
    local values = {}
    if count == 1 then
        table.insert(values, min)
    else
        local step = (max - min) / (count - 1)
        for i = 0, count - 1 do
            table.insert(values, min + i * step)
        end
    end
    return values
end

-- Dynamic test generation
local function generate_test_steps(num_steps)
    local steps = {}

    local vx_values = linspace(-2.0, 2.0, num_steps)
    local vy_values = linspace(-2.0, 2.0, num_steps)
    local vtetha_values = linspace(-2*math.pi, 2*math.pi, num_steps)

    for _, vx in ipairs(vx_values) do
        table.insert(steps, {vx = vx, vy = 0.0, vtetha = 0.0})
    end

    for _, vy in ipairs(vy_values) do
        table.insert(steps, {vx = 0.0, vy = vy, vtetha = 0.0})
    end

    for _, vtetha in ipairs(vtetha_values) do
        table.insert(steps, {vx = 0.0, vy = 0.0, vtetha = vtetha})
    end

    return steps
end


local test_steps = generate_test_steps(5)


-- Internal state
local current_step = 1
local frame_count = 0
local state = "testing"  -- can be "testing" or "returning"

-- Helpers
local function is_out_of_bounds(x, y)
    return x < xmin or x > xmax or y < ymin or y > ymax
end

local function is_at_origin(x, y, tolerance)
    tolerance = tolerance or 0.1
    return math.abs(x) < tolerance and math.abs(y) < tolerance
end

function process()

    if current_step > #test_steps then
        -- All tests complete, ensure robot is stopped
        Engine.send_velocity(robot_id, team, 0, 0, 0)
        return
    end

    local robot_state = Engine.get_robot_state(robot_id, team)
    local x = robot_state.x
    local y = robot_state.y

    if state == "returning" then
        if is_at_origin(x, y) then
            state = "testing"
            frame_count = 0
            current_step = current_step + 1
            if current_step > #test_steps then
                -- End of tests: stop robot
                Engine.send_velocity(robot_id, team, 0, 0, 0)
                return
            end
        else
            Engine.move_to(robot_id, team, {x = 0, y = 0})
        end
        return
    end

    -- In testing mode
    local step = test_steps[current_step]
    Engine.send_velocity(robot_id, team, step.vx, step.vy, step.vtetha)

    frame_count = frame_count + 1

    if is_out_of_bounds(x, y) then
        state = "returning"
        return
    end

    if frame_count >= TEST_DURATION then
        frame_count = 0
        current_step = current_step + 1
        if current_step > #test_steps then
            Engine.send_velocity(robot_id, team, 0, 0, 0)
        end
    end
end
