local utils = require("sysmickit.utils")
local Engine = require("sysmickit.engine")

local OffensiveZonePlay = {}

function OffensiveZonePlay.run(robots, ball, team)
    local attack_x = (team == 0) and 3.5 or -3.5
    local support_x = (team == 0) and 2.2 or -2.2
    local y_positions = { 1.2, 0.6, 0, -0.6, -1.2 }
    local attack_positions = {
        {x = attack_x, y = y_positions[1]},
        {x = attack_x, y = y_positions[5]},
        {x = support_x, y = y_positions[2]},
        {x = support_x, y = y_positions[4]},
        {x = support_x, y = y_positions[3]}
    }
    local states = {}
    for i, r in ipairs(robots) do
        states[i] = r:GetState()
    end
    local closest = utils.get_closest_robot_to_point(states, ball)
    local arco = { x = (team == 0) and 4.5 or -4.5, y = 0 }

    for i, robot in ipairs(robots) do
        if i == closest then
            if utils.is_path_clear(states[i], arco, Engine.get_opponents(team), 0.25) then
                robot:KickToPoint(arco)
            else
                -- Busca pase avanzado
                local best_teammate = nil
                local best_score = -math.huge
                for j, pos in ipairs(attack_positions) do
                    if j ~= i then
                        local teammate_state = states[j]
                        local score = -utils.distance(teammate_state, arco)
                        if utils.is_path_clear(states[i], teammate_state, Engine.get_opponents(team), 0.18)
                            and score > best_score then
                            best_score = score
                            best_teammate = teammate_state
                        end
                    end
                end
                if best_teammate then
                    robot:KickToPoint(best_teammate)
                else
                    robot:CaptureBall()
                end
            end
        else
            robot:Move(attack_positions[i])
        end
    end
end

return OffensiveZonePlay
