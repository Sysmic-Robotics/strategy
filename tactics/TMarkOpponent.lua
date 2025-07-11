-- tactics/TMarkOpponent.lua
-- Táctica que marca a un oponente específico usando la skill SMarkOpponent

local SMarkOpponent = require("skills.SMarkOpponent")

local MarkOpponent = {}
MarkOpponent.__index = MarkOpponent

--- Crea una nueva instancia de la táctica MarkOpponent.
--- @param opponentId number ID del robot oponente a marcar
--- @param alpha      number Opcional balance (0 = en el arco, 1 = encima del oponente). Default 0.9
function MarkOpponent.new(opponentId, alpha)
  return setmetatable({
    opponentId = opponentId,
    alpha      = alpha or 0.9,
  }, MarkOpponent)
end

--- Ejecuta un paso de la táctica.
--- @param robot_id number Nuestro robot que marcara
--- @param team     number Nuestro equipo (0 o 1)
--- @return boolean siempre false (táctica continua)
function MarkOpponent:process(robot_id, team)
  -- Llama a la skill que mueve y orienta continuamente
  SMarkOpponent.process(robot_id, team, self.opponentId, self.alpha)
  return false
end

--- Reinicia la táctica (no mantiene estado interno).
function MarkOpponent:reset()
  -- nada que reiniciar
end

--- Indica si la táctica ha finalizado (siempre false para táctica persistente).
function MarkOpponent:isDone()
  return false
end

return MarkOpponent
