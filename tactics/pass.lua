-- tactics/pass.lua
local api     = require("sysmickit.lua_api")
local kick    = require("skills.kick_to_point")
local move    = require("skills.move")
local capture = require("skills.capture_ball")
local aim     = require("skills.aim")
local utils   = require("sysmickit.utils")
local pass_receiver = require("skills.pass_receiver")

local Pass = {}
Pass.__index = Pass

--- Create a new pass tactic instance.
--- @return Pass
function Pass.new()
    return setmetatable({
        state            = "init",
        lastBallPos      = { x = 0, y = 0 },
    }, Pass)
end

--- Run one step of this pass tactic.
--- @param passerId number
--- @param receiverId number
--- @param team number
--- @param passTarget table { x, y }
--- @return boolean true when this cycle is done
function Pass:process(passerId, receiverId, team, passTarget)
    local ball     = api.get_ball_state()
    local passer   = api.get_robot_state(passerId, team)
    local receiver = api.get_robot_state(receiverId, team)
    if not ball or not passer or not receiver then
        return false
    end

    if self.state == "init" then
        self.state            = "prepare_pass"
        self.lastBallPos      = { x = ball.x, y = ball.y }
        return false

    elseif self.state == "prepare_pass" then
        local in_position = move.move_to(passerId, team, passTarget)
        local ready2 = capture.process(receiverId, team, 10)
        local ready1 = false
        if in_position then
            ready1 = aim.process(passerId, team, ball, "fast")
        end
        if ready1 and ready2 then
            self.state = "kick"
        end
        return false

    elseif self.state == "kick" then
        
        local kicked = kick.process(receiverId, team, passer)
        if kicked then
            print("Preparing receive")
            self.state = "receive"
        end
        return false

    elseif self.state == "receive" then
        local pass_received = pass_receiver.process(passerId, team)
        return pass_received
    end

    return false
end

return Pass
