local PBasic221Global = require("plays.PBasic221Global")
local attack = require("plays.PAttack")
-- Aquí podrías requerir más plays, como tu play ofensiva...

-- Estado global de juego (ejemplo)
local game_state = {
    team = 0,        -- 0 para azul, 1 para amarillo
    in_offense = false,
    in_defense = true,
    aborted = false,
}

-- Instanciar la play defensiva
local defensive_play = PBasic221Global.new(game_state.team)
-- Aquí puedes instanciar otras plays, por ejemplo:
local offensive_play = attack.new()

function process()
    if game_state.in_defense then
        print("[MAIN] Ejecutando play defensiva")
        local finished = defensive_play:process(game_state)
        if finished then
            print("[MAIN] ¡Cambiando a modo ofensivo!")
            game_state.in_offense = true
            game_state.in_defense = false
            -- Si tienes una play ofensiva, podrías inicializarla aquí
        end
    elseif game_state.in_offense then
        print("[MAIN] Modo ofensivo (aquí deberías ejecutar tu play ofensiva)")
        offensive_play:process(game_state)
        -- Si tu play ofensiva termina, podrías volver a defensa:
        if finished_offense then
            game_state.in_defense = true
            game_state.in_offense = false
        end
    end
end

