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
<<<<<<< HEAD
    play:process(game_state)
end
=======
    -- Prueba de skills, descomenta una por vez para testear
    --robot:PivotKick({x=0, y=0})
    -- robot:Move({x=1, y=1})
    --robot:MoveDirect({x=4, y=1})
    --robot:Aim({x=2, y=0})
    --robot:CaptureBall() 
    -- robot:Kick()
    --robot:PivotAim({x=0, y=0})
    -- robot:PivotKick({x=0, y=2})
    -- robot:Intercept({x=0, y=0})
    -- robot:Mark({id=1,team=1})
    -- robot:PassReceiver(0,0)
    -- robot:KickToPoint({x=3, y=0})
    --robot:SDribbleMove({x=0, y=0})
    --robot:SCircleAroundBall(1)
    robot:SQuickShot({x=0,y=0})
end
>>>>>>> 212ad081d3ac3038a0469ff3d16c4e17020ce63f
