-- CONFIGURATION
local robotId = 0
local team = 0
local test_velocities = {0.3, 0.5, 0.9, 1.2, 1.9, 2.4}
local test_duration_frames = 30
local pause_duration_frames = 30

-- VELOCITY COMBINATIONS
local combinations = {
    function(v) return { vx = v,  vy = v,  vw = 0 } end, -- vx + vy
    function(v) return { vx = v,  vy = -v, vw = 0 } end, -- vx - vy
    function(v) return { vx = v,  vy = 0,  vw = v } end, -- vx + vw
    function(v) return { vx = 0,  vy = v,  vw = v } end, -- vy + vw
    function(v) return { vx = v,  vy = v,  vw = v } end  -- vx + vy + vw
}

-- STATE
local current_comb = 1
local current_test = 1
local direction = 1
local frame_counter = 0
local paused = false

-- Stop robot
local function stop()
    send_velocity(robotId, team, 0, 0, 0)
end

function process()
    if current_test > #test_velocities then
        if current_comb >= #combinations then
            stop()
            return -- All done
        end
        current_comb = current_comb + 1
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
            if direction == 1 then
                direction = -1
            else
                direction = 1
                current_test = current_test + 1
            end
        end
        return
    end

    local v = test_velocities[current_test] * direction
    local combo = combinations[current_comb](v)
    send_velocity(robotId, team, combo.vx, combo.vy, combo.vw*3)

    frame_counter = frame_counter + 1
    if frame_counter >= test_duration_frames then
        frame_counter = 0
        paused = true
    end
end
