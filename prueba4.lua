local PCoordinatedAttack = require("plays.PCoordinatedAttack")

local TEAM_SETTING = {
    team  = 0,   -- 0 = azul (ataca derecha), 1 = amarillo (ataca izquierda)
    goalkeeper_id = 0, -- si tienes un arquero separado
    robots_ids = {1,2,3,4,5},
    play_side = "left" --left para atacar derecha (x=4.5), "right" para atacar izquierda (x=-4.5)
}

-- Instancia global de la play
local play = PCoordinatedAttack.new(TEAM_SETTING)

function process()
    -- Ejecuta la play de ataque:
    local finished = play:process()
    if finished then
        -- Reinicializa la play cuando termina
        play = PCoordinatedAttack.new(TEAM_SETTING)
    end
end


