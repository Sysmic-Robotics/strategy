local FieldZones = {}

-- Each zone is a rectangle: { x_min, x_max, y_min, y_max }
FieldZones.ZONE_0 = {
    {
        x_min = -3.5, x_max = -1.5,
        y_min = 0.0, y_max = 1.0
    },
    {
        x_min = -4.5, x_max = -1.5,
        y_min = 1.0, y_max = 3.0
    }
}

FieldZones.ZONE_1 = {
    {
        x_min = -1.5, x_max = 1.5,
        y_min = 0.0, y_max = 3.0
    }
}


FieldZones.ZONE_4 = {
    {
        x_min = -1.5, x_max = 1.5,
        y_min = -3.0, y_max = 0.0
    }
}

FieldZones.ZONE_2 = {
    {
        x_min = 1.5, x_max = 3.5,
        y_min = 0.0, y_max = 1.0
    },
    {
        x_min = 1.5, x_max = 4.5,
        y_min = 1.0, y_max = 3.0
    }
}



FieldZones.ZONE_3 = {
    {
        x_min = -3.5, x_max = -1.5,
        y_min = -1.0, y_max = 0.0
    },
    {
        x_min = -4.5, x_max = -1.5,
        y_min = -3.0, y_max = -1.0
    }
}




FieldZones.ZONE_5 = {
    {
        x_min = 1.5, x_max = 3.5,
        y_min = -3.0, y_max = -1.0
    },
    {
        x_min = 3.5, x_max = 4.5,
        y_min = -3.0, y_max = -1.0
    }
}

FieldZones.GOALI_ZONE_LEFT = {
    {
        x_min = -4.5, x_max = -3.5,
        y_min = -1.0, y_max = 1.0
    },
}


FieldZones.GOALI_ZONE_RIGHT = {
    {
        x_min = 3.5, x_max = 4.5,
        y_min = -1.0, y_max = 1.0
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

-- Utility: get the center point of the whole zone (bounding box center)
function FieldZones.center_point_in_zone(zone)
    local x_min, x_max = math.huge, -math.huge
    local y_min, y_max = math.huge, -math.huge

    for _, rect in ipairs(zone) do
        if rect.x_min < x_min then x_min = rect.x_min end
        if rect.x_max > x_max then x_max = rect.x_max end
        if rect.y_min < y_min then y_min = rect.y_min end
        if rect.y_max > y_max then y_max = rect.y_max end
    end
    local x = (x_min + x_max) / 2
    local y = (y_min + y_max) / 2
    return {
        x = (x_min + x_max) / 2,
        y = (y_min + y_max) / 2
    }
end


function FieldZones.get_enemy_in_zone(zone, enemies)
    assert(zone ~= nil, "Zone is nil")
    assert(type(zone) == "table", "Zone is not a table")
    local inside = {}
    for _, enemy in ipairs(enemies) do
        local point = { x = enemy.x, y = enemy.y }
        if FieldZones.is_in_zone(point, zone) then
            table.insert(inside, enemy)
        end
    end

    return inside
end

function FieldZones.get_robot_in_zone(zone, enemies)
    assert(zone ~= nil, "Zone is nil")
    assert(type(zone) == "table", "Zone is not a table")
    local inside = {}
    for _, enemy in ipairs(enemies) do
        local point = { x = enemy.x, y = enemy.y }
        if FieldZones.is_in_zone(point, zone) then
            table.insert(inside, enemy)
        end
    end

    return inside
end



return FieldZones