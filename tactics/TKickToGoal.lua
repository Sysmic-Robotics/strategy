-- tactics/kick_to_goal.lua
local SKick = require("skills.kick_to_point")

local KickToGoal = {}
KickToGoal.__index = KickToGoal

function KickToGoal.new()
    return setmetatable({}, KickToGoal)
end

--- Shoot the ball towards the opponent goal.
--- @param robot_id number
--- @param team number (0=blue,1=yellow)
--- @return boolean always true after issuing the kick
function KickToGoal:process(robot_id, team)
    local goal_point = { x = 4.5, y = 0 }
    if team == 1 then
        goal_point.x = -4.5
    end
    SKick.process(robot_id, team, goal_point)
    return true
end

return KickToGoal