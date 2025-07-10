-- PAttack.lua
local Play = require("sysmickit.play")
local TAttackDecision = require("tactics.TAttackDecision")
local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")

---@class PAttack : Play
local PAttack = Play.new("PAttack")

function PAttack:assign_roles()
    local ball = api.get_ball_state()
    local team = 1  -- Team atacante (asumimos 1)

    -- Obtener todos los robots activos del equipo atacante
    local robots = {}
    for id = 0, 7 do
        local r = api.get_robot_state(id, team)
        if r and r.active then
            table.insert(robots, r)
        end
    end

    -- Si no hay robots activos, no hacemos nada
    if #robots == 0 then return end

    -- Elegir el robot más cercano al balón como role 0 (quien decide disparar o pasar)
    local closest_id = utils.get_closest_robot_to_point(robots, ball)

    for _, robot in ipairs(robots) do
        local role = (robot.id == closest_id) and 0 or 1
        self:assign_role(robot.id, TAttackDecision.new(role, robot.id, team, robots, api.get_opponents_states()))
    end
end

return PAttack