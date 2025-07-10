-- Tactic: TAttackDecision.lua
-- Decide whether to shoot at goal or pass to a teammate based on obstacle-free path

local TAttackDecision = {}
TAttackDecision.__index = TAttackDecision

local api = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local Vector2D = require("sysmickit.vector2D")

-- Define goal position (center of opponent goal)
local GOAL_POS = { x = 4.5, y = 0 }

-- Placeholder: obstacle check (replace later with more robust check)
local function is_path_clear(from_pos, to_pos, opponents)
    local EPSILON = 0.2 -- minimum clearance from obstacle
    for _, opp in pairs(opponents) do
        local opp_pos = Vector2D.new(opp.x, opp.y)
        local a = Vector2D.new(from_pos.x, from_pos.y)
        local b = Vector2D.new(to_pos.x, to_pos.y)
        local ab = b - a
        local ap = opp_pos - a
        local t = math.max(0, math.min(1, ap:dot(ab) / ab:length_squared()))
        local closest = a + ab * t
        if (closest - opp_pos):length() < EPSILON then
            return false
        end
    end
    return true
end

function TAttackDecision.new(role, robotId, teamId, all_allies, all_opponents)
    local self = setmetatable({}, TAttackDecision)
    self.role = role
    self.id = robotId
    self.team = teamId
    self.allies = all_allies
    self.opponents = all_opponents
    return self
end

function TAttackDecision:execute()
    local me = api.get_robot_state(self.id, self.team)
    local ball = api.get_ball_state()

    -- Check if we have the ball
    if not utils.has_captured_ball(me, ball) then
        return
    end

    -- Attempt direct shot
    if utils.is_ready_to_kick(me, ball, GOAL_POS)
        and is_path_clear(ball, GOAL_POS, self.opponents) then
        api.kickx(self.id, self.team)
        return
    end

    -- Else: find best receiver
    local min_dist = math.huge
    local receiver_id = nil
    for id, ally in pairs(self.allies) do
        if id ~= self.id then
            if is_path_clear(ball, ally, self.opponents) then
                local dist = utils.distance(ball, ally)
                if dist < min_dist then
                    min_dist = dist
                    receiver_id = id
                end
            end
        end
    end

    if receiver_id then
        api.kickx(self.id, self.team)
        -- Optional: send signal to receiver (not implemented yet)
    else
        api.dribbler(self.id, self.team, 5.0)
    end
end

return TAttackDecision