local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local FSM = require("sysmickit.fsm")

local M = {}

local DEFAULT_POSITION_THRESHOLD = 0.05

--- Creates an FSM that moves a robot to a given target.
--- @param robotId number
--- @param team number
--- @param target table {x, y}
--- @return FSM
function M.new(robotId, team, target)
    local fsm = FSM.new("move", "[SMoveDirect]", true)
    local used_threshold = DEFAULT_POSITION_THRESHOLD

    fsm:add_state("move", {
        update = function(self)
            local robot = api.get_robot_state(robotId, team)
            if not robot then return end

            local dist = utils.distance(robot, target)
            if dist <= used_threshold then
                self:change_state("done")
            else
                api.move_direct(robotId, team, target)
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

local fsm_instances = {}

--- Procesa el movimiento directo de un robot hacia un objetivo.
--- @param robotId number
--- @param team number
--- @param target table {x, y}
function M.process(robotId, team, target)
    local key = tostring(robotId) .. ":" .. tostring(team)
    if not fsm_instances[key] then
        fsm_instances[key] = M.new(robotId, team, target)
    end
    local fsm = fsm_instances[key]
    -- Actualiza el target si cambió
    if fsm.target ~= target then
        fsm = M.new(robotId, team, target)
        fsm_instances[key] = fsm
    end
    fsm:update()
    return fsm:is_done()
end

return M
