local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local M = {}

local position_threshold = 0.05  -- meters

--- Moves the specified robot to a given target point and returns whether it has reached it.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param target table A table containing target coordinates with keys `x` and `y`.
--- @return boolean True if robot is close enough to the target, else false.
function M.move_to(robotId, team, target)
    api.move_to(robotId, team, target)

    local robot = api.get_robot_state(robotId, team)
    if not robot then return false end

    local dist = utils.distance(robot, target)
    return dist < position_threshold
end

return M
