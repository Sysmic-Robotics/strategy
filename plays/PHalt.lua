local Engine = require("sysmickit.engine")

local PHalt = {}
PHalt.__index = PHalt

function PHalt.new()
    return setmetatable({}, PHalt)
end

function PHalt:assign_roles(roles) end -- Dummy, sin uso

function PHalt:is_done(game_state)
    return false  -- HALT es controlado por el árbitro
end

function PHalt:process(game_state)
    local team = game_state.team or 0
    for robot_id = 0, 5 do
        Engine.stop_robot(robot_id, team)
    end
end

return PHalt
