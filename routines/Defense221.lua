--local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.fieldzones")

local Defense221 = {}
Defense221.__index = Defense221

function Defense221.new(team_setting)
    local self = setmetatable({}, Defense221)
    self.team = team_setting.team
    self.robots = {}
    -- Esto itera por el largo de la lista
    for i = 0, #team_setting.robots_ids do
        table.insert(self.robots, Robot.new(i, team_setting.team))
    end
    self.done = false
    return self
end

-- Reaccionar con la pelota
-- Reaccionar con oponentes
-- Funcione en distintos lados 
-- El arquero debe estar definido por el lado

function Defense221:process()
    -- Defense right wing
    --local pos = FieldZones.random_point_in_zone(FieldZones.LEFT_ABOVE)
    self.robots[1]:Move({x=-1,y=-1}  )

    --- Defense left wing
    self.robots[2]:Move( {x=-1,y=1}  )

    if #self.robots > 3 then
        -- Midfield above
        self.robots[3]:Move( {x=0,y=-1}  )

    
    -- Midfield below
    self.robots[4]:Move( {x=0,y=1}  )

    -- Attacker
    self.robots[5]:Move( {x=1,y=0}  )

end

return Defense221