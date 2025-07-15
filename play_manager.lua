local ForwardPass = require("playbook.ForwardPass")

local forward = ForwardPass.new(0)
function process()
    forward:process()
end