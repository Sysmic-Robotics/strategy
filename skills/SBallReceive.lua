-- skills/ReceiveBall.lua
-- Moves robot to intercept ball smoothly, matching its motion

local api = require("sysmickit.engine")
local SMove = require("skills.SMove")
local Vector2D = require("sysmickit.vector2D")
local SCaptureBall = require("skills.SCaptureBall")
local utils = require("sysmickit.utils")
local M = {}

local ROBOT_MAX_SPEED = 3.0           -- m/s
local TIME_STEP = 0.016                -- seconds (try every 50ms)
local MAX_PREDICT_TIME = 2.0          -- max 2 seconds ahead
local INTERCEPT_RADIUS = 0.1          -- how close is "good enough" for intercept
local ALIGN_ANGLE_THRESHOLD = 0.4     -- radians ~23 degrees

--- Moves robot to intercept the ball without bouncing.
--- @param robotId number
--- @param team number
--- @return boolean True if robot is in interception position
function M.process(robotId, team)
    local ball = api.get_ball_state()
    local robot = api.get_robot_state(robotId, team)

    local ball_pos = Vector2D.new(ball.x, ball.y)
    local ball_vel = Vector2D.new(ball.vel_x, ball.vel_y)
    local robot_pos = Vector2D.new(robot.x, robot.y)

    local intercept_point = nil

    -- Try future predictions in 50ms steps
    for t = 0.016, MAX_PREDICT_TIME, TIME_STEP do
        local predicted_pos = ball_pos + ball_vel * t
        local dist = (predicted_pos - robot_pos):length()
        local time_to_reach = dist / ROBOT_MAX_SPEED

        if time_to_reach <= t then
            -- Check alignment
            local ball_dir = ball_vel:normalized()
            local to_target = (predicted_pos - robot_pos):normalized()
            local angle = to_target:angle_to(ball_dir)

            if math.abs(angle) <= ALIGN_ANGLE_THRESHOLD then
                intercept_point = predicted_pos
                break
            end
        end
    end

    -- If no valid point found, fallback to current ball position
    if not intercept_point then
        intercept_point = ball_pos
    end

    -- Move robot to intercept point
    if utils.distance(intercept_point, ball) <= 0.1 then
        return SCaptureBall.process(robotId, team)
    end

    local arrived = SMove.process(robotId, team, {
        x = intercept_point.x,
        y = intercept_point.y
    })

    -- Activate dribbler for soft receive and optionally kick to clear
    api.dribbler(robotId, team, 5)

    -- If close enough to intercept point and almost aligned, receive is done
    return arrived
end

return M
