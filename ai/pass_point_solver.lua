-- pass_point_solver.lua
local utils = require("sysmickit.utils")
local api   = require("sysmickit.engine")

local PassPointSolver = {}

-- Configuration parameters
local MAX_ATTEMPTS = 4
local SAFE_RADIUS = 0.25 -- safety distance around obstacles

--- Compute the squared Euclidean distance
local function dist_sq(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    return dx * dx + dy * dy
end

--- Compute minimum distance from point to line segment AB
local function point_to_segment_distance(point, A, B)
    local dx, dy = B.x - A.x, B.y - A.y
    local length_sq = dx * dx + dy * dy
    if length_sq == 0 then return math.sqrt(dist_sq(point, A)) end

    local t = ((point.x - A.x) * dx + (point.y - A.y) * dy) / length_sq
    t = math.max(0, math.min(1, t))

    local proj = { x = A.x + t * dx, y = A.y + t * dy }
    return math.sqrt(dist_sq(point, proj))
end

--- Check if the line from ball to point is clear of obstacles
local function is_line_clear(ball, point, obstacles, safe_radius)
    for _, obs in ipairs(obstacles) do
        local dist = point_to_segment_distance(obs, ball, point)
        if dist < safe_radius then
            return false
        end
    end
    return true
end


--- Sample a random point within a rectangular region
--- @param region table {x_min=number, x_max=number, y_min=number, y_max=number}
--- @return table {x=number, y=number}
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
--- @return table? best point {x, y} or nil
function PassPointSolver.find_best_pass_point(ball, receiver, region, min_dist, max_dist, num_samples)
    local obstacles = api.get_all_robots_positions()

    local best_point = nil
    local best_score = math.huge
    local min_dist_sq = min_dist * min_dist
    local max_dist_sq = max_dist * max_dist

    for _ = 1, num_samples or MAX_ATTEMPTS do
        local candidate = sample_point_in_region(region)

        local d_sq = dist_sq(ball, candidate)

        if d_sq >= min_dist_sq and d_sq <= max_dist_sq and
           is_line_clear(ball, candidate, obstacles, SAFE_RADIUS) then

            local score = math.sqrt(dist_sq(candidate, receiver))
            if score < best_score then
                best_score = score
                best_point = candidate
            end
        end
    end
    if best_point == nil then
        return receiver
    end
    return best_point
end

return PassPointSolver
