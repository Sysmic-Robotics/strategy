local FieldZones = require("sysmickit.fieldzones")

local FieldPerspective = {}

function FieldPerspective.get_midfield_zone()
    return {
            FieldZones.ZONE_1,
            FieldZones.ZONE_4
        }
end

function FieldPerspective.get_offensive_zones(side)
    if side == "left" then
        return {
            FieldZones.ZONE_2,
            FieldZones.ZONE_5
        }
    elseif side == "right" then
        return {
            FieldZones.ZONE_0,
            FieldZones.ZONE_3
        }
    end
end

function FieldPerspective.get_defensive_zones(side)
    if side == "left" then
        return {
            FieldZones.ZONE_0,
            FieldZones.ZONE_3
        }
    elseif side == "right" then
        return {
            FieldZones.ZONE_2,
            FieldZones.ZONE_5
        }
    end
end

return FieldPerspective