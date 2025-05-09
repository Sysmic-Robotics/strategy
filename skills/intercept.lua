local api = require("sysmickit.lua_api")
local move = require("skills.move")
local aim = require("skills.aim")
local M = {}

--- Intercepts the ball at the specified point using aggressive motion.
--- @param robotId number
--- @param team number
--- @param interceptPoint table { x, y } – where to intercept
function M.process(robotId, team, interceptPoint)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return end

    -- Move at full speed to the intercept point
    move.move_to(robotId, team, interceptPoint)

    -- Optionally face the ball or intercept point (can help goalie orientation)
    aim.process(robotId, team, ball, "fast")
end

return M
