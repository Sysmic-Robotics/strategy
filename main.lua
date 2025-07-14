local TMarkOpponent = require("tactics.TMarkOpponent")
local Robot      = require("sysmickit.robot")
local markPlay = require("plays.Defend3")

--local PPass = require("plays.PPass")
--local play = PPass.new()

--local mark = markPlay.new({0,1},0)
local robot = Robot.new(0,0)
local robot2 = Robot.new(1,0)


--local TMarkZone = require("tactics.TMarkZone")
--local tmark = TMarkZone.new()

--local robot_id = 0
--local team = 0
--local zonePt = {x = 0, y = 0}


--local TInterceptBall = require("tactics.TInterceptBall")
--local tintercept = TInterceptBall.new()
local game_state = {
    team = 0,
    in_offense = true,
    in_defense = false,
    aborted = false,
}

local passer_id = 0
local passer_team = 0
local receiver_id = 1
local region = { x1 = 1.0, y1 = -0.5, x2 = 2.0, y2 = 0.5 }  -- zona objetivo

local TCoordinatedPass = require("tactics.TCoordinatedPass")
local coordinated_pass = TCoordinatedPass.new()

function process()
  --robot:MarkOpponent(0)
 -- mark:process(robot.id,robot.team)
  --mark:process()
  --robot:Intercept({x=3,y=-1})
  --robot:Mark({x=0,y=0})
  --tmark:process(robot_id, team, zonePt)
 -- tintercept:process(robot_id, team,{x=3,y=-1}) 
  --robot:PivotKick({x=2,y=0}) 
  -- game_state debe contener al menos .team y puede incluir más info
 -- play:process(game_state)
end

