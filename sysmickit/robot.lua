local SMove = require("skills.SMove")
local kick_to_point = require("skills.kick_to_point")
local SCapture = require("skills.SCaptureBall")
local Robot = {}
Robot.__index = Robot

function Robot.new(id, team)
    local self = setmetatable({}, Robot)
    self.id = id
    self.team = team
    return self
end

function Robot:Move(target)
    return SMove.process(self.id, self.team, target)
end

function Robot:CaptureBall()
    return SCapture.process(self.id, self.team)
end

function Robot:KickToPoint(target)
    kick_to_point.process(self.id, self.team, target)
end


return Robot
