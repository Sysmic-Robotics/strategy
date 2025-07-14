-- tactics/kick_to_goal.lua
local SKick = require("skills.kick_to_point")

local KickToGoal = {}
KickToGoal.__index = KickToGoal

function KickToGoal.new()
    return setmetatable({
        state = "aim",
    }, KickToGoal)
end

--- Process the kick to goal tactic
--- @param robot_id number
--- @param team number
--- @return boolean true if shot is completed
function KickToGoal:process(robot_id, team)
    local goal_point = { x = 4.5, y = 0 } -- Assuming positive x is opponent's goal
    SKick.process(robot_id, team, goal_point)
    return self.state == "done"
end

return KickToGoal