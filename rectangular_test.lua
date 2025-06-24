local LuaAPI = require("sysmickit.lua_api") -- Assuming the API is in 'api.lua'

-- CONFIGURATION
local robotId = 0
local team = 0
local shrink_steps = 3
local shrink_factor = 0.7
local move_threshold = 0.1
local wait_frames = 30

-- Initial rectangle configuration
local rect_center = {x = 0, y = 0}
local half_width = 2.0
local half_height = 1.2

-- STATE VARIABLES
local corners = {}
local current_index = 1
local shrinking = 1
local state = "moving"
local wait_counter = 0

-- Distance computation
local function dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

-- Corner calculation
local function compute_corners(center, hw, hh)
    return {
        {x = center.x - hw, y = center.y - hh},
        {x = center.x + hw, y = center.y - hh},
        {x = center.x + hw, y = center.y + hh},
        {x = center.x - hw, y = center.y + hh},
    }
end

-- Initialize corners
corners = compute_corners(rect_center, half_width, half_height)

-- Main control loop
function process()
    if state == "done" then return end

    local target = corners[current_index]

    if state == "moving" then
        LuaAPI.move_to(robotId, team, target)

        local robot = LuaAPI.get_robot_state(robotId, team)
        local pos = {x = robot.x, y = robot.y}

        if dist(pos, target) < move_threshold then
            state = "facing"
            wait_counter = 0
        end

    elseif state == "facing" then
        local next_index = (current_index % #corners) + 1
        local face_point = corners[next_index]

        LuaAPI.face_to(robotId, team, face_point)

        wait_counter = wait_counter + 1
        if wait_counter > wait_frames then
            current_index = current_index + 1
            if current_index > #corners then
                current_index = 1
                shrinking = shrinking + 1
                if shrinking <= shrink_steps then
                    half_width = half_width * shrink_factor
                    half_height = half_height * shrink_factor
                    corners = compute_corners(rect_center, half_width, half_height)
                else
                    state = "done"
                    return
                end
            end
            state = "moving"
        end
    end
end