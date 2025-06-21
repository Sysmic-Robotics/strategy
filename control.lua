local SPivotKick = require("skills.SPivotKick")
local SCapture = require("skills.SCaptureBall")
local lua_api  = require("sysmickit.lua_api")
-- Create FSM instances

function process()
    local robot_id = 0
    local team     = 0
    local target   = { x = 0, y = 0 }  -- Example target: center of opponent goal
    -- Once captured, proceed to kick
    SPivotKick.process(robot_id, team, target)
    --send_velocity(0,0,0,0,0.1)
    --lua_api.dribbler(0,0,10)
end
