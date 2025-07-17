-- Utilizar para cuando los enemigos tengan la pelota en su lado

local Robot = require("sysmickit.robot")
local FieldPerspective = require("sysmickit.fieldperspective")
local TDefendZone = require("tactics.TDefendZone")
local Attack_dumy = {}
local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local FieldZones = require("sysmickit.fieldzones")

Attack_dumy.__index = Attack_dumy

function Attack_dumy.new(team_setting)
    local self = setmetatable({}, Attack_dumy)
    self.team = team_setting.team
    self.team_setting = team_setting
    -- Número de atacantes configurables (1 o 2)
    
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Id de robots del campo
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end
    self.num_attackers = math.min(team_setting.num_attackers or 1, #self.robots)
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

function Attack_dumy:process()
    -- Fase de ataque: capturar y pivot kick para los primeros num_attackers robots
    for i = 1, self.num_attackers do
        local attacker = self.robots[i]
        local ball = WORLD:get_ball()
        local state = Engine.get_robot_state(attacker.id, self.team)
        if not utils.has_captured_ball(state, ball) then
            attacker:CaptureBall()
        else
            -- seleccionar punto central del arco contrario
            local enemy_goal_zone = (self.team_setting == "left") and FieldZones.GOALI_ZONE_RIGHT or FieldZones.GOALI_ZONE_LEFT
            local goal_point = FieldZones.center_point_in_zone(enemy_goal_zone)
            attacker:PivotKick(goal_point)
        end
    end
    -- Fase de marcaje: asignar oponentes restantes de manera round-robin
    local opponents = WORLD:get_opponents()
    local n_opps = #opponents
    if n_opps > 0 then
        for idx = self.num_attackers + 1, #self.robots do
            local marker = self.robots[idx]
            -- índice cíclico entre oponentes
            local opp = opponents[((idx - (self.num_attackers + 1)) % n_opps) + 1]
            marker:Mark(opp.id)
        end
    end
end

return Attack_dumy