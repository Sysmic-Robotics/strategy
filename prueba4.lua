local PCoordinatedAttack = require("plays.PCoordinatedAttack")
local play = PCoordinatedAttack.new(0) -- tu equipo

play:process(game_state)
function process()
    play:process()
end
