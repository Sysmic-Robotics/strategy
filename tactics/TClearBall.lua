local SCapture = require("skills.SCaptureBall")
local SKick = require("skills.SPivotKick") -- Usa la skill moderna para disparo

local ClearBall = {}
ClearBall.__index = ClearBall

function ClearBall.new()
  return setmetatable({
    state = "capture"
  }, ClearBall)
end

--- Intenta capturar la pelota y despejarla a un punto seguro.
-- Retorna true cuando ambas acciones han sido completadas.
-- @param robot_id number
-- @param team number
-- @param safePoint table {x, y} - coordenada donde despejar
function ClearBall:process(robot_id, team, safePoint)
  if self.state == "capture" then
    local captured = SCapture.process(robot_id, team)
    if captured then
      self.state = "kick"
    end
    return false
  end

  if self.state == "kick" then
    local kicked = SKick.process(robot_id, team, safePoint)
    if kicked then
      self.state = "done"
      return true
    end
    return false
  end

  if self.state == "done" then
    return true
  end

  -- Si por alguna razón el estado es desconocido, reestablece
  self.state = "capture"
  return false
end

function ClearBall:reset()
  self.state = "capture"
end

function ClearBall:isDone()
  return self.state == "done"
end

return ClearBall