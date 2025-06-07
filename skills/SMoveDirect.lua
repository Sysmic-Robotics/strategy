local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")

local MoveDirect = {}

local POSITION_THRESHOLD = 0.05  -- meters

--- Moves the specified robot to a given target point and returns whether it has reached it.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param target table A table containing target coordinates with keys `x` and `y`.
--- @return boolean True if robot is close enough to the target, else false.
function MoveDirect.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    
    if not robot then
        return false
    end

    if utils.distance(robot, target) < POSITION_THRESHOLD then
        return true
    end
    
    api.move_direct(robotId, team, target)
    return false
end

return MoveDirect
