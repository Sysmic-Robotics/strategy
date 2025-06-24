-- CONFIGURATION
local robotId = 0
local team = 0
local test_velocities = {0.3, 0.5, 0.9, 1.2, 1.9, 2.4}

local test_duration_frames = 50    -- Duration per test
local pause_duration_frames = 30   -- Pause between each switch

-- STATE
local current_test = 1
local current_axis = "vx" -- "vx", "vy", "vw"
local direction = 1       -- 1 or -1
local frame_counter = 0
local paused = false

-- Stop command
local function stop()
    send_velocity(robotId, team, 0, 0, 0)
end

function process()
    if current_test > #test_velocities then
        if current_axis == "vx" then
            current_axis = "vy"
        elseif current_axis == "vy" then
            current_axis = "vw"
        else
            stop()
            return  -- All tests complete
        end
        current_test = 1
        direction = 1
        frame_counter = 0
        paused = false
        return
    end

    if paused then
        stop()
        frame_counter = frame_counter + 1
        if frame_counter >= pause_duration_frames then
            paused = false
            frame_counter = 0
            -- Switch direction or go to next test
            if direction == 1 then
                direction = -1
            else
                direction = 1
                current_test = current_test + 1
            end
        end
        return
    end

    -- Apply velocity in one axis and direction
    local v = test_velocities[current_test] * direction
    local vx, vy, vw = 0, 0, 0

    if current_axis == "vx" then
        vx = v
    elseif current_axis == "vy" then
        vy = v
    elseif current_axis == "vw" then
        vw = v*3
    end

    send_velocity(robotId, team, vx, vy, vw)

    frame_counter = frame_counter + 1
    if frame_counter >= test_duration_frames then
        frame_counter = 0
        paused = true
    end
end
