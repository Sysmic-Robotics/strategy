-- skills/face_ball_while_move.lua
local api   = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local M = {}

local FaceMove = {}
FaceMove.__index = FaceMove

--- Crea una nueva instancia de la skill face_ball_while_move
function FaceMove.new(target)
    local self = setmetatable({}, FaceMove)
    self.target = target or { x = 0, y = 0 }
    return self
end

--- Mueve el robot al punto destino mientras mantiene la vista hacia la pelota
--- @param robotId number
--- @param team number
--- @return boolean true si llegó al destino
function FaceMove:process(robotId, team)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return false end

    -- Mover hacia el destino
    api.move_to(robotId, team, self.target)

    -- Apuntar hacia la pelota
    api.face_to(robotId, team, ball, 1.0, 0.0, 0.1)

    -- Verificar si llegó
    local dist = utils.distance(robot, self.target)
    return dist < 0.05
end

return FaceMove
