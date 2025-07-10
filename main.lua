local PassAndShoot = require("plays.pass_and_shoot")
local api = require("sysmickit.lua_api")

-- Crear instancia de la play
local play = PassAndShoot.new()

-- Asignar dos robots manualmente como roles 0 y 1
-- Asegúrate de que estos robots estén activos en grSim
local assigned_roles = {
    [0] = 0,  -- id del robot que pasa
    [1] = 1   -- id del robot que recibe y dispara
}
play:assign_roles(assigned_roles)

-- Estado ficticio de juego (puedes modificar si tienes integración con game_state real)
local game_state = {
    team = 1,
    in_offense = true,
    aborted = false
}

function process()
    play:process(game_state)
end
