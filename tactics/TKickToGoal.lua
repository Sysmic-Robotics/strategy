local SPivotKick = require("skills.SPivotKick")

local TKickToGoal = {}
TKickToGoal.__index = TKickToGoal

function TKickToGoal.new()
    return setmetatable({}, TKickToGoal)
end

--- Process the kick to goal tactic
--- @param robot_id number
--- @param team number
--- @return boolean true if shot is completed
function TKickToGoal:process(robot_id, team)
    -- Define the correct goal depending on team (assuming 0: izquierda, 1: derecha)
    local goal_x = team == 0 and 4.5 or -4.5
    local goal_point = { x = goal_x, y = 0 }
    -- Usar SPivotKick, que es la skill moderna y robusta
    return SPivotKick.process(robot_id, team, goal_point)
end

return TKickToGoal
