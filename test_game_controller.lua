local Engine = require("sysmickit.engine")
local TCoordinatePass = require("tactics.TCoordinatedPass")

local id0 = 0
local id1 = 1
local pass = TCoordinatePass.new(id0, id1, 0, {x_min = 0, x_max = 3, y_min = -3, y_max = 3})
function process()
    if pass:process() then
        id0 = 1 - id0
        id1 = 1 - id1
        pass = TCoordinatePass.new(id0, id1 , 0, {x_min = 0, x_max = 3, y_min = -3, y_max = 3})
    end
end
