-- pass_point_solver_attack.lua
local utils = require("sysmickit.utils")
local api   = require("sysmickit.engine")

local PassPointSolver = {}

local MAX_ATTEMPTS = 7
local SAFE_RADIUS = 0.25
local ADVANCE_ZONE = 1.2

local function dist_sq(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    return dx * dx + dy * dy
end

local function point_to_segment_distance(point, A, B)
    local dx, dy = B.x - A.x, B.y - A.y
    local length_sq = dx * dx + dy * dy
    if length_sq == 0 then return math.sqrt(dist_sq(point, A)) end
    local t = ((point.x - A.x) * dx + (point.y - A.y) * dy) / length_sq
    t = math.max(0, math.min(1, t))
    local proj = { x = A.x + t * dx, y = A.y + t * dy }
    return math.sqrt(dist_sq(point, proj))
end

local function is_line_clear(ball, point, obstacles, safe_radius)
    for _, obs in ipairs(obstacles) do
        local dist = point_to_segment_distance(obs, ball, point)
        if dist < safe_radius then
            return false
        end
    end
    return true
end

local function sample_point_in_region(region)
    return {
        x = utils.random_between(region.x_min, region.x_max),
        y = utils.random_between(region.y_min, region.y_max)
    }
end

--- Main solver function
--- @param ball table {x, y}
--- @param receiver table {x, y}
--- @param region table {x_min, x_max, y_min, y_max}
--- @param min_dist number
--- @param max_dist number
--- @param num_samples number
--- @param team number (0=blue, 1=yellow)
--- @param play_side string ("left" o "right")
--- @return table? best point {x, y} or nil
function PassPointSolver.find_best_pass_point(ball, receiver, region, min_dist, max_dist, num_samples, team, play_side)
    play_side = play_side or "right"
    local obstacles = api.get_all_robots_positions()

    local best_point = nil
    local best_score = math.huge
    local min_dist_sq = min_dist * min_dist
    local max_dist_sq = max_dist * max_dist

    -- NUEVO: Dirección de avance según lado de juego
    local direction = (play_side == "right") and 1 or -1
    local kicker_x = ball.x

    local goal_x = (play_side == "right") and 4.5 or -4.5
    local dist_to_goal = math.abs(ball.x - goal_x)
    local restrict_forward = dist_to_goal > ADVANCE_ZONE

    for _ = 1, num_samples or MAX_ATTEMPTS do
        local candidate = sample_point_in_region(region)
        local d_sq = dist_sq(ball, candidate)

        -- Solo filtrar avance si estamos lejos del arco
        if restrict_forward then
            if direction * (candidate.x - kicker_x) < 0 then
                goto continue
            end
        end

        if d_sq >= min_dist_sq and d_sq <= max_dist_sq and
           is_line_clear(ball, candidate, obstacles, SAFE_RADIUS) then

            local score = math.sqrt(dist_sq(candidate, receiver))
            if score < best_score then
                best_score = score
                best_point = candidate
            end
        end
        ::continue::
    end
    if best_point == nil then
        return receiver
    end
    return best_point
end

return PassPointSolver
