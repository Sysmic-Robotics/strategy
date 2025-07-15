-- plays/DefensiveFormation.lua
-- Play de Defensa Completa que usa múltiples tácticas:
-- - MarkZone: Robots se posicionan en zonas defensivas
-- - InterceptBall: Robot más cercano intercepta la pelota
-- - ClearBall: Despeja la pelota cuando la captura
-- - MarkOpponent: Marca oponentes cercanos

local api             = require("sysmickit.engine")
local utils           = require("sysmickit.utils")
local TMarkZone       = require("tactics.TMarkZone")
local TInterceptBall  = require("tactics.TInterceptBall")
local TClearBall      = require("tactics.TClearBall")
local TMarkOpponent   = require("tactics.TMarkOpponent")

local DefensiveFormation = {}
DefensiveFormation.__index = DefensiveFormation

--- Constructor de la Play Defensiva
--- @param robotIds table Lista de IDs de nuestros robots
--- @param team number Nuestro ID de equipo (0 o 1)
--- @param defensiveZones table Array de puntos de zona para cada robot {{x,y}, {x,y}, ...}
--- @param safePoint table Punto seguro para despejar {x, y}
function DefensiveFormation.new(robotIds, team, defensiveZones, safePoint)
  local self = setmetatable({
    robotIds = robotIds,
    team = team,
    defensiveZones = defensiveZones or {
      {x = -1.5, y = 0.5},   -- zona defensiva robot 0
      {x = -1.5, y = -0.5},  -- zona defensiva robot 1
      {x = -2.0, y = 0},     -- zona defensiva robot 2
    },
    safePoint = safePoint or {x = -3, y = 0}, -- punto seguro para despejar
    markTactics = {},         -- tácticas de marcaje por zona
    interceptTactic = TInterceptBall.new(),
    clearTactic = TClearBall.new(),
    markOpponentTactics = {}, -- tácticas de marcaje de oponentes
    currentState = "zone_defense", -- estados: "zone_defense", "intercept", "clear"
    closestRobotIndex = 1,
  }, DefensiveFormation)

  -- Inicializar tácticas de marcaje de zona para cada robot
  for i = 1, #robotIds do
    self.markTactics[i] = TMarkZone.new()
    self.markOpponentTactics[i] = TMarkOpponent.new()
  end

  return self
end

--- Ejecuta un ciclo de la Play Defensiva
function DefensiveFormation:process()
  -- 1. Cachear estado de la pelota y robots
  local ball = api.get_ball_state()
  local ourRobots = {}
  
  -- Obtener posiciones de nuestros robots
  for i, robotId in ipairs(self.robotIds) do
    local robotState = api.get_robot_state(robotId, self.team)
    if robotState and robotState.active then
      ourRobots[i] = {id = robotId, x = robotState.x, y = robotState.y}
    end
  end

  -- 2. Determinar qué robot está más cerca de la pelota
  local closestDistance = math.huge
  for i, robot in ipairs(ourRobots) do
    local dist = utils.distance(robot, ball)
    if dist < closestDistance then
      closestDistance = dist
      self.closestRobotIndex = i
    end
  end

  -- 3. Ejecutar lógica defensiva según el estado
  if self.currentState == "zone_defense" then
    self:executeZoneDefense(ourRobots)
  elseif self.currentState == "intercept" then
    self:executeIntercept(ourRobots)
  elseif self.currentState == "clear" then
    self:executeClear(ourRobots)
  end

  return false  -- la Play corre continuamente
end

--- Ejecuta la defensa en zona
function DefensiveFormation:executeZoneDefense(ourRobots)
  local ball = api.get_ball_state()
  
  -- Si la pelota está muy cerca, cambiar a interceptar
  if utils.distance(ourRobots[self.closestRobotIndex], ball) < 0.8 then
    self.currentState = "intercept"
    self.interceptTactic:reset()
    return
  end

  -- Cada robot marca su zona asignada
  for i, robot in ipairs(ourRobots) do
    if i == self.closestRobotIndex then
      -- El robot más cercano también puede marcar oponentes cercanos
      local opponents = self:getClosestOpponents(1)
      if #opponents > 0 then
        self.markOpponentTactics[i]:process(robot.id, self.team, opponents[1])
      else
        -- Si no hay oponentes cercanos, marca su zona
        local zonePt = self.defensiveZones[i]
        self.markTactics[i]:process(robot.id, self.team, zonePt)
      end
    else
      -- Los otros robots marcan sus zonas defensivas
      local zonePt = self.defensiveZones[i]
      self.markTactics[i]:process(robot.id, self.team, zonePt)
    end
  end
end

--- Ejecuta la interceptación de la pelota
function DefensiveFormation:executeIntercept(ourRobots)
  local ball = api.get_ball_state()
  local closestRobot = ourRobots[self.closestRobotIndex]
  
  -- Intentar interceptar la pelota
  local intercepted = self.interceptTactic:process(closestRobot.id, self.team)
  
  if intercepted then
    -- Si interceptó, cambiar a despejar
    self.currentState = "clear"
    self.clearTactic:reset()
  else
    -- Si no interceptó y la pelota se alejó, volver a defensa en zona
    if utils.distance(closestRobot, ball) > 1.2 then
      self.currentState = "zone_defense"
    end
  end
end

--- Ejecuta el despeje de la pelota
function DefensiveFormation:executeClear(ourRobots)
  local closestRobot = ourRobots[self.closestRobotIndex]
  
  -- Intentar despejar la pelota
  local cleared = self.clearTactic:process(closestRobot.id, self.team, self.safePoint)
  
  if cleared then
    -- Si despejó exitosamente, volver a defensa en zona
    self.currentState = "zone_defense"
  end
end

--- Obtiene los oponentes más cercanos al balón
function DefensiveFormation:getClosestOpponents(count)
  local ball = api.get_ball_state()
  local opponents = {}
  local oppTeam = 1 - self.team

  -- Obtener todos los oponentes activos
  for oppId = 0, 5 do
    local st = api.get_robot_state(oppId, oppTeam)
    if st and st.active then
      table.insert(opponents, { id = oppId, x = st.x, y = st.y })
    end
  end

  -- Ordenar por distancia al balón
  table.sort(opponents, function(a, b)
    return utils.distance(a, ball) < utils.distance(b, ball)
  end)

  -- Retornar solo los más cercanos
  local result = {}
  for i = 1, math.min(count, #opponents) do
    result[i] = opponents[i].id
  end
  
  return result
end

--- Reinicia la Play para poder reutilizarla
function DefensiveFormation:reset()
  self.currentState = "zone_defense"
  self.interceptTactic:reset()
  self.clearTactic:reset()
  
  for i = 1, #self.robotIds do
    self.markTactics[i]:reset()
    self.markOpponentTactics[i]:reset()
  end
end

return DefensiveFormation 