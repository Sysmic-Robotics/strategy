local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local FSM = require("sysmickit.fsm")

local M = {}

local instances = {}

local DEFAULT_POSITION_THRESHOLD = 0.05

--- Creates an FSM that moves a robot to a given target.
--- @param robotId number
--- @param team number
--- @param target table {x, y}
--- @return FSM
function M.new(robotId, team, target)
    local fsm = FSM.new("move", "[SMove]", true)
    local used_threshold = DEFAULT_POSITION_THRESHOLD

    fsm:add_state("move", {
        on_enter = function()
            print(string.format("Robot %d: starting move to (%.2f, %.2f)", robotId, target.x, target.y))
        end,
        update = function(self)
            local robot = api.get_robot_state(robotId, team)
            if not robot then return end

            local dist = utils.distance(robot, target)
            if dist <= used_threshold then
                self:change_state("done")
            else
                api.move_to(robotId, team, target)
            end
        end
    })

    fsm:add_state("done", {
        on_enter = function()
            print(string.format("Robot %d reached target!", robotId))
        end,
        update = function(self)
            -- Terminal state; no further action
            local robot = api.get_robot_state(robotId, team)
            local dist = utils.distance(robot, target)
            if dist > used_threshold then
                self:change_state("move")
            end
        end
    })

    fsm:set_done_state("done")

    return fsm
end

--- Run the movement FSM every cycle.
--  Returns true when target is reached.
function M.process(robotId, team, target)
    local key = robotId .. ":" .. team
    local fsm = instances[key]
    if not fsm then
        fsm = M.new(robotId, team, target)
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
