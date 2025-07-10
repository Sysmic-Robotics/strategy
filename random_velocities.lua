local LuaAPI = require("sysmickit.lua_api") -- assuming LuaAPI is required

-- CONFIGURATION
local robotId = 0
local team = 0

local velocity_range = {
    vx = {min = -3.0, max = 3.0},
    vy = {min = -4.0, max = 4.0},
    vw = {min = -3.0, max = 3.0}
}

local change_interval_frames = 10
local field_limits = {
    x = {-1.0, 1.0},
    y = {-0.9, 0.9}
}
local home_position = {x = 0.0, y = 0.0}
local return_threshold = 0.1

-- STATE
local frame_counter = 0
local current_vx = 0
local current_vy = 0
local current_vw = 0
local returning_home = false
local pause_mode = false
local pause_counter = 0
local pause_duration = 0
local state = "go_home"
local state_timer = 0

-- Helpers
local function random_range(min, max)
    return min + math.random() * (max - min)
end

local function new_random_burst()
    current_vx = random_range(velocity_range.vx.min, velocity_range.vx.max)
    current_vy = random_range(velocity_range.vy.min, velocity_range.vy.max)
    current_vw = random_range(velocity_range.vw.min, velocity_range.vw.max)
end

local function is_out_of_bounds(x, y)
    return x < field_limits.x[1] or x > field_limits.x[2]
        or y < field_limits.y[1] or y > field_limits.y[2]
end

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

function process()
    local robot = LuaAPI.get_robot_state(robotId, team)
    local pos = {x = robot.x, y = robot.y}

    if state == "go_home" then
        LuaAPI.move_to(robotId, team, home_position)
        LuaAPI.face_to(robotId, team, home_position)
        if distance(pos, home_position) < return_threshold then
            state = "wait"
            state_timer = 0
        end
        return
    end

    if state == "wait" then
        send_velocity(robotId, team, 0, 0, 0)
        state_timer = state_timer + 1
        if state_timer >= 300 then -- 5 segundos a 60 fps
            state = "random_move"
            frame_counter = 0
            new_random_burst()
        end
        return
    end

    if state == "random_move" then
        if frame_counter >= 3600 then -- 1 minuto a 60 fps
            state = "stop"
            send_velocity(robotId, team, 0, 0, 0)
            return
        end
        if returning_home then
            LuaAPI.move_to(robotId, team, home_position)
            LuaAPI.face_to(robotId, team, home_position)
            if distance(pos, home_position) < return_threshold then
                returning_home = false
                frame_counter = 0
                new_random_burst()
            end
            return
        end
        if pause_mode then
            send_velocity(robotId, team, 0, 0, 0)
            pause_counter = pause_counter + 1
            if pause_counter >= pause_duration then
                pause_mode = false
                pause_counter = 0
                frame_counter = 0
                new_random_burst()
            end
            return
        end
        if is_out_of_bounds(pos.x, pos.y) then
            returning_home = true
            return
        end
        if frame_counter % change_interval_frames == 0 then
            new_random_burst()
        end
        if frame_counter > 0 and frame_counter % 600 == 0 then -- cada 10 segundos
            pause_mode = true
            pause_duration = math.random(120, 240) -- entre 2 y 4 segundos
            pause_counter = 0
            send_velocity(robotId, team, 0, 0, 0)
            return
        end
        send_velocity(robotId, team, current_vx, current_vy, current_vw)
        frame_counter = frame_counter + 1
        return
    end

    if state == "stop" then
        send_velocity(robotId, team, 0, 0, 0)
        return
    end
end
