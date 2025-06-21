local api = require("sysmickit.lua_api")
local sCapture = require("skills.SCaptureBall")
local aim = require("skills.SAim")
local M = {}


--- Executes a kick-to-point skill using a state machine.
--- @param robotId number
--- @param team number
--- @param target table { x, y }
--- @return boolean True if the kick has been performed, false otherwise
function M.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    if not robot or not api.get_ball_state() then return false end

    -- Ensure to capture ball
    if not sCapture.process(robotId, team, 10) then
        return false
    end

    if not aim.process(robotId, team, target, "slow") then
        api.dribbler(robotId, team, 10)
        return false
    end
    -- The ball is captured and is aiming
    api.dribbler(robotId, team, 10)
    api.kickx(robotId, team)

    return true
end

return M
