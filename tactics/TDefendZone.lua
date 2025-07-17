local Robot = require("sysmickit.robot")
local Engine = require("sysmickit.engine")
local FieldZones = require("sysmickit.fieldzones")

local TDefendZone = {}


function TDefendZone.process(id, team, zone)
    local robot = Robot.new(id, team)
    local ball = Engine.get_ball_state()

    local enemies_in_zone = FieldZones.get_enemy_in_zone(zone, WORLD:get_opponents())
    if FieldZones.is_in_zone(ball, zone) then
        robot:PivotKick({x=0,y=0})
    elseif #enemies_in_zone > 0 then
        robot:Mark(enemies_in_zone[1].id)
    else
        robot:Move(FieldZones.center_point_in_zone(zone))
    end
end


return TDefendZone
