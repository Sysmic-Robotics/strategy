
local Engine = require("sysmickit.engine")


local robotId = 0
local team = 0

function process()
    Engine.send_velocity(robotId, team, 2, 0 , 0)

end