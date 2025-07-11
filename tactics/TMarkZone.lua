-- tactics/TMarkZone.lua
-- Táctica que mantiene al robot dentro de una zona (punto de cobertura)

local Mark = require("skills.mark")

local MarkZone = {}
MarkZone.__index = MarkZone

--- Crea una nueva instancia de la táctica MarkZone.
function MarkZone.new()
  return setmetatable({
    -- estado único, pues Mark.process retorna true al llegar
    done = false,
  }, MarkZone)
end

--- Ejecuta un paso de la táctica.
--- @param robot_id number ID del robot que marca
--- @param team     number ID del equipo
--- @param zonePt   table  Punto de cobertura {x, y}
--- @return boolean true cuando el robot alcanza la zona
function MarkZone:process(robot_id, team, zonePt)
  -- Llamamos directamente al skill Mark, que devuelve true al llegar al punto
  local arrived = Mark.process(robot_id, team, zonePt)  -- :contentReference[oaicite:0]{index=0}
  if arrived then
    self.done = true
  end
  return arrived
end

--- Reinicia la táctica para poder reutilizarla.
function MarkZone:reset()
  self.done = false
end

--- Indica si la táctica finalizó.
function MarkZone:isDone()
  return self.done
end

return MarkZone
