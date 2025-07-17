local Engine = require("sysmickit.engine")

local World = {}
World.__index = World

function World.new(team)
    assert(team == "blue" or team == "yellow", "Team must be 'blue' or 'yellow'")
    local self = setmetatable({}, World)
    self.team = team
    self.blue_team = {}
    self.yellow_team = {}
    self.ball = {}
    return self
end

function World:get_allies()
    if self.team == "blue" then
        return self.blue_team
    else
        return self.yellow_team
    end
end

function World:get_opponents()
    if self.team == "blue" then
        return self.yellow_team
    else
        return self.blue_team
    end
end

function World:get_ball()
    return self.ball
end

function World:process()
    self.blue_team = Engine.get_blue_team_state()
    self.yellow_team = Engine.get_yellow_team_state()
    self.ball = Engine.get_ball_state()
end

return World
