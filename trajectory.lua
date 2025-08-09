-- trajectory.lua
local Engine = require("sysmickit.engine")
local robot_id = 0
local team = 0

-- Waypoints to follow (meters)
local PATH = {
    { x = -0.4,  y = 0.3 },
    { x = 0.4,  y = 0.3 },
    { x = 0.4,  y = -0.3 },
    { x = -0.4,  y = -0.3 },
}

local NEAR_R = 0.08   -- how close counts as "at" a waypoint
local LOOP   = true   -- loop back to first waypoint when done

-- Internal state
local idx = 1

local function dist2(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return dx * dx + dy * dy
end

local function at_waypoint(state, wp)
    if not state or not wp then return false end
    return dist2(state.x or 0, state.y or 0, wp.x, wp.y) <= (NEAR_R * NEAR_R)
end

local function trajectory_process()
    if #PATH == 0 then return end

    local current_point = PATH[idx]
    Engine.move_to(robot_id, team, current_point)
    Engine.face_to(robot_id, team, current_point, 4.0, 0.7, 0.0)
    local s = Engine.get_robot_state(robot_id, team)
    if at_waypoint(s, current_point) then
        if idx < #PATH then
            idx = idx + 1
        elseif LOOP then
            idx = 1
        end
    end
end

local TEST_FRAMEWORK = require("test_framework")
local test_framework = TEST_FRAMEWORK.new(robot_id, team, trajectory_process)

function process()
    test_framework:process()
end
