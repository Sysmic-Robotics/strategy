local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")

local Aim = {}

local DEFAULT_ORIENTATION_THRESHOLD = 0.01  -- radians

--- @param id number Robot id
--- @param team number Robot team
--- @param target table {x, y} Point to aim at
function Aim.process(id, team, target)
    local robot = Engine.get_robot_state(id, team)
    if not robot then return false end

    -- Calculate angle from robot to target
    local dx = target.x - robot.x
    local dy = target.y - robot.y
    local target_angle = math.atan(dy, dx)

    local angle_diff = utils.angle_diff(robot.orientation, target_angle)

    if math.abs(angle_diff) <= DEFAULT_ORIENTATION_THRESHOLD then
        return true
    end

    Engine.face_to(id, team, target)
    return false
end

return Aim
