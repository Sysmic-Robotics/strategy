local Engine = require("sysmickit.engine")
local Robot = require("sysmickit.robot")

local TGoalkeeper = {}
TGoalkeeper.__index = TGoalkeeper

function TGoalkeeper.new(id, team)
    local keeper = Robot.new(id, team)

    return setmetatable({
        state = "guard",
        robot = keeper,
        team = team
    }, TGoalkeeper)
end


local function compute_intercept_position(team, ball)
    local x_pos = (team == 0) and -4.1 or 4.1  -- inside the box, but not at edge
    local y_clamped = math.max(-1.0, math.min(1.0, ball.y))  -- clamp y

    return { x = x_pos, y = y_clamped }
end

local function is_ball_in_goalie_area(team, ball)
    local x_min, x_max
    if team == 0 then
        x_min, x_max = -4.5, -3.5  -- Blue team goalie area
    else
        x_min, x_max = 3.5, 4.5    -- Yellow team goalie area
    end

    return ball.x >= x_min and ball.x <= x_max
       and ball.y >= -1.0 and ball.y <= 1.0
end

function TGoalkeeper:process()
    local ball = Engine.get_ball_state()
    local is_ball_inside = is_ball_in_goalie_area(self.team, ball)
    if not is_ball_inside then
        local pos = compute_intercept_position(self.team, ball)
        if self.robot:MoveDirect(pos) then
            self.robot:Aim(ball)
        else
            self.robot:Aim(pos)
        end
        return false
    else
        self.robot:PivotKick({x=0,y=0})
    end

    return false
end

return TGoalkeeper
