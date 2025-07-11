local Robot = require("sysmickit.robot")
local robot1 = Robot.new(0, 0)
local robot2 = Robot.new(1, 0)
local robot3 = Robot.new(2, 0)
local play1 = require("tactics.TKickToGoal")
local play2 = require("tactics.TCoordinatedPass")
local play3 = require("tactics.TClearBall")
play1.new()
play2.new()
play3.new({x=3,y=3})
local PASS_REGION = {
    x_min = 0,
    x_max = 4.5,
    y_min = -3.0,
    y_max = 3.0
}
function process()
    play3:process(robot1.id, robot1.team)
    --play2:process(robot1.id,robot2.id,robot1.team,PASS_REGION)



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
    --robot:SQuickShot({x=0,y=0})
    --robot:SCircularAim({x=0,y=0})
end