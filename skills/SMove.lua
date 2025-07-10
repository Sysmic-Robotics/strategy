local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local M = {}

local DEFAULT_POSITION_THRESHOLD = 0.05  -- meters

--- Moves the specified robot to a given target point and returns whether it has reached it.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param target table A table containing target coordinates with keys `x` and `y`.
--- @param threshold? number Optional override for position threshold
--- @return boolean True if robot is close enough to the target, else false.
function M.process(robotId, team, target, threshold)
    local robot = api.get_robot_state(robotId, team)
    if not robot then return false end

    local dist = utils.distance(robot, target)
    local used_threshold = threshold or DEFAULT_POSITION_THRESHOLD

    if dist < used_threshold then
        return true
    end

    api.move_to(robotId, team, target)
    api.face_to(robotId, team, target)
    return false
end

return M
