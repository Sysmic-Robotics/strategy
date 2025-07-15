local PBasic221 = require("plays.PBasic221")
local play = PBasic221.new(0) -- 0 para azul, o usa el team que corresponda

-- Dentro de tu loop principal:
play:process(game_state)

function process()
  play:process()
end

