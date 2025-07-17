-- Utilizar para cuando los enemigos tengan la pelota en su lado

local Robot = require("sysmickit.robot")
local FieldPerspective = require("sysmickit.fieldperspective")
local FieldZones = require("sysmickit.fieldzones")
local TDefendZone = require("tactics.TDefendZone")
local TheirKickOff = {}

TheirKickOff.__index = TheirKickOff

function TheirKickOff.new(team_setting)
    local self = setmetatable({}, TheirKickOff)
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
    -- Generar posiciones aleatorias de defensa para cada robot
    local defensive_zones = FieldPerspective.get_defensive_zones(team_setting.play_side)
    self.positions = {}
    for i=1, #self.robots do
        -- alternar entre zonas defensivas
        local zone = defensive_zones[((i-1) % #defensive_zones) + 1]
        self.positions[i] = FieldZones.random_point_in_zone(zone)
    end

    return self
end

function TheirKickOff:process()
    for i, robot in ipairs(self.robots) do
        robot:Move(self.positions[i])
    end
end

return TheirKickOff