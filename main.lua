local Robot = require("sysmickit.robot")
local robot = Robot.new(0, 0)

function process()
    -- Prueba de skills, descomenta una por vez para testear
    robot:PivotKick({x=3, y=1})
    -- robot:Move({x=1, y=1})
    -- robot:MoveDirect({x=1, y=1})
    -- robot:Aim({x=2, y=0})
    -- robot:CaptureBall() then
    -- robot:Kick()
    -- robot:PivotAim({x=0, y=2})
    -- robot:PivotKick({x=0, y=2})
    -- robot:Intercept({x=0, y=0})
    -- robot:Mark({id=1,team=1})
    -- robot:PassReceiver(0,0)
    -- robot:KickToPoint({x=3, y=0})
end