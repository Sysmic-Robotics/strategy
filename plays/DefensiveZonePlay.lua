local utils = require("sysmickit.utils")
local Engine = require("sysmickit.engine")
local FieldZones = require("sysmickit.fieldzones")
local DefensiveZonePlay = {}

function DefensiveZonePlay.run(robots, ball, team)
    local base_x = (team == 0) and -3.2 or 3.2
    local y_positions = {-1.2, -0.5, 0, 0.5, 1.2}

    -- Arma states como diccionario por ID real
    local states = {}
    for i, r in ipairs(robots) do
        states[r.id] = r:GetState()
    end
    local closest_id = utils.get_closest_robot_to_point(states, ball)

    -- Encuentra índice en array de robots con ese ID
    local closest_index = nil
    for i, r in ipairs(robots) do
        if r.id == closest_id then
            closest_index = i
            break
        end
    end

    for i, robot in ipairs(robots) do
        if i == closest_index then
            if robot:CaptureBall() then
                local point = FieldZones.random_point_in_zone(FieldZones.MIDFIELD)
                robot:KickToPoint(point)
                return
            end
        else
            robot:Move({ x = base_x, y = y_positions[i] })
        end
    end
end

return DefensiveZonePlay

