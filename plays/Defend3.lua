-- plays/PMarkOpponents.lua
-- Play que asigna a tres de nuestros robots la tarea de marcar a los tres oponentes más cercanos al balón

local api            = require("sysmickit.engine")
local utils          = require("sysmickit.utils")
local TMarkOpponent  = require("tactics.TMarkOpponent")

local PMarkOpponents = {}
PMarkOpponents.__index = PMarkOpponents

--- Constructor de la Play
--- @param robotIds table Lista de IDs de nuestros robots que marcarán
--- @param team     number  Nuestro ID de equipo (0 o 1)
function PMarkOpponents.new(robotIds, team)
  local self = setmetatable({
    robotIds = robotIds,
    team     = team,
  }, PMarkOpponents)
  return self
end

--- Ejecuta un ciclo de la Play
function PMarkOpponents:process()
  -- 1. Cachear estado de la pelota
  local ball = api.get_ball_state()

  -- 2. Determinar equipo oponente
  local oppTeam = 1 - self.team

  -- 3. Leer y filtrar estados de todos los oponentes
  local opponents = {}
  local oppTeam   = 1 - self.team

  for oppId = 0, 5 do
    local st = api.get_robot_state(oppId, oppTeam)
    if st and st.active then
      table.insert(opponents, { id = oppId, x = st.x, y = st.y })
    end
  end

  -- 4. Ordenar rivales por distancia al balón
  table.sort(opponents, function(a, b)
    return utils.distance(a, ball) < utils.distance(b, ball)
  end)

  -- 5. Extraer solo los 3 más cercanos (o menos, si hay <3 activos)
  local n = math.min(3, #opponents)
  local closestOpponents = {}
  for i = 1, n do
    closestOpponents[i] = opponents[i].id
  end

  -- Ahora closestOpponents es un array con los IDs de los 3 rivales más cercanos
  -- Ejemplo de uso en la Play:
  for i, ourId in ipairs(self.robotIds) do
    if closestOpponents[i] then
      local oppId = closestOpponents[i]
      local tac   = TMarkOpponent.new(oppId)
      tac:process(ourId, self.team)
    end
  end


  return false  -- la Play corre continuamente
end

return PMarkOpponents
