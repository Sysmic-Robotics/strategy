local Robot = require("sysmickit.robot")

local RKickoffWait = {}
RKickoffWait.__index = RKickoffWait

function RKickoffWait.new(team_setting)
    local self = setmetatable({}, RKickoffWait)
    self.team = team_setting.team
    self.robots_ids = team_setting.robots_ids
    self.play_side = team_setting.play_side or "left"
    self.robots = {}
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, self.team)
    end
    return self
end

function RKickoffWait:assign_roles(roles) end

function RKickoffWait:is_done(game_state)
    return false
end

function RKickoffWait:process()
    -- El primer robot es el kicker, lo ponemos justo detrás de la pelota
    local kicker_pos = {x = -0.09, y = 0}
    if self.play_side == "right" then
        kicker_pos.x = -kicker_pos.x
    end
    if self.robots[1] then
        self.robots[1]:MoveDirect(kicker_pos)
    end

    -- El resto se ubica en línea, fuera del círculo, en tu mitad
    local positions = {
        {x = -1.5, y =  0.7},
        {x = -1.5, y =  0.35},
        {x = -1.5, y = -0.35},
        {x = -1.5, y = -0.7},
    }
    if self.play_side == "right" then
        for i, pos in ipairs(positions) do
            pos.x = -pos.x
        end
    end

    for i = 2, #self.robots do
        if positions[i-1] then
            self.robots[i]:MoveDirect(positions[i-1])
        end
    end
end

return RKickoffWait
