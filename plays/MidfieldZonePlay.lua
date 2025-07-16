local utils = require("sysmickit.utils")
local Engine = require("sysmickit.engine")

local MidfieldZonePlay = {}

function MidfieldZonePlay.run(robots, ball, team)
    local positions = {
        {x =  0.0, y =  0.0},
        {x = -1.0, y =  0.7},
        {x = -1.0, y = -0.7},
        {x =  1.0, y =  0.7},
        {x =  1.0, y = -0.7}
    }

    -- Etiqueta cada posición con el número de camiseta (ID real)
    local states = {}
    for i, r in ipairs(robots) do
        states[r.id] = r:GetState()
    end
    local closest_id = utils.get_closest_robot_to_point(states, ball)

    -- Encuentra el índice correcto en el array
    local closest_index = nil
    for i, r in ipairs(robots) do
        if r.id == closest_id then
            closest_index = i
            break
        end
    end

    local forward = (team == 0) and 1 or -1

    for i, robot in ipairs(robots) do
        if i == closest_index then
            -- Lógica de pase de avance
            local best_teammate = nil
            local best_score = -math.huge
            for j, pos in ipairs(positions) do
                if j ~= i and (states[robots[j].id].x - states[robot.id].x) * forward > 0 then
                    local score = (states[robots[j].id].x - states[robot.id].x) * forward
                    if utils.is_path_clear(states[robot.id], states[robots[j].id], Engine.get_opponents(team), 0.18)
                        and score > best_score then
                        best_score = score
                        best_teammate = states[robots[j].id]
                    end
                end
            end
            if best_teammate then
                robot:KickToPoint(best_teammate)
            else
                robot:CaptureBall()
                -- Elige arriba o abajo aleatorio
                local y_target = (math.random() > 0.5) and 1.2 or -1.2

                -- Define punto de disparo hacia adelante (ajusta x según qué tan lejos quieres patear)
                local x_target = 2.0 * forward  -- avanza 2 metros hacia adelante

                local punto_libre = { x = x_target, y = y_target }
                robot:PivotKick(punto_libre)
            end
        else
            robot:Move(positions[i])
        end
    end
end

return MidfieldZonePlay
