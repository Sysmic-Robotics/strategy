local Engine           = require("sysmickit.engine")
local utils            = require("sysmickit.utils")
local TGoalkeeper      = require("tactics.TGoalkeeper")
local SCaptureBall     = require("skills.SCaptureBall")
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
    self.tactics_def       = {}
    for i=1, #DEF_ZONES do
        self.tactics_def[i] = TMarkZone.new()
    end
    self.capture_tactic = SCaptureBall  -- SCaptureBall es stateless, no necesita .new()
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

    -- 6. El atacante intenta capturar la pelota
    if captured then
        print("[PBasic221Global] ¡Pelota capturada por el robot", attacker_id, "!")
        if game_state then
            game_state.in_offense = true
            game_state.in_defense = false
            game_state.aborted = false
        end
        self.done = true
    end

    -- 7. Defensores: cubrir zonas (asigna a los primeros N defenders)
    for i=1, math.min(#defenders, #DEF_ZONES) do
        self.tactics_def[i]:process(defenders[i], self.team, DEF_ZONES[i])
    end

    return self.done
end

return PBasic221Global


