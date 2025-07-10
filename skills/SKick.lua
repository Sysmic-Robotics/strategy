-- Use when the ball is captured

local api = require("sysmickit.lua_api")
local SMoveDirect = require("skills.SMoveDirect")
local M = {}

--- Moves the specified robot to a given target point and returns whether it has reached it.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return boolean True if robot is close enough to the target, else false.
function M.process(robotId, team, point)
    local ball = api.get_ball_state()
    if not ball then return false end
    SMoveDirect.process(robotId,team, ball)
    api.kickx(robotId, team)
    api.dribbler(robotId,team,1)
    return true
end

return M
