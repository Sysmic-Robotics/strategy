local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")

local Move = {}

local DEFAULT_POSITION_THRESHOLD = 0.01

--- @param id number Robot id
--- @param team number Robot team
--- @param target table {x, y}
function Move.process(id, team, target)
    local state = Engine.get_robot_state(id,team)
    local dist = utils.distance(state, target)
    if dist <= DEFAULT_POSITION_THRESHOLD then
        return true
    end
    Engine.move_to(id, team, target)
    return false
end

return Move
