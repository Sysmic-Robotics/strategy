-- tactics/TAttackDecision.lua
-- Decide whether to shoot or pass based on obstacle-free path

local api   = require("sysmickit.lua_api")
local utils = require("sysmickit.utils")
local Vector2D = require("sysmickit.vector2D")
local kick  = require("skills.kick_to_point")
local aim   = require("skills.SAim")
local capture = require("skills.SCaptureBall")

local TAttackDecision = {}
TAttackDecision.__index = TAttackDecision

local GOAL_POS = { x = 4.5, y = 0 }

local function is_path_clear(from_pos, to_pos, opponents)
    local EPSILON = 0.2
    local a = Vector2D.new(from_pos.x, from_pos.y)
    local b = Vector2D.new(to_pos.x, to_pos.y)
    local ab = b - a
    for _, opp in ipairs(opponents) do
        local p = Vector2D.new(opp.x, opp.y)
        local ap = p - a
        local t = math.max(0, math.min(1, ap:dot(ab) / ab:length_squared()))
        local closest = a + ab * t
        if (closest - p):length() < EPSILON then
            return false
        end
    end
    return true
end

function TAttackDecision.new()
    return setmetatable({
        state = "init",
        action = nil,
        target = nil
    }, TAttackDecision)
end

--- Procesa un ciclo de toma de decisión
--- @param id number robotId
--- @param team number teamId
--- @return boolean true si terminó la táctica
function TAttackDecision:process(id, team)
    local me = api.get_robot_state(id, team)
    local ball = api.get_ball_state()
    local opponents = api.get_opponents(team)
    local allies = api.get_allies(team)

    if not me or not ball or not opponents or not allies then return false end

    if self.state == "init" then
        if not utils.has_captured_ball(me, ball) then
            return capture.process(id, team)
        end

        if utils.is_ready_to_kick(me, ball, GOAL_POS)
            and is_path_clear(ball, GOAL_POS, opponents) then
            self.action = "kick"
            self.target = GOAL_POS
        else
            -- Buscar el mejor compañero con línea libre
            local best_id = nil
            local best_dist = math.huge
            for i, ally in pairs(allies) do
                if i ~= id then
                    if is_path_clear(ball, ally, opponents) then
                        local dist = utils.distance(ball, ally)
                        if dist < best_dist then
                            best_id = i
                            best_dist = dist
                            self.target = { x = ally.x, y = ally.y }
                        end
                    end
                end
            end
            if best_id then
                self.action = "pass"
            else
                self.action = "position"
            end
        end
        self.state = "aim"
        return false

    elseif self.state == "aim" then
        if self.action == "position" then
            -- No necesita apuntar
            self.state = "positioning"
            return false
        elseif aim.process(id, team, self.target) then
            self.state = (self.action == "hold") and "done" or "kick"
        end
        return false

    elseif self.state == "kick" then
        if kick.process(id, team, self.target) then
            self.state = "done"
        end
        return false

    elseif self.state == "positioning" then
        -- Mover a una zona libre
        local px = ball.x + 1.0
        local py = (me.y > 0) and 1.5 or -1.5
        api.move_to(id, team, { x = px, y = py })
        return false

    elseif self.state == "done" then
        return true
    end

    return false
end

return TAttackDecision