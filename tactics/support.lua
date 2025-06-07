local api     = require("sysmickit.lua_api")
local dribble = require("skills.dribble_to_point")
local capture = require("skills.capture_ball")
local move    = require("skills.move")

local Support = {}
Support.__index = Support

function Support.new(target)
    return setmetatable({ target = target or { x = 0, y = 0 }, state = "move", drib = nil }, Support)
end

function Support:update_target(target)
    self.target = target
    if self.drib then
        self.drib.target = target
    end
end

function Support:process(robotId, team)
    local ball = api.get_ball_state()
    if not ball then return end
    if self.state == "move" then
        move.move_to(robotId, team, self.target)
        if api.get_robot_state(robotId, team) then
            if math.abs(api.get_robot_state(robotId, team).x - self.target.x) < 0.1 and
               math.abs(api.get_robot_state(robotId, team).y - self.target.y) < 0.1 then
                self.state = "capture"
            end
        end
    elseif self.state == "capture" then
        if not self.drib then
            self.drib = dribble.new(self.target)
        end
        local done = self.drib:process(robotId, team)
        if done then
            self.state = "move"
        end
    end
end

return Support
