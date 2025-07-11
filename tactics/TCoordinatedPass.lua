-- tactics/CoordinatedPass.lua
-- Pass the ball from a specific robot to another robot in a specific region
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
    print("[TCoordinatedPass] Procesando: passer = " .. passerId .. ", receiver = " .. receiverId)

    local ball     = api.get_ball_state()
    local passer   = api.get_robot_state(passerId, team)
    local receiver = api.get_robot_state(receiverId, team)

    if not ball or not passer or not receiver then
        print("[TCoordinatedPass] Faltan datos: ball = " .. tostring(ball ~= nil) ..
              ", passer = " .. tostring(passer ~= nil) ..
              ", receiver = " .. tostring(receiver ~= nil))
        return false
    end

    if self.state == "init" then
        print("[TCoordinatedPass] Estado: init")
        self.lastBallPos = { x = ball.x, y = ball.y }
        self.computedTarget = PassPointSolver.find_best_pass_point(
            ball, receiver, region, 0.25, 2.0, 15
        )
        if not self.computedTarget then
            print("[TCoordinatedPass] No se encontró punto válido, usando posición del receiver")
            self.computedTarget = {x = receiver.x , y= receiver.y}
            return false
        end
        print("[TCoordinatedPass] Punto de pase encontrado: x=" .. self.computedTarget.x .. ", y=" .. self.computedTarget.y)
        self.state = "prepare_pass"
        return false

    elseif self.state == "prepare_pass" then
        print("[TCoordinatedPass] Estado: prepare_pass")
        local ready = 0

        if SCapture.process(passerId, team) then
            print("[TCoordinatedPass] Passer capturó la pelota")
            if Saim.process(passerId, team, self.computedTarget) then
                print("[TCoordinatedPass] Passer está apuntando al objetivo")
                ready = ready + 1
            else
                print("[TCoordinatedPass] Passer no pudo apuntar al objetivo")
            end
        else
            print("[TCoordinatedPass] Passer no pudo capturar la pelota")
        end

        local receiver = api.get_robot_state(receiverId, team)
        if receiver then
            print(string.format("[TCoordinatedPass] Receiver pos actual: x=%.2f y=%.2f", receiver.x, receiver.y))
            print(string.format("[TCoordinatedPass] Receiver objetivo: x=%.2f y=%.2f", self.computedTarget.x, self.computedTarget.y))
        end

        if SMove.process(receiverId, team, self.computedTarget) then
            print("[TCoordinatedPass] Receiver llegó a la posición")
            if Saim.process(receiverId, team, ball) then
                print("[TCoordinatedPass] Receiver está apuntando hacia la pelota")
                ready = ready + 1
            else
                print("[TCoordinatedPass] Receiver no pudo apuntar hacia la pelota")
            end
        else
            print("[TCoordinatedPass] Receiver no se movió a la posición")
        end

        if ready >= 2 then
            print("[TCoordinatedPass] Listo para patear. Transición a 'kick'")
            self.state = "kick"
        end

        return false

    elseif self.state == "kick" then
        print("[TCoordinatedPass] Estado: kick")
        if kick.process(passerId, team,  self.computedTarget) then
            print("[TCoordinatedPass] Pase ejecutado con éxito")
            self.state = "receive"
        else
            print("[TCoordinatedPass] Aún no se ejecuta el pase")
        end
        return false

    elseif self.state == "receive" then
        print("[TCoordinatedPass] Estado: receive")
        return pass_receiver.process(receiverId, team)
    end

    return false
end

return CoordinatedPass
