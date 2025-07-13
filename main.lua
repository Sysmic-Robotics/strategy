local TMarkOpponent = require("tactics.TMarkOpponent")
local Robot      = require("sysmickit.robot")
local markPlay = require("plays.Defend3")
local mark = markPlay.new({0,1,2},0)
local robot = Robot.new(0,0)
local robot2 = Robot.new(1,0)

function process()
  --robot:MarkOpponent(0)
  --mark:process(robot.id,robot.team)
  mark:process()

end
