-- tactics/clear_ball.lua
-- Despeja la pelota hacia un punto seguro tras interceptarla

local api       = require("sysmickit.engine")
local SCapture  = require("skills.SCaptureBall")
local SKick     = require("skills.kick_to_point")

local ClearBall = {}
ClearBall.__index = ClearBall

--- Crea una nueva instancia de la táctica ClearBall.
--- @param safePoint table {x, y} Punto al que despejar la bola
function ClearBall.new(safePoint)
  return setmetatable({
    state     = "capture",  -- estados: "capture" → "kick" → "done"
    safePoint = safePoint,
  }, ClearBall)
end

--- Ejecuta un paso de la táctica.
--- @param robot_id number ID del robot que hará el despeje
--- @param team     number ID del equipo
--- @return boolean true cuando la táctica ha finalizado
function ClearBall:process(robot_id, team)
  local ball = api.get_ball_state()

  if self.state == "capture" then
    -- intento de captura hasta tener la bola
    if SCapture.process(robot_id, team) then
      self.state = "kick"
    end
    return false

  elseif self.state == "kick" then
    -- despeje al punto seguro
    if SKick.process(robot_id, team, self.safePoint) then
      self.state = "done"
      return true
    end
    return false

  elseif self.state == "done" then
    return true
  end

  return false
end

return ClearBall
