local api = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local move = require("skills.SMove")
local SAim = require("skills.SAim")
local Vector2D = require("sysmickit.vector2D")
local SPivot = {}

local SAFE_DISTANCE       = 0.12   -- Distance behind the ball to prepare kick
local ANGLE_THRESHOLD = 0.2 -- Angle threshold to check if the robot, ball and target are aligned
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


--- Compute
-- @param end_a table {x, y}
-- @param center table {x, y}
-- @param end_b table {x, y}
-- @param Angle threshold to determine if aligned 
local function is_aligned(end_a,center,end_b, angle_threshold)
    local end_a_pos = Vector2D.new(end_a.x, end_a.y)
    local center_pos = Vector2D.new(center.x, center.y)
    local end_b_pos = Vector2D.new(end_b.x, end_b.y)

    local center_to_b_dir = (end_b_pos - center_pos):normalized()
    local center_to_a_dir = (end_a_pos - center_pos):normalized()
    local IDEAL_ANGLE = math.pi 
    local align_angle = center_to_b_dir:angle_to(center_to_a_dir)
    
    local align_error_abs = math.abs((math.abs(align_angle) - IDEAL_ANGLE))
    
    if align_error_abs<angle_threshold then
        return true
    end
    return false
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
    --local dist_to_approach_target = utils.distance(robot, approach_target)
    --print(dist_to_approach_target)
    local robot_pos = Vector2D.new(robot.x, robot.y)
    local ball_pos = Vector2D.new(ball.x, ball.y)
    local target_pos = Vector2D.new(target.x, target.y)
    
    if (dist_to_ball < 0.30 and is_aligned(robot_pos,ball_pos,target_pos,ANGLE_THRESHOLD))  then --Añadir que chequee que se encuentre también detrás de la pelota, si no se queda pegado.  and dist_to_approach_target < APPROACH_POINT_THRESHOLD
        SAim.process(robotId, team, ball, "medium")
    end
    move.process(robotId, team, approach_target)

    return false
end

return SPivot