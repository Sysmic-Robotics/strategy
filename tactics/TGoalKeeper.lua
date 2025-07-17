local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.fieldzones")
local TGoalkeeper = {}

local function compute_intercept_position(side, ball)
    local x_pos = (side == "left") and -4.3 or 4.3  -- inside the box, but not at edge
    local y_clamped = math.max(-0.5, math.min(0.5, ball.y))  -- clamp y
    return { x = x_pos, y = y_clamped }
end

function TGoalkeeper.process(robot_id, team, side)
    local robot = Robot.new(robot_id, team)
    local ball = WORLD:get_ball()
    local zone = FieldZones.GOALI_ZONE_LEFT
    if side == "right" then
        zone = FieldZones.GOALI_ZONE_RIGHT
    end

    if FieldZones.is_in_zone(ball, zone) then
        -- Aca hacer que patee para afuera
        if robot:MoveDirect(ball) and robot:Aim(ball) then
            robot:Kick()
        end
    else
        local pos = compute_intercept_position(side, ball)
        robot:MoveDirect(pos)
    end

    return false
end

return TGoalkeeper