local api = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local SAim = require("skills.SAim")
local move = require("skills.SMove")

local M = {}

local block_distance = 0.5

--- Places the robot between the ball and a given target (point or opponent).
--- process returns true when robot is at mark point and facing target, false otherwise.
--- @param robotId number
--- @param team number
--- @param target_id number
--- @param target_team number
function M.process(robotId, team, target_id, target_team)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return false end

    -- Resolve target position
    local targetPos = api.get_robot_state(target_id, target_team)

    -- Compute mark point
    local dx = targetPos.x - ball.x
    local dy = targetPos.y - ball.y
    local d = math.sqrt(dx * dx + dy * dy)
    if d == 0 then dx, dy, d = 1, 0, 1 end

    local markPoint = {
        x = ball.x + dx * (1 - block_distance / d),
        y = ball.y + dy * (1 - block_distance / d),
    }

    -- Move and aim
    local at_position = move.process(robotId, team, markPoint)
    --local at_orientation = aim.process(robotId, team, targetPos)

    if at_position then
        SAim.process(robotId, team, ball)
        return true
    end
    return false
end

return M
