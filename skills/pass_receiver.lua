-- pass_receiver.lua
local api   = require("sysmickit.lua_api")
local move  = require("skills.move")
local aim   = require("skills.aim")
local utils = require("sysmickit.utils")
local M     = {}

-- Tunable: max distance the robot will step sideways
local max_intercept_dist = 0.2

--- Lateral intercept: step into the ball’s path without chasing it,
--- but never more than max_intercept_dist from the robot’s current pos.
--- @param robotId number
--- @param team number
function M.process(robotId, team)
    local robot = api.get_robot_state(robotId, team)
    local ball  = api.get_ball_state()
    if not robot or not ball then return false end

    -- 1) Ball‐velocity vector
    local bvx, bvy = ball.vel_x or 0, ball.vel_y or 0
    local speed = math.sqrt(bvx*bvx + bvy*bvy)
    

    -- 2) Unit direction of travel
    local ux, uy = 0, 0
    if speed ~= 0 then
        ux, uy = bvx/speed, bvy/speed
    end

    -- 3) Compute projection “t” of robot onto that path
    local wx, wy = robot.x - ball.x, robot.y - ball.y
    local t = wx*ux + wy*uy

    -- 4) Raw intercept point on the infinite path
    local rawX = ball.x + ux * t
    local rawY = ball.y + uy * t

    -- 5) Compute vector from robot to that point
    local dx, dy = rawX - robot.x, rawY - robot.y
    local dist = math.sqrt(dx*dx + dy*dy)

    -- 6) Clamp distance if too far
    local interceptPoint = { x = rawX, y = rawY }
    if dist > max_intercept_dist then
        local scale = max_intercept_dist / dist
        interceptPoint.x = robot.x + dx * scale
        interceptPoint.y = robot.y + dy * scale
    end

    -- 7) Move purely sideways toward the (clamped) intercept point
    move.move_to(robotId, team, interceptPoint)

    -- 8) Face the ball and spin up dribbler
    aim.process(robotId, team, ball, "mid")
    api.dribbler(robotId, team, 7)
    if utils.distance(robot, ball) < (0.12) then
        return true
    end

    return false
end

return M
