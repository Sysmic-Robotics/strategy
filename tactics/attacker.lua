local api     = require("sysmickit.lua_api")
local capture = require("skills.capture_ball")
local aim     = require("skills.aim")
local kick    = require("skills.kick_to_point")

local Attacker = {}
Attacker.__index = Attacker

function Attacker.new()
    return setmetatable({ state = "capture" }, Attacker)
end

function Attacker:process(robotId, team)
    local goal = team == 0 and { x = 1.4, y = 0 } or { x = -1.4, y = 0 }
    if self.state == "capture" then
        local has = capture.process(robotId, team, 10)
        if has then
            self.state = "aim"
        end
        return false
    elseif self.state == "aim" then
        local ready = aim.process(robotId, team, goal, "fast")
        if ready then
            self.state = "kick"
        end
        return false
    elseif self.state == "kick" then
        local done = kick.process(robotId, team, goal)
        if done then
            self.state = "capture"
            return true
        end
        return false
    end
    return false
end

return Attacker
