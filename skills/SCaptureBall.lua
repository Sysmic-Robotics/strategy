local Engine = require("sysmickit.engine")
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
    local ball = Engine.get_ball_state()
    local robot = Engine.get_robot_state(robotId, team)

    if utils.has_captured_ball(robot, ball) then
        Engine.dribbler(robotId, team, 2)
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
        if SAim.process(robotId, team, ball) then
            SMoveDirect.process(robotId, team, ball)
        end
        Engine.dribbler(robotId, team, 2)
    end

    return false
end

return M