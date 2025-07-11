local PAttack = require("plays.PAttack")

local game_state = {
    team = 0,
    in_offense = true,
    in_defense = false,
    aborted = false,
}

-- Lista de IDs fijos para esta prueba
local ids = {}
ids[1] = 0 -- striker
ids[2] = 1 -- support1
ids[3] = 2 -- support2

local function teleport_all()
    print("[Test] Teleportando robots y balón...")

    grsim.teleport_robot(ids[1], 0, 0, -0.5, 0)     -- striker
    grsim.teleport_robot(ids[2], 0, 0, 0.5, 0)      -- support1
    grsim.teleport_robot(ids[3], 0, -0.5, -1, 0)    -- support2
    grsim.teleport_ball(0, -0.2)
end

-- Inicializar posición
teleport_all()

-- Crear la play
local play = PAttack.new()
play:assign_roles({
    striker = ids[1],
    support1 = ids[2],
    support2 = ids[3],
})

local frame_count = 0
local delay_frames = 30
local play_terminada = false

function process()
    if play_terminada then
        return
    end

    if frame_count < delay_frames then
        frame_count = frame_count + 1
        return
    end

    if play:is_done(game_state) then
        print("[Test] Play finalizada. No se reiniciará (fin de prueba).")
        play_terminada = true
    else
        play:process(game_state)
    end
end

