-- File: plays/PBasic221Global.lua
local Engine           = require("sysmickit.engine")
local utils            = require("sysmickit.utils")
local TGoalkeeper      = require("tactics.TGoalkeeper")
local TKickToGoal      = require("tactics.TKickToGoal")
local TCoordinatedPass = require("tactics.TCoordinatedPass2")
local TMarkZone        = require("tactics.TMarkZone")

local PBasic221Global = {}
PBasic221Global.__index = PBasic221Global

-- Zonas defensivas (ajusta según tu cancha/lado si quieres)
local DEF_ZONES = {
    {x = -1.5, y = 2.0},
    {x = -1.5, y = 1.0},
    {x = -1.5, y = 0.0},
    {x = -1.5, y = -1.0},
    {x = -1.5, y = -2.0},
}

function PBasic221Global.new(team)
    local self = setmetatable({}, PBasic221Global)
    self.team = team or 0
    self.tactic_goalkeeper = TGoalkeeper.new()
    self.tactic_attack     = TKickToGoal.new()
    self.tactic_pass       = TCoordinatedPass.new()
    self.tactics_def       = {}
    for i=1, #DEF_ZONES do
        self.tactics_def[i] = TMarkZone.new()
    end
    self.done = false
    return self
end

function PBasic221Global:process(game_state)
    -- 1. Arquero (ID 0 siempre)
    self.tactic_goalkeeper:process(0, self.team)

    -- 2. Robots activos de campo (IDs 1–5)
    local robots = {}
    local active_ids = {}
    for id = 1, 5 do
        local rob = Engine.get_robot_state(id, self.team)
        if rob and rob.active then
            table.insert(robots, rob)
            table.insert(active_ids, id)
        end
    end

    -- 3. Pelota
    local ball = Engine.get_ball_state()
    if not ball then return false end
    if #robots == 0 then
        print("[PBasic221Global] No robots activos en campo!")
        return false
    end

    -- 4. ¿Quién es el atacante? (más cercano a la pelota)
    local closestIdx = utils.get_closest_robot_to_point(robots, ball)
    if not closestIdx then
        print("[PBasic221Global] No se pudo encontrar atacante.")
        return false
    end
    local attacker_id = active_ids[closestIdx]
    if not attacker_id then
        print("[PBasic221Global] attacker_id nil!")
        return false
    end

    -- 5. Defensores = todos menos el atacante
    local defenders = {}
    for _, id in ipairs(active_ids) do
        if id ~= attacker_id then table.insert(defenders, id) end
    end

    -- 6. Ataque: ¿disparar o pasar?
    local attacker = Engine.get_robot_state(attacker_id, self.team)
    local dist_to_ball = utils.distance(attacker, ball)
    local can_shoot = dist_to_ball < 1.0 -- Puedes ajustar este umbral
    local shot_done = false

    print("[PBasic221Global] Atacante:", attacker_id, "Distancia a balón:", dist_to_ball, "Defensores:", table.concat(defenders, ", "))

    if can_shoot or #defenders == 0 then
        -- Dispara al arco
        print("[PBasic221Global] Atacante", attacker_id, "intenta disparar")
        shot_done = self.tactic_attack:process(attacker_id, self.team)
    else
        -- Busca receptor válido (el más adelantado en y, o el primero que esté activo)
        local receiver_id = nil
        local max_y = -math.huge
        for _, id in ipairs(defenders) do
            local mate = Engine.get_robot_state(id, self.team)
            if mate and mate.active and mate.y > max_y then
                receiver_id = id
                max_y = mate.y
            end
        end
        if receiver_id then
            print("[PBasic221Global] Atacante", attacker_id, "pasa a", receiver_id)
            self.tactic_pass:process(attacker_id, self.team, receiver_id)
        else
            print("[PBasic221Global] No hay receptor válido, atacante intenta disparar")
            shot_done = self.tactic_attack:process(attacker_id, self.team)
        end
    end

    -- 7. Defensores: cubrir zonas (asigna a los primeros N defenders)
    for i=1, math.min(#defenders, #DEF_ZONES) do
        self.tactics_def[i]:process(defenders[i], self.team, DEF_ZONES[i])
    end

    -- 8. Termina si hubo disparo (opcional)
    if shot_done then self.done = true end
    return self.done
end

return PBasic221Global

