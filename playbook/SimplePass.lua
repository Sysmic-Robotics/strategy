local Pass = require("tactics.TCoordinatedPass")
local Robot = require("sysmickit.robot")
local Engine = require("sysmickit.engine")
local Utils = require("sysmickit.utils")
local TMoveClearArea = require("tactics.TMoveToPass") -- ✅ Include the tactic

SimpleForwardPass = {}
SimpleForwardPass.__index = SimpleForwardPass

function SimpleForwardPass.new(team)
    local all_ids = {0, 1, 2, 3, 4, 5}
    local ball = Engine.get_ball_state()

    -- Sort robots by distance to ball
    local distances = {}
    for _, id in ipairs(all_ids) do
        local state = Engine.get_robot_state(id, team)
        distances[#distances + 1] = {
            id = id,
            dist = Utils.distance(state, ball)
        }
    end

    table.sort(distances, function(a, b)
        return a.dist < b.dist
    end)

    local passerId = distances[1].id
    local receiverId = distances[2].id

    -- Remaining robots become supporters
    local supportIds = {}
    for i = 3, #distances do
        table.insert(supportIds, distances[i].id)
    end

    -- Pass region ahead of passer
    local passerX = Engine.get_robot_state(passerId, team).x
    local passRegion = {
        x_min = passerX,
        x_max = 4.5 * (1 - 2 * team),
        y_min = -3,
        y_max = 3
    }

    -- Define region where support robots look for clear space
    local clearRegion = {
        x_min = passerX,
        x_max = 4.5 * (1 - 2 * team),
        y_min = -3,
        y_max = 3
    }

    -- Create support tactics for each support robot
    local supportTactics = {}
    for i = 1, #supportIds do
        supportTactics[i] = TMoveClearArea.new(supportIds[i], team, clearRegion)
    end

    return setmetatable({
        team = team,
        passerId = passerId,
        receiverId = receiverId,
        supportIds = supportIds,
        passTactic = Pass.new(passerId, receiverId, team, passRegion),
        supportTactics = supportTactics
    }, SimpleForwardPass)
end

function SimpleForwardPass:process()
    -- Process main pass
    local ready = self.passTactic:process()

    -- Process all support robots’ clear movement
    for _, tactic in ipairs(self.supportTactics) do
        tactic:process()
    end

    return ready
end

return SimpleForwardPass
