-- skills/SPivotKickFSM.lua
local api        = require("sysmickit.lua_api")
local utils      = require("sysmickit.utils")
local SCapture    = require("skills.SCaptureBall")      -- Updated to non-class capture_ball
local SPivotAim  = require("skills.SPivotAim")
local SKick = require("skills.SKick")
local M = {}
local kick_wait_counter = {}
local kick_wait_frames = 10 -- ~1/3 segundo a 60 fps
local approach_vel = 0.2
--- Main process function
-- @param robotId number The ID of the robot
-- @param team number The team ID
function M.process(robotId, team, target)
    -- Make sure that is near and aiming to the target
    if not SPivotAim.process(robotId, team, target) then
        kick_wait_counter[robotId] = 0
        return false
    end

    if SCapture.process(robotId, team) then
        -- Avanzar lentamente y apuntar hacia el target
        send_velocity(robotId,team,approach_vel,0,0)
        api.face_to(robotId, team, target)
        -- Esperar unos instantes antes de patear
        kick_wait_counter[robotId] = (kick_wait_counter[robotId] or 0) + 1
        if kick_wait_counter[robotId] >= kick_wait_frames then
            SKick.process(robotId, team)
            kick_wait_counter[robotId] = 0
            return true
        end
        return false
    else
        kick_wait_counter[robotId] = 0
    end
    return false
end

return M

