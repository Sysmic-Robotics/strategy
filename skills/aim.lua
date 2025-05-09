local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local M = {}

-- PID presets for different aiming speeds
local aim_modes = {
    fast = { kp = 1.0, ki = 1.0, kd = 0.1 },
    mid  = { kp = 0.5, ki = 0.5, kd = 0.05 },
    slow = { kp = 0.25, ki = 0.25, kd = 0.025 },
}

--- Aim the robot toward a target point using a specified mode.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table Target position with x, y.
--- @param mode string One of: "fast", "mid", "slow".
function M.process(robotId, team, point, mode)
    local robot = api.get_robot_state(robotId, team)
    local angle_to_target = math.atan(point.y - robot.y, point.x - robot.x)
    local angle_diff = utils.angle_diff(robot.orientation, angle_to_target)
    if angle_diff < 0.05 then
        return true
    end
    local preset = aim_modes[mode] or aim_modes.mid  -- default to "mid" if invalid
    api.face_to(robotId, team, point, preset.kp, preset.ki, preset.kd)
    return false
end

return M
