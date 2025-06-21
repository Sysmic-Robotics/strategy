local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local Vector2D = require("sysmickit.vector2D")
local FSM = require("sysmickit.fsm")

local SMove = require("skills.SMove")
local SAim = require("skills.SAim")
local SMoveDirect = require("skills.SMoveDirect")

local M = {}

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
        update = function(self)
            local ball = api.get_ball_state()
            local robot = api.get_robot_state(robotId, team)
            local robot_pos = Vector2D.new(robot.x, robot.y)
            local ball_pos = Vector2D.new(ball.x, ball.y)
            local dir = (robot_pos - ball_pos):normalized()
            local approach_point = ball_pos + dir * SAFE_DISTANCE
            move_fsm = SMove.new(robotId, team, approach_point)
            if move_fsm then move_fsm:update() end
            if move_fsm and move_fsm:is_done() then
                self:change_state("aim")
            end
        end
    })

    fsm:add_state("aim", {
        update = function(self)
            local ball = api.get_ball_state()
            aim_fsm = SAim.new(robotId, team, ball, "mid")
            if aim_fsm then aim_fsm:update() end
            if aim_fsm and aim_fsm:is_done() then
                self:change_state("final")
            end
        end
    })

    fsm:add_state("final", {
        update = function(self)
            local ball = api.get_ball_state()
            final_fsm = SMoveDirect.new(robotId, team, ball)
            api.dribbler(robotId, team, 10)
            if final_fsm then final_fsm:update() end
            local ball = api.get_ball_state()
            local robot = api.get_robot_state(robotId, team)
            if utils.has_captured_ball(robot, ball) then
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

return M
