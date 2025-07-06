local SMove = require("skills.SMove")
local SAim = require("skills.SAim")
local SCapture = require("skills.SCaptureBall")
local SKick = require("skills.SKick")

local robot_id = 0
local team_id = 0

local state = "move"
local move_target = { x = 1.5, y = -2.0 }
local kick_target = { x = 0.0, y = 0.0 }

function process()
    if state == "move" then
        if SMove.process(robot_id, team_id, move_target) then
            state = "capture"
        end
    elseif state == "capture" then
        if SCapture.process(robot_id, team_id) then
            state = "aim"
        end
    elseif state == "aim" then
        if SAim.process(robot_id, team_id, kick_target, "mid") then
            state = "kick"
        end
    elseif state == "kick" then
        if SKick.process(robot_id, team_id, kick_target) then
            state = "done"
        end
    end
end
