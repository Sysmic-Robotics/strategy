-- Asegúrate de ajustar los paths según tu estructura real
local PAttack = require("plays.PAttack")
local play = PAttack.new()

-- Asigna los roles de los robots que participarán (puedes cambiarlos a tus IDs)
play:assign_roles({[0]=0, [1]=1})

-- Este es tu "ciclo principal" que se llamará por el engine en cada frame
function base.process()
    -- Construye el game_state real. Modifica según tus necesidades de prueba:
    local game_state = {
        team = 0,           -- 0 para azul, 1 para amarillo (ajusta a tu equipo)
        in_offense = true,  -- Mantén true para probar ataques sin parar
        aborted = false,    -- Puedes poner en true si quieres cortar la jugada
    }

    -- Llama la play con el estado del juego
    play:process(game_state)
end
