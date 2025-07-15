-- tactics/TKickToGoal.lua
-- Make a robot aim and kick the ball directly toward the enemy goal

local Engine   = require("sysmickit.engine")
local Robot = require("sysmickit.robot")

local TKickToGoal = {}
TKickToGoal.__index = TKickToGoal

--- Create a new TKickToGoal tactic
--- @param robotId number The ID of the robot that will kick
--- @param team number The team the robot belongs to
function TKickToGoal.new(robotId, team)
    local kicker = Robot.new(robotId, team)

    return setmetatable({
        state = "init",
        kicker = kicker,
    }, TKickToGoal)
end

--- Run one step of this tactic
--- @return boolean true when this cycle is done
function TKickToGoal:process()
    local ball = Engine.get_ball_state()
    local kickerState = Engine.get_robot_state(self.kicker.id, self.kicker.team)

    -- Define the enemy goal position based on the team
    local goalX = (self.kicker.team == 1) and -4.5 or 4.5
    local goalY = 0
    local goalPoint = { x = goalX, y = goalY }

    if self.state == "init" then
        -- Pivot to face the goal
        if self.kicker:PivotAim(goalPoint) then
            self.state = "kick"
        end
        return false

    elseif self.state == "kick" then
        if self.kicker:KickToPoint(goalPoint) then
            return true
        end
        return false
    end

    return false
end

return TKickToGoal
