local utils = require("sysmickit.utils")
local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.fieldzones")
local Engine = require("sysmickit.engine")

local Defense221 = {}
Defense221.__index = Defense221

function Defense221.new(team_setting)
    local self = setmetatable({}, Defense221)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Debe traer SOLO los 5 robots de campo (sin arquero)
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end
    self.done = false
    return self
end

function Defense221:process()
    local ball = Engine.get_ball_state()
    if not ball then return end


    -- ZONA DEFENSIVA
    if FieldZones.is_in_zone(ball, FieldZones.LEFT_ABOVE)
    or FieldZones.is_in_zone(ball, FieldZones.LEFT_BELOW) then
        local base_x = (self.team == 0) and -3.2 or 3.2
        local y_positions = {-1.2, -0.5, 0, 0.5, 1.2}

        -- Determina el más cercano al balón
        local states = {}
        for i, r in ipairs(self.robots) do
            states[i] = r:GetState()
        end
        local closest = utils.get_closest_robot_to_point(states, ball)

        for i, robot in ipairs(self.robots) do
            if i == closest then
                -- ¿Tiene la pelota capturada?
                local robot_state = states[i]
                if utils.has_captured_ball(robot_state, ball) then
                    -- Busca un área libre para despejar
                    local candidates = {
                        {x = 0.0, y = 0.0},      -- centro campo
                        {x = 1.5, y = 1.0},      -- medio arriba
                        {x = 1.5, y = -1.0},     -- medio abajo
                        {x = 2.0, y = 0.0},      -- más ofensivo
                    }
                    local best = candidates[1]
                    local max_dist = 0
                    -- Busca el más lejos de los rivales
                    local opponents = Engine.get_opponents(self.team)
                    for _, pt in ipairs(candidates) do
                        local min_dist = math.huge
                        for _, opp in ipairs(opponents) do
                            local d = utils.distance(pt, opp)
                            if d < min_dist then min_dist = d end
                        end
                        if min_dist > max_dist then
                            max_dist = min_dist
                            best = pt
                        end
                    end
                    robot:PivotKick(best)
                else
                    robot:CaptureBall()
                end
            else
                robot:Move({ x = base_x, y = y_positions[i] })
            end
        end
        return
    end



    -- MEDIOCAMPO
    if FieldZones.is_in_zone(ball, FieldZones.MIDFIELD) then
        local positions = {
            {x =  0.0, y =  0.0}, -- centro
            {x = -1.0, y =  0.7},
            {x = -1.0, y = -0.7},
            {x =  1.0, y =  0.7},
            {x =  1.0, y = -0.7}
        }

        local states = {}
        for i, r in ipairs(self.robots) do
            states[i] = r:GetState()
        end
        local closest = utils.get_closest_robot_to_point(states, ball)

        -- Define dirección de avance (X+ para azul, X- para amarillo)
        local forward = (self.team == 0) and 1 or -1

        for i, robot in ipairs(self.robots) do
            if i == closest then
                -- Busca un compañero más adelantado y con pase libre
                local best_teammate = nil
                local best_score = -math.huge
                for j, pos in ipairs(positions) do
                    if j ~= i then
                        -- Que esté más adelantado en X respecto al sentido de juego
                        if (states[j].x - states[i].x) * forward > 0 then
                            local score = (states[j].x - states[i].x) * forward
                            if utils.is_path_clear(states[i], states[j], Engine.get_opponents(self.team), 0.18)
                                and score > best_score then
                                best_score = score
                                best_teammate = states[j]
                            end
                        end
                    end
                end
                if best_teammate then
                    robot:PivotKick(best_teammate)
                else
                    robot:CaptureBall()
                end
            else
                robot:Move(positions[i])
            end
        end
        return
    end



-- ZONA OFENSIVA
    if FieldZones.is_in_zone(ball, FieldZones.RIGHT_ABOVE)
    or FieldZones.is_in_zone(ball, FieldZones.RIGHT_BELOW) then
        local attack_x = (self.team == 0) and 3.5 or -3.5
        local support_x = (self.team == 0) and 2.2 or -2.2
        local y_positions = { 1.2, 0.6, 0, -0.6, -1.2 }
        local attack_positions = {
            {x = attack_x, y = y_positions[1]},
            {x = attack_x, y = y_positions[5]},
            {x = support_x, y = y_positions[2]},
            {x = support_x, y = y_positions[4]},
            {x = support_x, y = y_positions[3]}
        }

        local states = {}
        for i, r in ipairs(self.robots) do
            states[i] = r:GetState()
        end
        local closest = utils.get_closest_robot_to_point(states, ball)

        -- Define posición del arco rival
        local arco = { x = (self.team == 0) and 4.5 or -4.5, y = 0 }

        for i, robot in ipairs(self.robots) do
            if i == closest then
                -- Si hay camino libre al arco, patea
                local path_clear = utils.is_path_clear(states[i], arco, Engine.get_opponents(self.team), 0.25)
                if path_clear then
                    robot:PivotKick(arco)
                else
                    -- Si no hay camino, busca un compañero desmarcado más cerca del arco
                    local best_teammate = nil
                    local best_score = -math.huge
                    for j, pos in ipairs(attack_positions) do
                        if j ~= i then
                            -- Chequea que el pase esté libre y que esté más cerca del arco
                            local teammate_state = states[j]
                            local score = -utils.distance(teammate_state, arco)
                            if utils.is_path_clear(states[i], teammate_state, Engine.get_opponents(self.team), 0.18)
                                and score > best_score then
                                best_score = score
                                best_teammate = teammate_state
                            end
                        end
                    end
                    if best_teammate then
                        robot:PivotKick(best_teammate)
                    else
                        -- Si no hay pase claro, intenta capturar/controlar la pelota
                        robot:CaptureBall()
                    end
                end
            else
                robot:Move(attack_positions[i])
            end
        end
        return
    end
end

return Defense221
