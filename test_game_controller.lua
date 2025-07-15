local simple_pass = require("playbook.SimplePass")

local team = 0
local play = simple_pass.new(team)

function process()
    play:process()
end
