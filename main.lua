local MarkOpponents = require("plays.Defend3")

-- IDs de nuestros 3 robots y nuestro equipo
local markPlay = MarkOpponents.new({0,1}, 0)

function process()
  markPlay:process()
end
