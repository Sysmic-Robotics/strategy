local api = require("sysmickit.lua_api")
local capture = require("skills.capture_ball")
local aim = require("skills.aim")
local utils = require("sysmickit.utils")
local M = {}

-- Internal state machine
local state = "capture"

--- Executes a kick-to-point skill using a state machine.
--- @param robotId number
--- @param team number
--- @param target table { x, y }
--- @return boolean True if the kick has been performed, false otherwise
function M.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    if not robot or not api.get_ball_state() then return false end

    if state == "capture" then
        local captured = capture.process(robotId, team, 10)
        if captured then
            state = "align"
        end
        return false

    elseif state == "align" then
        api.dribbler(robotId, team, 7)
        local is_aiming = aim.process(robotId, team, target, "slow")

        if is_aiming then
            state = "kick"
        end
        return false

    elseif state == "kick" then
        api.kickx(robotId, team)
        state = "capture"  -- Reset for reuse
        return true
    end

    return false
end

return M
