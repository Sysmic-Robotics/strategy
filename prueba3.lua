local TGoalkeeper = require("tactics.TGoalkeeper")
local Engine      = require("sysmickit.engine")

local team = 0        -- Cambia a 1 si juegas de amarillo
local goalie_id = 0   -- ID de tu arquero

local keeper = TGoalkeeper.new(goalie_id, team)

function process()
    keeper:process()
end
