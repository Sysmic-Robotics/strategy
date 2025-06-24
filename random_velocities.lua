local LuaAPI = require("sysmickit.lua_api") -- assuming LuaAPI is required

-- CONFIGURATION
local robotId = 0
local team = 0

local velocity_range = {
    vx = {min = -4.0, max = 4.0},
    vy = {min = -4.0, max = 4.0},
    vw = {min = -6.0, max = 6.0}
}

local change_interval_frames = 10
local field_limits = {
    x = {-2.0, 2.0},
    y = {-1.0, 1.0}
}
local home_position = {x = 0.0, y = 0.0}
local return_threshold = 0.1

-- STATE
local frame_counter = 0
local current_vx = 0
local current_vy = 0
local current_vw = 0
local returning_home = false

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

    if returning_home then
        LuaAPI.move_to(robotId, team, home_position)
        if distance(pos, home_position) < return_threshold then
            returning_home = false
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

    send_velocity(robotId, team, current_vx, current_vy, current_vw)
    frame_counter = frame_counter + 1
end
