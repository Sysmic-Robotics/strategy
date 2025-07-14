-- tactics/pass_through.lua
local api     = require("sysmickit.engine")
local kick    = require("skills.kick_to_point")
local SMove   = require("skills.SMove")
local SCapture = require("skills.SCaptureBall")
local aim     = require("skills.SAim")
local utils   = require("sysmickit.utils")
local pass_receiver = require("skills.pass_receiver")

local PassThrough = {}
PassThrough.__index = PassThrough

function PassThrough.new()
    return setmetatable({
        state = "init",
        through_target = nil,
    }, PassThrough)
end

--- Run the through pass logic
--- @param passerId number
--- @param receiverId number
--- @param team number
--- @param targetPoint table (Where the ball should go — lead point in front of receiver)
function PassThrough:process(passerId, receiverId, team, targetPoint)
    local ball     = api.get_ball_state()
    local passer   = api.get_robot_state(passerId, team)
    local receiver = api.get_robot_state(receiverId, team)
    if not ball or not passer or not receiver then
        return false
    end

    if self.state == "init" then
        self.through_target = targetPoint
        self.state = "prepare_pass"
        return false

    elseif self.state == "prepare_pass" then
        local passer_ready = SMove.process(passerId, team, passer) -- Stay near ball
        local receiver_ready = SCapture.process(receiverId, team, 5)

        local facing_ready = false
        if passer_ready then
            facing_ready = aim.process(passerId, team, targetPoint, "fast")
        end

        if facing_ready and receiver_ready then
            self.state = "kick"
        end
        return false

    elseif self.state == "kick" then
        local kicked = kick.process(passerId, team, self.through_target)
        if kicked then
            print("Pass sent to space for receiver.")
            self.state = "receive"
        end
        return false

    elseif self.state == "receive" then
        local received = pass_receiver.process(receiverId, team, self.through_target)
        return received
    end

    return false
end

return PassThrough
