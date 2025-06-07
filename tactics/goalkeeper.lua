local api       = require("sysmickit.lua_api")
local move      = require("skills.move")
local aim       = require("skills.aim")
local clear     = require("skills.clear_ball")
local utils     = require("sysmickit.utils")

local Goalkeeper = {}
Goalkeeper.__index = Goalkeeper

function Goalkeeper.new()
    return setmetatable({ state = "guard" }, Goalkeeper)
end

function Goalkeeper:process(robotId, team)
    local ball = api.get_ball_state()
    if not ball then return end
    local goalX = team == 0 and -1.5 or 1.5
    local guardPos = { x = goalX, y = ball.y }

    if self.state == "guard" then
        move.move_to(robotId, team, guardPos)
        aim.process(robotId, team, ball, "fast")
        if utils.distance(guardPos, ball) < 0.3 then
            self.state = "clear"
            self.clearer = clear.new(team)
        end
    elseif self.state == "clear" then
        local done = self.clearer:process(robotId, team)
        if done then
            self.state = "guard"
        end
    end
end

return Goalkeeper
