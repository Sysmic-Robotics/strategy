-- File: skills/SQuickShot.lua
local api          = require("sysmickit.engine")
local Vector2D     = require("sysmickit.vector2D")
local SPivotAim    = require("skills.SPivotAim")
local SAim         = require("skills.SAim")
local SMoveDirect  = require("skills.SMoveDirect")

local M = {}

-- Distancia extra para empujar más allá de la bola (m)
local PUSH_DISTANCE = 0.4

--- Pivotea detrás de la bola, afina puntería, y empuja con chasis hacia target
-- @param robotId número del robot
-- @param teamId  número del equipo
-- @param target  {x:number, y:number} punto al cual queremos disparar
-- @return true si completó el quick‐shot (para que robot.lua elimine la instancia), false si aún sigue en curso
function M.process(robotId, teamId, target)
    -- 1) Pivot‐aim: posicionarse detrás de la bola alineado a target
    if SPivotAim.process(robotId, teamId, target) ~= "done" then
        return false
    end

    -- 2) Aim fino: girar justo apuntando al target
    if SAim.process(robotId, teamId, target) ~= "done" then
        return false
    end

    -- 3) Obtener posición de la bola
    local ball = api.get_ball_state()
    -- 4) Dirección normalizada de la bola al target
    local dir = Vector2D:sub(target, ball)
    local norm = Vector2D:normalized(dir)

    -- 5) Punto de empuje: un poco más allá de la bola
    local pushPoint = {
        x = ball.x + norm.x * PUSH_DISTANCE,
        y = ball.y + norm.y * PUSH_DISTANCE
    }

    -- 6) Empujar con movimiento directo
    SMoveDirect.process(robotId, teamId, pushPoint)

    -- 7) Skill completada
    return true
end

return M
