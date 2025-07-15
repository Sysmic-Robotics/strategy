local FieldZones = {}

-- Each zone is a rectangle: { x_min, x_max, y_min, y_max }
FieldZones.LEFT_ABOVE = {
    {
        x_min = -3.5, x_max = -1.5,
        y_min = 0.0, y_max = 1.0
    },
    {
        x_min = -4.5, x_max = -1.5,
        y_min = 1.0, y_max = 3.0
    }
}


FieldZones.LEFT_BELOW = {
    {
        x_min = -3.5, x_max = -1.5,
        y_min = -1.0, y_max = 0.0
    },
    {
        x_min = -4.5, x_max = -1.5,
        y_min = -3.0, y_max = -1.0
    }
}


FieldZones.RIGHT_ABOVE = {
    {
        x_min = 1.5, x_max = 3.5,
        y_min = 0.0, y_max = 1.0
    },
    {
        x_min = 1.5, x_max = 4.5,
        y_min = 1.0, y_max = 3.0
    }
}


FieldZones.RIGHT_BELOW = {
    {
        x_min = 1.5, x_max = 3.5,
        y_min = -3.0, y_max = -1.0
    },
    {
        x_min = 3.5, x_max = 4.5,
        y_min = -3.0, y_max = -1.0
    }
}


FieldZones.MIDFIELD = {
    {
        x_min = -1.5, x_max = 1.5,
        y_min = -3.0,
        y_max = 3.0
    }
}


-- Utility: check if a point is in a zone (supports multi-rectangle zones)
function FieldZones.is_in_zone(point, zone)
    for _, rect in ipairs(zone) do
        if point.x >= rect.x_min and point.x <= rect.x_max and
           point.y >= rect.y_min and point.y <= rect.y_max then
            return true
        end
    end
    return false
end

-- Utility: get a random point within a zone (uniformly from one of its rectangles)
function FieldZones.random_point_in_zone(zone)
    local rect = zone[math.random(1, #zone)]
    return {
        x = math.random() * (rect.x_max - rect.x_min) + rect.x_min,
        y = math.random() * (rect.y_max - rect.y_min) + rect.y_min
    }
end


return FieldZones