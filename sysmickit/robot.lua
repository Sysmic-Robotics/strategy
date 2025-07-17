local SMove         = require("skills.SMove")
local SMoveDirect   = require("skills.SMoveDirect")
local SAim          = require("skills.SAim")
local SCapture      = require("skills.SCaptureBall")
local SKick         = require("skills.SKick")
local SPivotAim     = require("skills.SPivotAim")
local SPivotKick    = require("skills.SPivotKick")
local Intercept     = require("skills.intercept")
local SMark          = require("skills.SMark")
local PassReceiver  = require("skills.pass_receiver")
local KickToPoint   = require("skills.kick_to_point")
local SCircleAroundBall = require("skills.SCircleAroundBall")
local SDribbleMove = require("skills.SDribbleMove")
local SQuickShot = require("skills.SQuickShot")
local Engine = require("sysmickit.engine")
local ReceiveBall = require("skills.SBallReceive")
local Stop = require("skills.Stop")
local Robot = {}
Robot.__index = Robot

function Robot.new(id, team)
    local self = setmetatable({}, Robot)
    self.id = id
    self.team = team
    return self
end

function Robot:GetState()
    return Engine.get_robot_state(self.id, self.team)
end

function Robot:Move(target)
    return SMove.process(self.id, self.team, target)
end

function Robot:MoveDirect(target)
    return SMoveDirect.process(self.id, self.team, target)
end

function Robot:Aim(target)
    return SAim.process(self.id, self.team, target)
end

function Robot:CaptureBall()
    return SCapture.process(self.id, self.team)
end

function Robot:Kick()
    return SKick.process(self.id, self.team)
end

function Robot:PivotAim(target)
    return SPivotAim.process(self.id, self.team, target)
end

function Robot:PivotKick(target)
    return SPivotKick.process(self.id, self.team, target)
end

function Robot:Intercept(target)
    return Intercept.process(self.id, self.team, target)
end

function Robot:Mark(target)
    return SMark.process(self.id, self.team, target, 1 - self.team)
end
function Robot:PassReceiver()
    return PassReceiver.process(self.id, self.team)
end

function Robot:KickToPoint(target)
    return KickToPoint.process(self.id, self.team, target)
end


function Robot:SCircleAroundBall(direction)
    return SCircleAroundBall.process(self.id,self.team,direction)
end

function Robot:SDribbleMove(target)
    return SDribbleMove.process(self.id,self.team,target)
end

function Robot:SQuickShot(target)
    return SQuickShot.process(self.id,self.team,target)
end

function Robot:ReceiveBall()
    return ReceiveBall.process(self.id, self.team)
end

function Robot:Stop()
    Stop.process(self.id, self.team)
    return true
end

return Robot
