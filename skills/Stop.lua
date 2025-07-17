local Engine = require("sysmickit.engine")

local stop = {}

function stop.process(id, team)
    Engine.send_velocity(id, team, 0, 0, 0)
end

return stop