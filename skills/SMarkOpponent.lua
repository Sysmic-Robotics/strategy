local engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")
local aim = require("skills.SAim")
local move = require("skills.SMove")

local M = {}

--- Mark an opponent by staying between them and our goal, facing the opponent.
--- process returns true when robot is at target and facing opponent, false otherwise.
function M.process(robotId, team, opponentId)
    -- Parametro para definir la fuerza con la que se marca
    local alpha = 0.7
    local opponent = engine.get_robot_state(opponentId, 1 - team)
    if not opponent or not opponent.active then return false end

    -- Goal position based on team
    local goal = { x = -4.5, y = 0 }
    if team == 1 then 
        goal.x = 4.5 
        alpha = opponent.x > 0 and 0.9 or 0.5
    else
        alpha = opponent.x > 0 and 0.5 or 0.9
    end

    -- Weighted position: closer to the opponent
    local target = {
        x = goal.x * (1 - alpha) + opponent.x * alpha,
        y = goal.y * (1 - alpha) + opponent.y * alpha
    }

    -- Move and face the opponent
    local at_position = move.process(robotId, team, target)
    -- Orientación simple: robot debe estar mirando al rival (usa SAim)
    local at_orientation = aim.process(robotId, team, opponent, "mid")

    if at_position and at_orientation then
        return true
    end
    return false
end

return M
