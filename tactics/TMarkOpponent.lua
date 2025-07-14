-- tactics/TMarkOpponent.lua
-- Táctica que marca a un oponente específico usando la skill SMarkOpponent
local engine        = require("sysmickit.lua_api")
local SMarkOpponent = require("skills.SMarkOpponent")

local MarkOpponent = {}
MarkOpponent.__index = MarkOpponent

--- Creates a new MarkOpponent tactic for a specific opponent.
-- @param opponentId number
function MarkOpponent.new(opponentId)
  return setmetatable({ opponentId = opponentId }, MarkOpponent)
end

function MarkOpponent:process(robotId, team)
  local robot = engine.get_robot_state(robotId, team)
  if not robot or not robot.active then return false end

  -- Determine alpha based on field half
  local alpha
  if team == 0 then
    alpha = robot.x > 0 and 0.5 or 0.9
  else
    alpha = robot.x > 0 and 0.9 or 0.5
  end

  -- Invoke atomic skill
  return SMarkOpponent.process(robotId, team, self.opponentId, alpha)
end

function MarkOpponent:reset() end
function MarkOpponent:isDone() return false end

return MarkOpponent
