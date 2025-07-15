--local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.FieldZones")



local Defense221 = {}
Defense221.__index = Defense221

function Defense221.new(team_setting)
    local self = setmetatable({}, Defense221)
    self.team = team_setting.team
    self.robots = {}
    for i = 1, #team_setting.robots_ids do
        table.insert(self.robots, Robot.new(i, team_setting.team))
    end
    self.done = false
    return self
end

local function get_random_defender_position(team)
    local x_min, x_max
    if team == 0 then
        x_min, x_max = -3.5, -2.5
    else
        x_min, x_max = 2.5, 3.5
    end

    local y_min, y_max = -1.5, 1.5

    return {
        x = utils.random_between(x_min, x_max),
        y = utils.random_between(y_min, y_max)
    }
end


function Defense221:process()
    -- Defense right wing
    --local pos = FieldZones.random_point_in_zone(FieldZones.LEFT_ABOVE)
    self.robots[1]:Move({x=0,y=0}  )

    --- Defense left wing
    --self.robots[2]:Move( FieldZones.random_point_in_zone(FieldZones.LEFT_BELOW) )
end

return Defense221