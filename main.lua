local Robot = require("sysmickit.robot")
local robot = Robot.new(0, 0)

function process()
    -- Prueba de skills, descomenta una por vez para testear
    --robot:PivotKick({x=0, y=0})
    -- robot:Move({x=1, y=1})
    --robot:MoveDirect({x=4, y=1})
    --robot:Aim({x=2, y=0})
    --robot:CaptureBall() 
    -- robot:Kick()
    --robot:PivotAim({x=0, y=0})
    -- robot:PivotKick({x=0, y=2})
    -- robot:Intercept({x=0, y=0})
    -- robot:Mark({id=1,team=1})
    -- robot:PassReceiver(0,0)
    -- robot:KickToPoint({x=3, y=0})
    --robot:SDribbleMove({x=0, y=0})
    --robot:SCircleAroundBall(1)
    robot:SQuickShot({x=0,y=0})
end