local Robot = require("sysmickit.robot")

local robot = Robot.new(0,0)
function process()
    --robot:Move({x=0,y=0})
    --robot:KickToPoint({x=0,y=0})
    robot:CaptureBall()
end