-- Utilizar para cuando los enemigos tengan la pelota en su lado

local Robot = require("sysmickit.robot")
local FieldPerspective = require("sysmickit.fieldperspective")
local TDefendZone = require("tactics.TDefendZone")
local Defense221 = {}

Defense221.__index = Defense221

function Defense221.new(team_setting)
    local self = setmetatable({}, Defense221)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Id de robots del campo
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end

    -- Definir zonas --

    -- Defender zones
    local defensive_zones = FieldPerspective.get_defensive_zones(team_setting.play_side)
    self.defender_0_zone = defensive_zones[1]
    self.defender_1_zone  = defensive_zones[2]

    -- Midfielder zone 
    local midfielder_zones = FieldPerspective.get_midfield_zone()
    self.midfielder_0_zone = midfielder_zones[1]
    self.midfielder_1_zone = midfielder_zones[2]

    return self
end

function Defense221:process()
    -- Two defenders back
    TDefendZone.process(self.robots[1].id , self.team, self.defender_0_zone)
    TDefendZone.process(self.robots[2].id , self.team, self.defender_1_zone)
    -- Two Midfields
    TDefendZone.process(self.robots[3].id , self.team, self.midfielder_0_zone )
    TDefendZone.process(self.robots[4].id , self.team, self.midfielder_1_zone )
end

return Defense221
