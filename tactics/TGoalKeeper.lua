local api = require("sysmickit.engine")
local Mark = require("skills.mark")
local move = require("skills.SMove")
local aim = require("skills.SAim")
local SCapture = require("skills.SCaptureBall")
local SPivotKick = require("skills.SPivotKick") -- Usamos la skill de kick fuerte

local TGoalkeeper = {}
TGoalkeeper.__index = TGoalkeeper

function TGoalkeeper.new()
    return setmetatable({
        state = "guard",
        cooldown = 0
    }, TGoalkeeper)
end

-- Parámetros para tu cancha (ajusta si cambian dimensiones)
local GOAL_X = { [0] = -4.5, [1] = 4.5 }
local AREA_X = { [0] = -3.5, [1] = 3.5 }
local Y_MAX = 0.45
local R_INTERCEPT = 1
local COOLDOWN_TICKS = 20  -- espera tras despeje
-- Define aquí a dónde quieres despejar (zona lateral)
local SAFE_CLEAR = { [0] = {x = -3.5, y = 1.0}, [1] = {x = 3.5, y = 1.0} }

function TGoalkeeper:process(robot_id, team)
    local ball = api.get_ball_state()
    
    local goalie_x = GOAL_X[team]
    local area_x = AREA_X[team]
    local safe_clear = SAFE_CLEAR[team]
    local target_y = math.max(math.min(ball.y, Y_MAX), -Y_MAX)
    local mark_point = { x = goalie_x, y = target_y }

    local dist_to_goal = math.abs(ball.x - goalie_x)
    local ball_vx = ball.vx or 0
    local ball_threat = (team == 0 and ball_vx > 0.2) or (team == 1 and ball_vx < -0.2)
    local must_intercept = dist_to_goal < R_INTERCEPT or (dist_to_goal < 1.0 and ball_threat)
    local ball_in_area = (team == 0 and ball.x > area_x and ball.x < goalie_x + 0.2)
                       or (team == 1 and ball.x < area_x and ball.x > goalie_x - 0.2)
    local ball_y_ok = math.abs(ball.y) <= Y_MAX

    if self.state == "guard" then
        if must_intercept then
            self.state = "capture"
        else
            Mark.process(robot_id, team, mark_point)
            aim.process(robot_id, team, ball, "mid")
        end
        return false
    end

    if self.state == "capture" then
        if SCapture.process(robot_id, team) then
            self.state = "clear"
        else
            -- Sale adelante para tapar
            local block_x = (team == 0) and (goalie_x + 0.3) or (goalie_x - 0.3)
            move.process(robot_id, team, {x=block_x, y=target_y})
            aim.process(robot_id, team, ball, "mid")
        end
        return false
    end

    if self.state == "clear" then
        if SPivotKick.process(robot_id, team, safe_clear) then
            self.cooldown = COOLDOWN_TICKS
            self.state = "wait"
        end
        return false
    end

    if self.state == "wait" then
        -- Espera breve y vuelve a guard solo si la pelota salió del área
        self.cooldown = self.cooldown - 1
        Mark.process(robot_id, team, mark_point)
        aim.process(robot_id, team, ball, "mid")
        if self.cooldown <= 0 and not ball_in_area then
            self.state = "guard"
        end
        return false
    end

    self.state = "guard"
    return false
end

function TGoalkeeper:reset()
    self.state = "guard"
    self.cooldown = 0
end

return TGoalkeeper
