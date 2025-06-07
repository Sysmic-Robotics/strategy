-- tactics/CoordinatedPass.lua
-- Pass the ball from a specific robot to a another robot in a specific region
local api     = require("sysmickit.lua_api")
local kick    = require("skills.kick_to_point")
local SMove    = require("skills.SMove")
local SCapture = require("skills.SCaptureBall")
local Saim     = require("skills.SAim")
local pass_receiver = require("skills.pass_receiver")
local PassPointSolver = require("AI.pass_point_solver")

local CoordinatedPass = {}
CoordinatedPass.__index = CoordinatedPass

--- Create a new pass tactic instance.
function CoordinatedPass.new()
    return setmetatable({
        state            = "init",
        lastBallPos      = { x = 0, y = 0 },
        computedTarget   = nil,
    }, CoordinatedPass)
end

--- Run one step of this pass tactic.
--- @param passerId number the robot that has the ball
--- @param receiverId number the robot that will receive the ball
--- @param team number
--- @param region table {x_min, x_max, y_min, y_max}
--- @return boolean true when this cycle is done
function CoordinatedPass:process(passerId, receiverId, team, region)
    local ball     = api.get_ball_state()
    local passer   = api.get_robot_state(passerId, team)
    local receiver = api.get_robot_state(receiverId, team)

    if not ball or not passer or not receiver then
        print("No receiver, ball or passer")
        return false
    end

    if self.state == "init" then
        self.lastBallPos = { x = ball.x, y = ball.y }
        self.computedTarget = PassPointSolver.find_best_pass_point(
            ball, receiver, region, 0.25, 2.0, 15
        )
        if not self.computedTarget then
            print("[Pass] No valid target found in region")
            self.computedTarget = {x = receiver.x , y= receiver.y}
            return false
        end
        self.state = "prepare_pass"
        return false

    -- The passer has the ball and is facing the target
    -- The receiver is in position and is facing the passer
    elseif self.state == "prepare_pass" then
        -- Passer: Capture the ball and aim to the pass target
        local ready = 0
        if SCapture.process(passerId, team) then
           if Saim.process(passerId, team, self.computedTarget, "slow") then
                ready = ready + 1
           end
        end
        -- Receiver: Capture the ball and aim to the ball
        if SMove.process(receiverId, team, self.computedTarget) then
            if Saim.process(receiverId, team, ball, "fast") then
                ready = ready + 1
            end
        end

        if ready >= 2 then
            self.state = "kick"
        end

        return false

    elseif self.state == "kick" then
        if kick.process(passerId, team,  self.computedTarget) then
            self.state = "receive"
        end
        return false

    elseif self.state == "receive" then
        return pass_receiver.process(receiverId, team)
    end

    return false
end

return CoordinatedPass
