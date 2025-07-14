local SMove = require("skills.SMove")
local kick_to_point = require("skills.kick_to_point")
local SCapture = require("skills.SCaptureBall")
local SAim = require("skills.SAim")
local Engine = require("sysmickit.engine")
local SBallReceive = require("skills.SBallReceive")
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

function Robot:CaptureBall()
    return SCapture.process(self.id, self.team)
end

function Robot:KickToPoint(target)
    return kick_to_point.process(self.id, self.team, target)
end

function Robot:Aim(target)
    return SAim.process(self.id, self.team, target)
end

function Robot:ReceiveBall()
    return SBallReceive.process(self.id, self.team)
end

return Robot
