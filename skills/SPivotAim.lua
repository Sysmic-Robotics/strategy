local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local move = require("skills.SMove")
local SAim = require("skills.SAim")
local Vector2D = require("sysmickit.vector2D")
local SPivot = {}

local SAFE_DISTANCE       = 0.12   -- Distance behind the ball to prepare kick

--- Compute a point behind the ball, in line with the target direction.
-- @param ball table {x, y}
-- @param target table {x, y}
-- @param distance number Distance behind the ball
-- @return Vector2D Approach position
local function compute_approach_point(ball, target, distance)
    local ball_pos = Vector2D.new(ball.x, ball.y)
    local target_pos = Vector2D.new(target.x, target.y)
    local direction = (target_pos - ball_pos):normalized()
    --local distance = (robot - ball).x
    local approach_point = ball_pos - direction * distance
    return approach_point
end

--- Align behind the ball and face the target
-- @param robotId number
-- @param team number
-- @param target table {x, y} where we want to kick the ball to
-- @return boolean true if robot is ready to kick
function SPivot.process(robotId, team, target)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball or not target then return false end
    
    if utils.is_ready_to_kick(robot, ball, target) then
        return true
    end
    -- 1. Compute ideal pivot position
    local approach_target = compute_approach_point(ball, target, SAFE_DISTANCE)

    -- 3. Move to position behind ball and aim
    local dist_to_ball = utils.distance(robot, ball)
    if dist_to_ball < 0.30 then
        SAim.process(robotId, team, ball, "medium")
    end
    move.process(robotId, team, approach_target)

    return false
end

return SPivot
