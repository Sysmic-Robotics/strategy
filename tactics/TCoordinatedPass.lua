-- tactics/CoordinatedPass.lua
-- Pass the ball from a specific robot to another robot in a specific region

local api     = require("sysmickit.engine")
local Robot   = require("sysmickit.robot")
local pass_receiver = require("skills.pass_receiver")
local PassPointSolver = require("AI.pass_point_solver")
local utils = require("sysmickit.utils")

local CoordinatedPass = {}
CoordinatedPass.__index = CoordinatedPass

--- Create a new pass tactic instance.
--- @param passerId number The ID of the passer robot
--- @param receiverId number The ID of the receiver robot
--- @param team number The team both robots belong to
--- @param region table Target pass region {x_min, x_max, y_min, y_max}
function CoordinatedPass.new(passerId, receiverId, team, region)
    local passer = Robot.new(passerId, team)
    local receiver = Robot.new(receiverId, team)

    return setmetatable({
        state = "init",
        lastBallPos = { x = 0, y = 0 },
        computedTarget = nil,
        passer = passer,
        receiver = receiver,
        region = region,
    }, CoordinatedPass)
end

--- Run one step of this pass tactic.
--- @return boolean true when this cycle is done
function CoordinatedPass:process()
    local ball = api.get_ball_state()
    local passerState = api.get_robot_state(self.passer.id, self.passer.team)
    local receiverState = api.get_robot_state(self.receiver.id, self.receiver.team)

    if not ball or not passerState or not receiverState then
        print("[Pass] Missing ball, passer, or receiver state.")
        return false
    end

    if self.state == "init" then
        self.lastBallPos = { x = ball.x, y = ball.y }
        self.computedTarget = PassPointSolver.find_best_pass_point(
            ball, receiverState, self.region, 0.25, 2.0, 15
        )

        if not self.computedTarget then
            print("[Pass] No valid target found in region")
            self.computedTarget = { x = receiverState.x, y = receiverState.y }
            return false
        end

        self.state = "prepare_pass"
        print(self.state)
        print("computedTarget: " .. self.computedTarget.x .. "," .. self.computedTarget.y)
        return false

    elseif self.state == "prepare_pass" then
        local ready = 0

        -- Cambiar por el pivot kick
        if self.passer:CaptureBall() then
            if self.passer:Aim(self.computedTarget) then
                ready = ready + 1
            end
        end

        if self.receiver:Move(self.computedTarget) then
            self.receiver:Aim(ball)
            ready = ready + 1
        end

        if ready >= 2 then
            self.state = "kick"
            print(self.state)
        end

        return false

    elseif self.state == "kick" then
        self.receiver:Aim(ball)
        if self.passer:KickToPoint(self.computedTarget) then
            self.state = "receive"
            print(self.state)
        end
        return false

    elseif self.state == "receive" then
        if utils.distance(passerState, ball) < (0.30) then
            if self.receiver:CaptureBall() then
                print("done")
                return true
            end
        else
            return self.receiver:ReceiveBall()
        end
    end

    return false
end

return CoordinatedPass
