local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local Vector2D = require("sysmickit.vector2D")
local FSM = require("sysmickit.fsm")

local SMove = require("skills.SMove")
local SAim = require("skills.SAim")
local SMoveDirect = require("skills.SMoveDirect")

local M = {}

local instances = {}

local SAFE_DISTANCE = 0.18

--- Creates a FSM that captures the ball using SMove, SAim, and SMoveDirect
--- @param robotId number
--- @param team number
--- @return FSM
function M.new(robotId, team)
    local fsm = FSM.new("approach", "[SCapture]", true)

    local move_fsm = nil
    local aim_fsm = nil
    local final_fsm = nil

    fsm:add_state("approach", {
        on_enter = function()
            local ball = api.get_ball_state()
            local robot = api.get_robot_state(robotId, team)
            if not robot or not ball then return end
            local robot_pos = Vector2D.new(robot.x, robot.y)
            local ball_pos = Vector2D.new(ball.x, ball.y)
            local dir = (robot_pos - ball_pos):normalized()
            local approach_point = ball_pos + dir * SAFE_DISTANCE
            move_fsm = SMove.new(robotId, team, approach_point)
        end,
        update = function(self)
            if move_fsm then move_fsm:update() end
            if move_fsm and move_fsm:is_done() then
                self:change_state("aim")
            end
        end
    })

    fsm:add_state("aim", {
        on_enter = function()
            local ball = api.get_ball_state()
            if not ball then return end
            aim_fsm = SAim.new(robotId, team, ball, "mid")
        end,
        update = function(self)
            if aim_fsm then aim_fsm:update() end
            if aim_fsm and aim_fsm:is_done() then
                self:change_state("final")
            end
        end
    })

    fsm:add_state("final", {
        on_enter = function()
            local ball = api.get_ball_state()
            if not ball then return end
            final_fsm = SMoveDirect.new(robotId, team, ball)
        end,
        update = function(self)
            api.dribbler(robotId, team, 10)
            if final_fsm then final_fsm:update() end
            local ball = api.get_ball_state()
            local robot = api.get_robot_state(robotId, team)
            if robot and ball and utils.has_captured_ball(robot, ball) then
                self:change_state("done")
            end
        end
    })

    fsm:add_state("done", {
        update = function()
            api.dribbler(robotId, team, 10)
        end
    })

    fsm:set_done_state("done")

    return fsm
end

--- Runs the capture ball FSM and returns true once done.
function M.process(robotId, team)
    local key = robotId .. ":" .. team
    local fsm = instances[key]
    if not fsm then
        fsm = M.new(robotId, team)
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
