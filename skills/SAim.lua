local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local FSM = require("sysmickit.fsm")

local M = {}

-- Store FSM instances per robot/team
local instances = {}



-- PID presets
local aim_modes = {
    fast = { kp = 1.0, ki = 1.0, kd = 0.1 },
    mid  = { kp = 0.5, ki = 0.5, kd = 0.05 },
    slow = { kp = 0.25, ki = 0.25, kd = 0.025 },
}

--- Creates an FSM to rotate a robot to face a target point.
--- @param robotId number
--- @param team number
--- @param point table {x, y}
--- @param mode string ("fast", "mid", "slow")
--- @return FSM
function M.new(robotId, team, point, mode)
    local fsm = FSM.new("rotate", "[SAim]")
    local preset = aim_modes[mode] or aim_modes.mid

    fsm:add_state("rotate", {
        update = function(self)
            local robot = api.get_robot_state(robotId, team)
            if not robot then return end

            local angle_to_target = math.atan(point.y - robot.y, point.x - robot.x)
            local angle_diff = utils.angle_diff(robot.orientation, angle_to_target)

            if math.abs(angle_diff) < 0.05 then
                self:change_state("done")
            else
                api.face_to(robotId, team, point, preset.kp, preset.ki, preset.kd)
            end
        end
    })

    fsm:add_state("done", {
        update = function(self)
            local robot = api.get_robot_state(robotId, team)
            if not robot then return end

            local angle_to_target = math.atan(point.y - robot.y, point.x - robot.x)
            local angle_diff = utils.angle_diff(robot.orientation, angle_to_target)

            if math.abs(angle_diff) >= 0.05 then
                self:change_state("rotate")
            end
        end
    })

    fsm:set_done_state("done")

    return fsm
end

--- Convenience helper that runs the FSM every cycle.
--  Internally stores one FSM per robot/team.
--  @return boolean true when the rotation is finished
function M.process(robotId, team, point, mode)
    local key = robotId .. ":" .. team
    local fsm = instances[key]
    if not fsm then
        fsm = M.new(robotId, team, point, mode)
        instances[key] = fsm
    end

    fsm:update()

    if fsm:is_done() then
        instances[key] = nil
        return true
    end
    return false
end

return M
