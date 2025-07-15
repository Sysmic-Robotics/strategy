local MatchDemo = require("plays.MatchDemo")

-- Posicionamiento inicial
grsim.teleport_robot(0, 0, -3.2, -0.5, 0)
grsim.teleport_robot(1, 0, -3.2,  0.5, 0)
grsim.teleport_robot(0, 1,  4.2, 0.0, 0)
grsim.teleport_ball(-3, -0.2)

local play = MatchDemo.new()

function process()
    play:process()
end
