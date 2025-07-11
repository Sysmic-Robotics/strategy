local PAttack = require("plays.PAttack")

local game_state = {
    team = 0,
    in_offense = true,
    in_defense = false,
    aborted = false,
}

-- Lista de IDs fijos para esta prueba
local ids = {0, 1, 2}
local roles = {}

local function assign_current_roles()
    roles[ids[1]] = 0 -- striker
    roles[ids[2]] = 1 -- support1
    roles[ids[3]] = 1 -- support2
end

local function teleport_all()
    print("utilizando funcion puta")
    grsim.teleport_robot(ids[1], 0, 3.2, -0.3, 0)
    grsim.teleport_robot(ids[2], 0, -0.5, 1, 0)
    grsim.teleport_robot(ids[3], 0, -0.5, -1, 0)
    grsim.teleport_ball(3, -0.5)
end

-- Inicializar roles y posición
assign_current_roles()
teleport_all()

-- Crear la play
local play = PAttack.new()
play:assign_roles({
    striker = ids[1],
    support1 = ids[2],
    support2 = ids[3],
})

local frame_count = 0
local delay_frames = 10
local play_terminada = false

function process()
    -- Si la play terminó, no hacemos nada más
    if play_terminada then
        return
    end

    -- Delay inicial para evitar bugs por estado sin actualizar
    if frame_count < delay_frames then
        frame_count = frame_count + 1
        return
    end

    -- Ejecutar lógica de la play
    if play:is_done(game_state) then
        print("[Test] Play finalizada. No se reiniciará (fin de prueba).")
        play_terminada = true
    else
        play:process(game_state)
    end
end
