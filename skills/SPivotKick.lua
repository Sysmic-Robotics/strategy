-- skills/SPivotKickFSM.lua
local api        = require("sysmickit.engine")
local utils      = require("sysmickit.utils")
local SCapture    = require("skills.SCaptureBall")      -- Updated to non-class capture_ball
local SPivotAim  = require("skills.SPivotAim")
local SKick = require("skills.SKick")
local M = {}
--- Main process function
-- @param robotId number The ID of the robot
-- @param team number The team ID
function M.process(robotId, team, target)
    -- Make sure that is near and aiming to the target
    if not SPivotAim.process(robotId, team, target) then
        return false
    end

    if SCapture.process(robotId, team) then
        SKick.process(0,0)
        return true
    end
    return false
end

return M

