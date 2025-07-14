-- tactics/TPressNearest.lua
-- Táctica que presiona/intercepta la bola con el robot más cercano

local Intercept = require("skills.intercept")

local PressNearest = {}
PressNearest.__index = PressNearest

--- Crea una nueva instancia de la táctica PressNearest.
function PressNearest.new()
  return setmetatable({}, PressNearest)
end

--- Ejecuta un paso de la táctica.
--- @param robot_id number ID del robot que presiona
--- @param team     number ID del equipo
--- @param ball     table  Estado de la pelota ({x, y})
--- @return boolean true cuando la táctica recupera la bola
function PressNearest:process(robot_id, team, ball)
  -- Llama a la skill Intercept hasta capturar la bola
  return Intercept.process(robot_id, team, ball)
end

return PressNearest
