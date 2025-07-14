local api = require("sysmickit.engine")
local move = require("skills.SMove")
local aim = require("skills.SAim")
local utils = require("sysmickit.utils")
local M = {}

--- Intercepts the ball at the specified point using aggressive motion.
--- process returns true when robot is at intercept point and captures the ball, false otherwise.
--- @param robotId number
--- @param team number
--- @param interceptPoint table { x, y }
function M.process(robotId, team, interceptPoint)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return false end

    -- Move to the intercept point
    local at_target = move.process(robotId, team, interceptPoint)
    -- Orient towards the ball for better interception
    aim.process(robotId, team, ball, "fast")

    -- Option 1: Si quieres solo retornar cuando el robot llegue al punto Y capture la pelota
    if at_target and utils.has_captured_ball(robot, ball) then
        return true
    end
    -- Option 2: Si quieres retornar cuando llegue al punto aunque no haya captura, usa solo:
    -- if at_target then return true end

    return false
end

return M

