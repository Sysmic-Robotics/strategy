local Engine = require("sysmickit.engine")

local RoleSelection = {}

--- Assigns roles dynamically based on ball proximity (offense)
--- @param team number team id
--- @param robots table list of all robot IDs in the team
--- @param goalie_id number ID of the goalie robot
--- @return table roles mapped like { [0] = goalie, [1] = closestToBall, ... }
function RoleSelection.assign_by_proximity_to_ball(team, robots, goalie_id)
    local ball = Engine.get_ball_state()
    if not ball then return {} end

    -- Remove goalie from list
    local others = {}
    for _, id in ipairs(robots) do
        if id ~= goalie_id then
            table.insert(others, id)
        end
    end

    -- Sort others by distance to ball
    table.sort(others, function(a, b)
        local ra = Engine.get_robot_state(a, team)
        local rb = Engine.get_robot_state(b, team)
        if not ra or not rb then return false end

        local da = math.sqrt((ra.x - ball.x)^2 + (ra.y - ball.y)^2)
        local db = math.sqrt((rb.x - ball.x)^2 + (rb.y - ball.y)^2)
        return da < db
    end)

    -- Assign roles
    local roles = { [0] = goalie_id }
    for i = 1, math.min(6, #others) do
        roles[i] = others[i]
    end

    return roles
end

return RoleSelection
