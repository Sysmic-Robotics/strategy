-- plays/ZoneDefense.lua
-- Play de Defensa en Zona usando tácticas: PressNearest, MarkZone y ClearBall

local api             = require("sysmickit.lua_api")
local Robot           = require("sysmickit.robot")
local utils = require("sysmickit.utils")
local PressNearest    = require("tactics.TPressNearest")
local MarkZone        = require("tactics.TMarkZone")
local ClearBall       = require("tactics.TClearBall")

local ZoneDefense = {}
ZoneDefense.__index = ZoneDefense

function ZoneDefense.new(robotIds, team, zonePoints, safePoint)
  local self = setmetatable({
    team        = team,
    robots      = {},       -- objetos Robot
    markTacs    = {},       -- táctica MarkZone por robot
    zonePoints  = zonePoints,
    safePoint   = safePoint,
    pressTac    = PressNearest.new(),
    clearTac    = ClearBall.new(safePoint),
  }, ZoneDefense)

  for i, id in ipairs(robotIds) do
    self.robots[i] = Robot.new(id, team)
    self.markTacs[i] = MarkZone.new()
  end

  return self
end

function ZoneDefense:process()
  -- cachear una sola vez
  local ball  = api.get_ball_state()
  local poses = api.get_all_robots_positions()

  -- quién presiona
  local closestIdx = utils.get_closest_robot_to_point(poses, ball)

  for i, robot in ipairs(self.robots) do
    if i == closestIdx then
      -- 1) Presionar/interceptar
      if not self.pressTac:process(robot.id, self.team, ball) then
        -- continua presionando...
      -- 2) Despejar tras capturar
      elseif not self.clearTac:process(robot.id, self.team) then
        -- continua despejando...
      else
        -- reiniciar ambas
        self.pressTac:reset()
        self.clearTac:reset()
      end

    else
      -- marcar zona
      local zonePt = self.zonePoints[i]
      self.markTacs[i]:process(robot.id, self.team, zonePt)
    end
  end

  return false
end

return ZoneDefense
