local robot_id = 0
local team = 0

-- === CONFIGURATION ===
local test_value = 1.0              -- vx/vy value (±)
local switch_interval = 0.5         -- For sharp switching (s)
local test_duration = 6.0           -- Time per axis test (s)
local omega_mode = "both"           -- "sharp", "full_turn", or "both"

-- Internal state
local t0 = os.clock()
local axis_list = { "vx", "vy", "omega" }
local current_axis_index = 1
local omega_submode = "full_turn"   -- Tracks which omega test is active

-- === SHARP SWITCH FUNCTION ===
function sharp_axis_test(axis, value, interval)
    local vx, vy, omega = 0.0, 0.0, 0.0
    local t = os.clock() - t0

    if axis == "omega" then
        if omega_mode == "sharp" or (omega_mode == "both" and omega_submode == "sharp_switch") then
            -- Sharp switch: alternate ±omega
            local direction = ((math.floor(t / interval) % 2) == 0) and 1 or -1
            omega = direction * 4.0 -- High speed for sharp spin reversals

        elseif omega_mode == "full_turn" or (omega_mode == "both" and omega_submode == "full_turn") then
            omega = 3.14 -- ~180 deg/s for full spin (adjust as needed)
        end
    elseif axis == "vx" then
        local direction = ((math.floor(t / interval) % 2) == 0) and 1 or -1
        vx = direction * value
    elseif axis == "vy" then
        local direction = ((math.floor(t / interval) % 2) == 0) and 1 or -1
        vy = direction * value
    end

    send_velocity(robot_id, team, vx or 0.0, vy or 0.0, omega or 0.0)
end

-- === MAIN PROCESS LOOP ===
function process()
    local t = os.clock() - t0
    local current_axis = axis_list[current_axis_index]

    if t < test_duration then
        sharp_axis_test(current_axis, test_value, switch_interval)
    else
        -- Stop robot at end of test segment
        send_velocity(robot_id, team, 0, 0, 0)

        if current_axis == "omega" and omega_mode == "both" then
            -- Switch between full turn and sharp switch
            if omega_submode == "full_turn" then
                omega_submode = "sharp_switch"
            else
                omega_submode = "full_turn"
                current_axis_index = current_axis_index + 1
            end
        else
            -- Move to next axis normally
            current_axis_index = current_axis_index + 1
        end

        if current_axis_index > #axis_list then
            current_axis_index = 1 -- Loop
        end

        print("Test complete for axis: " .. current_axis .. " | Next up: " .. axis_list[current_axis_index])
        t0 = os.clock()
    end
end
