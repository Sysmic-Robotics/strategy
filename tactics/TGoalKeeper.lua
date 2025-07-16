local Engine = require("sysmickit.engine")
local Robot = require("sysmickit.robot")
local utils = require("sysmickit.utils")

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

-- Medidas del área chica (ajusta si cambian)
local SAFETY_MARGIN = 0.10  -- 10 cm de margen a cada borde
local AREA_X_MIN = { [-1] = -4.4 + SAFETY_MARGIN, [1] = 3.5 + SAFETY_MARGIN }
local AREA_X_MAX = { [-1] = -3.5 - SAFETY_MARGIN, [1] = 4.4 - SAFETY_MARGIN }
local AREA_Y_MIN = -1.0 + SAFETY_MARGIN
local AREA_Y_MAX =  1.0 - SAFETY_MARGIN

local function clamp(val, minv, maxv)
    return math.max(minv, math.min(maxv, val))
end

-- Intersección de la línea pelota-arco con el área del arquero (con margen)
local function intersection_with_area(team, ball)
    local side = (team == 0) and -1 or 1
    local x_min, x_max = AREA_X_MIN[side], AREA_X_MAX[side]
    local y_min, y_max = AREA_Y_MIN, AREA_Y_MAX
    local goal_x, goal_y = (team == 0) and -4.5 or 4.5, 0

    local bx, by = ball.x, ball.y
    local dx, dy = goal_x - bx, goal_y - by

    -- Parametriza la recta: ball + t*(goal-ball)
    local tx = (dx ~= 0) and ((side == -1 and x_max or x_min) - bx) / dx or 1e6
    local ty1 = (dy ~= 0) and (y_min - by) / dy or 1e6
    local ty2 = (dy ~= 0) and (y_max - by) / dy or 1e6

    local candidates = {}
    local function add_candidate(t)
        if t > 0 and t < 1.2 then
            local x = bx + t * dx
            local y = by + t * dy
            if x >= x_min and x <= x_max and y >= y_min and y <= y_max then
                table.insert(candidates, {x=x, y=y})
            end
        end
    end

    add_candidate(tx)
    add_candidate(ty1)
    add_candidate(ty2)

    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            return math.abs(a.x - goal_x) < math.abs(b.x - goal_x)
        end)
        return candidates[1]
    end

    return {x = clamp(bx, x_min, x_max), y = clamp(by, y_min, y_max)}
end

local function get_enemy_with_ball(team)
    local enemy_team = (team == 0) and 1 or 0
    for id = 0, 5 do
        local rob = Engine.get_robot_state(id, enemy_team)
        if rob and rob.active and utils.has_captured_ball(rob, Engine.get_ball_state()) then
            return rob
        end
    end
    return nil
end

-- Cuando el enemigo tiene la pelota, ¡que no se pegue al extremo!
-- Nos quedamos siempre a "safe_x" del arco (más cerca que el borde) sobre la línea de disparo
local function intersection_enemy_shot(team, enemy)
    local side = (team == 0) and -1 or 1
    local x_min, x_max = AREA_X_MIN[side], AREA_X_MAX[side]
    local y_min, y_max = AREA_Y_MIN, AREA_Y_MAX
    local goal_x, goal_y = (team == 0) and -4.5 or 4.5, 0

    local safe_x = (side == -1) and (x_max - 0.18) or (x_min + 0.18)  -- ¡Ajusta 0.18 según preferencia!
    local theta = enemy.theta or 0
    local aim_x = enemy.x + math.cos(theta) * 8
    local aim_y = enemy.y + math.sin(theta) * 8

    local ex, ey = enemy.x, enemy.y
    local dx, dy = aim_x - ex, aim_y - ey

    local t = (dx ~= 0) and (safe_x - ex) / dx or 1e6
    t = math.max(0, math.min(1, t))
    local inter_x = ex + t * dx
    local inter_y = ey + t * dy

    -- Clipa el y al rango permitido, y también el x
    return {
        x = clamp(inter_x, x_min, x_max),
        y = clamp(inter_y, y_min, y_max)
    }
end

function TGoalkeeper:process()
    local ball = Engine.get_ball_state()
    local pos = nil
    local enemy = get_enemy_with_ball(self.team)

    if enemy then
        pos = intersection_enemy_shot(self.team, enemy)
    else
        pos = intersection_with_area(self.team, ball)
    end

    if self.robot:MoveDirect(pos) then
        self.robot:Aim(ball)
    else
        self.robot:Aim(pos)
    end
    return false
end

return TGoalkeeper