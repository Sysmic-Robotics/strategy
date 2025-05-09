local api = require("sysmickit.lua_api")
local kick = require("skills.kick_to_point")
local move = require("skills.move")
local capture = require("skills.capture_ball")
local aim = require("skills.aim")
local utils = require("sysmickit.utils")
local pass_receiver = require("skills.pass_receiver")
local M = {}

-- Internal state
local state = "init"
local lastBallPos = { x = 0, y = 0 }
local kickFrameCounter = 0

--- Executes a coordinated pass where the passer prepares to receive and the receiver initiates the pass.
--- @param passerId number Robot who will receive the pass.
--- @param receiverId number Robot who has the ball and initiates the pass.
--- @param team number Team identifier.
--- @param passTarget table { x, y } Where the pass should go (usually the passer's position).
function M.pass(passerId, receiverId, team, passTarget)
    local ball = api.get_ball_state()
    local passer = api.get_robot_state(passerId, team)
    local receiver = api.get_robot_state(receiverId, team)
    if not ball or not passer or not receiver then return false end

    -- === INIT: Start pass logic ===
    if state == "init" then
        state = "prepare_pass"
        print("[Pass] Preparing coordinated pass.")
        lastBallPos = { x = ball.x, y = ball.y }
        kickFrameCounter = 0
        return false

    -- === PREPARE PASS: passer moves into position, receiver prepares to pass ===
    elseif state == "prepare_pass" then
        local passer_ready = move.move_to(passerId, team, passTarget)
        local ball_captured = capture.process(receiverId, team, 10)

        if passer_ready and ball_captured then
            state = "kick"
            print("[Pass] Both robots ready. Receiver will kick.")
        end
        return false

    -- === KICK: Receiver kicks ball to passer ===
    elseif state == "kick" then
        local kicked = kick.process(receiverId, team, passTarget)
        aim.process(passerId, team, ball, "mid")
        if kicked then
            print("[Pass] Ball kicked. Passer will intercept.")
            state = "receive"
        end

        return false


    -- === RECEIVE: Passer intercepts the pass ===
    elseif state == "receive" then
        pass_receiver.process(passerId, team)

        if utils.distance(ball, passer) < 0.12 then
            print("[Pass] Pass complete.")
            state = "done"
            return true
        end
        return false

    elseif state == "done" then
        return true
    end

    return false
end

return M
