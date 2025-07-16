-- tactics/kick_to_goal.lua
local SKick = require("skills.kick_to_point")

local KickToGoal = {}
KickToGoal.__index = KickToGoal

-- Ahora recibe el lado al crear la instancia (opcional, puede cambiar por ciclo)
function KickToGoal.new(play_side)
    return setmetatable({
        state = "aim",
        play_side = play_side or "right",
    }, KickToGoal)
end

--- Process the kick to goal tactic
--- @param robot_id number
--- @param team number
--- @param play_side string ("left" o "right"), opcional, sobreescribe el de la instancia
--- @return boolean true if shot is completed
function KickToGoal:process(robot_id, team, play_side)
    play_side = play_side or self.play_side or "right"
    local goal_point
    if play_side == "left" then
        goal_point = { x = 4.5, y = 0 }
    else
        goal_point = { x = -4.5, y = 0 }
    end
    SKick.process(robot_id, team, goal_point)
    return self.state == "done"
end

return KickToGoal
