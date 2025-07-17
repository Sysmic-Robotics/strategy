-- AttackFlank.lua (rutina simple de ataque por flancos)
local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.fieldzones")
local Engine = require("sysmickit.engine")

local AttackFlank = {}
AttackFlank.__index = AttackFlank

function AttackFlank.new(team_setting)
    local self = setmetatable({}, AttackFlank)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids  -- IDs de nuestros robots (sin arquero)
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, self.team)
    end
    return self
end

function AttackFlank:process()
    local ball = Engine.get_ball_state()
    if not ball then return end

    -- Detectar zona del flanco rival según el equipo
    local inFlank = false
    if self.team == 0 then
        inFlank = FieldZones.is_in_zone(ball, FieldZones.RIGHT_ABOVE) or 
                  FieldZones.is_in_zone(ball, FieldZones.RIGHT_BELOW)
    else
        inFlank = FieldZones.is_in_zone(ball, FieldZones.LEFT_ABOVE) or 
                  FieldZones.is_in_zone(ball, FieldZones.LEFT_BELOW)
    end

    if not inFlank then
        return  -- Salir si la pelota no está en el flanco enemigo
    end

    -- Seleccionar atacante (robot más cercano a la pelota)
    local minDist, attacker, support = math.huge, nil, nil
    for _, robot in ipairs(self.robots) do
        local state = robot:GetState()
        local dist = ((state.x - ball.x)^2 + (state.y - ball.y)^2)^0.5
        if dist < minDist then
            minDist, attacker = dist, robot
        end
    end
    -- Escoger otro robot como apoyo (el primero distinto del atacante)
    for _, robot in ipairs(self.robots) do
        if robot.id ~= attacker.id then
            support = robot
            break
        end
    end

    -- Posición de apoyo cerca del arco rival
    local goalX = (self.team == 0) and 4.5 or -4.5
    local supportPos = {x = goalX - 1.0 * ((self.team==0) and 1 or -1), y = 0} 
    -- p.ej. a 1 metro del arco, centro en y=0

    -- Mover apoyador al frente del arco rival
    if support then
        support:MoveDirect(supportPos)
    end

    -- Acciones del atacante
    if attacker then
        -- Capturar o controlar el balón
        attacker:CaptureBall()
        -- Hacer pase al apoyo
        if support then
            attacker:PivotKick(supportPos)
        end
    end

    -- Recepción y disparo por parte del apoyo
    if support then
        -- Intentar recibir el pase (interceptar el balón)
        if support:ReceiveBall() then
            -- Disparo a la portería rival (centro)
            local shotTarget = { x = goalX, y = 0 }
            support:PivotKick(shotTarget)
        end
    end
end

return AttackFlank
