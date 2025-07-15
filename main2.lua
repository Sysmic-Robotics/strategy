local PBasic221Global = require("plays.PBasic221")
local PCoordinatedAttack = require("plays.PCoordinatedAttack")

-- Estado global de juego (ejemplo)
local game_state = {
    team = 0,        -- 0 para azul, 1 para amarillo
    in_offense = false,
    in_defense = true,
    aborted = false,
}

-- Instanciar la play defensiva y ofensiva
local defensive_play = PBasic221Global.new(game_state.team)
local offensive_play = PCoordinatedAttack.new(game_state.team)

function process()
    if game_state.in_defense then
        print("[MAIN] Ejecutando play defensiva")
        local finished_defense = defensive_play:process(game_state)
        if finished_defense then
            print("[MAIN] ¡Cambiando a modo ofensivo!")
            game_state.in_offense = true
            game_state.in_defense = false
            -- Reinicia la ofensiva por si acaso
            offensive_play = PCoordinatedAttack.new(game_state.team)
        end
    elseif game_state.in_offense then
        print("[MAIN] Ejecutando play ofensiva")
        local finished_offense = offensive_play:process(game_state)
        if finished_offense then
            print("[MAIN] ¡Cambiando a modo defensivo!")
            game_state.in_defense = true
            game_state.in_offense = false
            -- Reinicia la defensiva por si acaso
            defensive_play = PBasic221Global.new(game_state.team)
        end
    end
end
