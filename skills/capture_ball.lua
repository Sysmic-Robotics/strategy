-- capture_ball.lua
local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local move = require("skills.move")
local M = {}

-- Define states: "approach", "capture", "idle"
local state = "approach"
local safe_distance = 0.12  -- desired gap from the ball (in meters)
local threshold = 0.05      -- distance threshold to consider the target reached
local angle_tolerance = 0.1 -- radians tolerance to consider the robot is facing the ball
-- The computed approach target (a table with x and y)

--- Process the capture ball state machine.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param dribbleSpeed number Optional dribbler speed (0–10); default is 10.
function M.process(robotId, team, dribbleSpeed)
    dribbleSpeed = dribbleSpeed or 7
    local approach_target = { x = 0, y = 0 }
    local ball = api.get_ball_state()
    local robot = api.get_robot_state(robotId, team)
    if not ball or not robot then
        return false
    end

    if state == "approach" then
        local dx = robot.x - ball.x
        local dy = robot.y - ball.y
        local d = math.sqrt(dx * dx + dy * dy)
        if d == 0 then dx, dy, d = 1, 0, 1 end
        approach_target.x = ball.x + (dx / d) * safe_distance
        approach_target.y = ball.y + (dy / d) * safe_distance

        local angle_to_ball = math.atan(ball.y - robot.y, ball.x - robot.x)
        local angle_diff = utils.angle_diff(robot.orientation, angle_to_ball)

        if math.abs(angle_diff) < angle_tolerance then
            move.move_to(robotId, team, approach_target)
        else
            api.face_to(robotId, team, { x = ball.x, y = ball.y })
        end

        local dist_to_target = utils.distance(robot, approach_target)
        if dist_to_target < threshold and math.abs(angle_diff) < angle_tolerance then
            state = "capture"
        end
        return false

    elseif state == "capture" then
        api.dribbler(robotId, team, dribbleSpeed)
        api.move_to(robotId, team, { x = ball.x, y = ball.y })

        if utils.distance(robot, ball) <= safe_distance then
            state = "idle"
        elseif utils.distance(robot, approach_target) > threshold then
            state = "approach"
        end
        return false

    elseif state == "idle" then
        api.dribbler(robotId, team, dribbleSpeed)
        if utils.distance(robot, ball) > (safe_distance + threshold) then
            state = "approach"
            return false
        end
        return true  -- Ball is considered captured
    end

    return false  -- Fallback
end



return M
