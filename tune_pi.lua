local PIDTuner = require("tools.tuner.pid_tuner")
local tuner = PIDTuner:new("vy", 0.016)

local Engine = require("sysmickit.engine")

function process()
    --tuner:tune(3, 0, 0.2)
    Engine.send_velocity(3,0,0,2.0,0)
end
