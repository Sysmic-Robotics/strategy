local engine = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local aim = require("skills.SAim")
local move = require("skills.SMove")

local M = {}


--- Mark an opponent more intelligently by staying between them and our goal,
-- slightly closer to the opponent and facing them.
-- @param robotId number Our robot's ID
-- @param team number Our team ID (0 or 1)
-- @param opponentId number The ID of the opponent to mark
-- @param alpha number Optional balance factor (0 = on goal, 1 = on opponent). Default 0.7
function M.process(robotId, team, opponentId)
    
    local alpha =  0.7  -- closer to opponent by default
    local opponent = engine.get_robot_state(opponentId, 1 - team)
    
    if not opponent or not opponent.active then return end
    

    -- Goal position based on team
    local goal = { x = -4.5, y = 0 }
    if team == 1 then 
        goal.x = 4.5 
        if opponent.x > 0 then
            alpha = 0.9

        elseif opponent.x < 0 then
            alpha = 0.5
        end
    else
        if opponent.x > 0 then
            alpha = 0.5

        elseif opponent.x < 0 then
            alpha = 0.9
        end

    end


    -- Weighted position: closer to the opponent
    local target = {
        x = goal.x * (1 - alpha) + opponent.x * alpha,
        y = goal.y * (1 - alpha) + opponent.y * alpha
    }

    -- Move and face the opponent
    move.process(robotId, team, target)
    engine.face_to(robotId, team, { x = opponent.x, y = opponent.y })
end

return M