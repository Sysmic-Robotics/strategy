-- skills/dribble_to_point.lua
local api     = require("sysmickit.lua_api")
local utils   = require("sysmickit.utils")
local move    = require("skills.move")
local capture = require("skills.capture_ball")

local Dribble = {}
Dribble.__index = Dribble

--- Crea una nueva instancia de la skill dribble_to_point
function Dribble.new(target)
    local self = setmetatable({}, Dribble)
    self.state = "capture"
    self.target = target or { x = 0, y = 0 }
    return self
end

--- Ejecuta un paso de la skill
--- @param robotId number
--- @param team number
--- @return boolean true si terminó
function Dribble:process(robotId, team)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return false end

    if self.state == "capture" then
        local has_ball = capture.process(robotId, team, 10)
        if has_ball then
            self.state = "dribble"
        end
        return false

    elseif self.state == "dribble" then
        api.dribbler(robotId, team, 10)
        local arrived = move.move_to(robotId, team, self.target)
        if arrived then
            self.state = "capture"  -- reset
            return true
        end
        return false
    end

    return false
end

return Dribble
