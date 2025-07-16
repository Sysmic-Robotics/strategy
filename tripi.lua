local Robot = require("sysmickit.robot")
local robot = Robot.new(0,0)

function process()
    robot:PivotKick({x=0,y=0})
end