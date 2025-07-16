local Engine = require("sysmickit.engine")
local robot = require("sysmickit.robot")

local test_robot = robot.new(0,1)
function process()
    --send_velocity(0,1,1,0,0)
    test_robot:Move({x=0,y=0})
    
end