local Robot      = require("sysmickit.robot")

-- Ajusta esto al nombre real de tu archivo:
local TKickToGoal     = require("tactics.TKickToGoal")
local TCoordinatedPass= require("tactics.TCoordinatedPass")
local TClearBall      = require("tactics.TClearBall")    -- o "tactics.TClearBall" si renombraste el .lua
local TPressNearest     = require("tactics.TPressNearest") 
local TMarkZone      = require("tactics.TMarkZone") 

-- crea instancias y guárdalas
local pressTactic    = TPressNearest.new()
local passTactic     = TCoordinatedPass.new()
local clearTactic    = TClearBall.new({ x = 3, y = 3 })
local markTactic   = TMarkZone.new()

-- crea robots
local robot1 = Robot.new(0, 0)
local robot2 = Robot.new(0, 1)
-- ...

function process()

  --clearTactic:process(robot1.id, robot1.team) 
  --pressTactic:process(robot1.id, robot1.team,{x=0,y=0})
  markTactic:process(robot1.id, robot1.team, {x=0,y=0})


end
