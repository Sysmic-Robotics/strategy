local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local Vector2D = require("sysmickit.vector2D")
local SMove = require("skills.SMove")
local SAim = require("skills.SAim")
local SMoveDirect = require("skills.SMoveDirect")

local M = {}

local SAFE_DISTANCE = 0.18  -- Desired distance to ball


--- Main process function
-- @param robotId number The ID of the robot
-- @param team number The team ID
function M.process(robotId, team)
    local ball = api.get_ball_state()
    local robot = api.get_robot_state(robotId, team)

    if utils.has_captured_ball(robot, ball) then
        api.dribbler(robotId, team, 10)
        return true
    end

    -- Prepare to move toward ball
    local robot_pos = Vector2D.new(robot.x, robot.y)
    local ball_pos = Vector2D.new(ball.x, ball.y)
    local direction = (robot_pos - ball_pos):normalized()
    local robot_to_ball = ball_pos + direction * SAFE_DISTANCE

    -- Distance check to decide movement direct or movement with path planning
    if utils.distance(robot, robot_to_ball) > SAFE_DISTANCE then
        SMove.process(robotId, team, robot_to_ball)
    else
        -- Make sure to always approach the ball while is aiming
        if SAim.process(robotId, team, ball, "medium") then
            SMoveDirect.process(robotId, team, ball)
        end
        api.dribbler(robotId, team, 10)
    end

    return false
end

return M