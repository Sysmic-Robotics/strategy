print("Strategy script initialized")

local Selector = require("plays.play_selector")

local TEAM = 0

function process()
    Selector.process(TEAM)
end
