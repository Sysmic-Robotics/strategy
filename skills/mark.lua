local api = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local aim = require("skills.SAim")
local move = require("skills.SMove")

local M = {}

-- How far to position away from the target line (in meters)
local block_distance = 0.3

--- Places the robot between the ball and a given target (point or opponent).
--- @param robotId number
--- @param team number
--- @param target table Can be:
---   { x, y } -> point to block,
---   or { id = opponentId, team = 1 } -> opponent to block
function M.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return end

    -- Resolve target position
    local targetPos
    if target.x and target.y then
        targetPos = target
    elseif target.id and target.team then
        targetPos = api.get_robot_state(target.id, target.team)
    end
    if not targetPos then return end

    -- Compute a point between the target and ball, away from the target
    local dx = targetPos.x - ball.x
    local dy = targetPos.y - ball.y
    local d = math.sqrt(dx * dx + dy * dy)
    if d == 0 then dx, dy, d = 1, 0, 1 end

    local markPoint = {
        x = ball.x + dx * (1 - block_distance / d),
        y = ball.y + dy * (1 - block_distance / d),
    }

    -- Move the robot to the mark point
    move.process(robotId, team, markPoint)

    -- Face the opponent or ball
    aim.process(robotId, team, targetPos, "mid")
end

return M