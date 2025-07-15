-- plays/MatchDemo.lua

local PAttack = require("plays.PAttack")
local TGoalkeeper = require("tactics.TGoalkeeper")

local MatchDemo = {}
MatchDemo.__index = MatchDemo

function MatchDemo.new()
    local self = setmetatable({}, MatchDemo)
    self.attack_roles = { [0] = 0, [1] = 1 }      -- IDs de robots azules (team=0)
    self.play_attack = PAttack.new()
    self.play_attack:assign_roles(self.attack_roles)
    self.goalkeeper = TGoalkeeper.new()
    self.delay_frame = true
    return self
end

-- Puedes modificar el estado de juego aquí si quieres detectar goles/faltas/etc.
local game_state = {
    team = 0, -- blue
    in_offense = true,
    in_defense = false,
    aborted = false,
}

-- Rotación simple de roles azules tras cada play
local function swap_attack_roles(roles)
    roles[0], roles[1] = roles[1], roles[0]
    print(string.format("[PAttack] Swapped roles: [0] = %d, [1] = %d", roles[0], roles[1]))
end

function MatchDemo:process()
    if self.delay_frame then
        self.delay_frame = false
        return
    end

    -- Ejecuta la play de ataque azul (usa los dos robots azules)
    if self.play_attack:is_done(game_state) then
        swap_attack_roles(self.attack_roles)
        self.play_attack = PAttack.new()
        self.play_attack:assign_roles(self.attack_roles)
        self.delay_frame = true
    else
        self.play_attack:process(game_state)
    end

    -- Ejecuta SIEMPRE el arquero amarillo en paralelo (robot 0, team 1)
    self.goalkeeper:process(0, 1)
end

return MatchDemo
