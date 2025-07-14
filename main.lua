local PIDTuner = require("tools.tuner.pid_tuner")
local tuner = PIDTuner:new("vy", 0.016)

-- ID y equipo del robot
local id = 0
local team = 0
local vel_ref = 0.2
function process()
    tuner:tune(id, team, vel_ref)
end

