local Engine           = require("sysmickit.engine")
local utils            = require("sysmickit.utils")
local SCaptureBall     = require("skills.SCaptureBall")
local TKickToGoal      = require("tactics.TKickToGoal")
local TCoordinatedPass = require("tactics.TCoordinatedPass")
local TGoalkeeper      = require("tactics.TGoalkeeper")

local PCoordinatedAttack = {}
PCoordinatedAttack.__index = PCoordinatedAttack

local PASS_REGION = {
    x_min = -4.5,
    x_max = 6.0,
    y_min = -3.0,
    y_max = 3.0
}

local GOAL_POS = { x = 4.5, y = 0 }
local MAX_SHOT_DISTANCE = 2.7
local ATTACK_TIMEOUT_FRAMES = 240  -- 4 segundos a 60 Hz
local ADVANCE_OFFSET = 0.8
local FORMATION_WIDTH = 2.5

-- NUEVO: umbral de distancia máxima balón-robot para abortar ataque
local BALL_TOO_FAR_DIST = 1

function PCoordinatedAttack.new(team)
    return setmetatable({
        state = "prepare",
        team = team or 0,
        pass_tactic = nil,
        kick_tactic = nil,
        tactic_goalkeeper = TGoalkeeper.new(),
        attack_start_frame = nil,
        _chosen_support = nil,
        _support_positions = {},
        _last_kicker = nil,
    }, PCoordinatedAttack)
end

function PCoordinatedAttack:is_done()
    return self.state == "done"
end

local global_frame = 0
function frame_count()
    global_frame = global_frame + 1
    return global_frame
end

local function set_other_supports_positions(kicker, support_ids, chosen_support, team)
    local positions = {}
    local filtered_ids = {}
    for _, id in ipairs(support_ids) do
        if id ~= chosen_support then table.insert(filtered_ids, id) end
    end
    local num_supports = #filtered_ids
    for i=1, num_supports do
        local frac = (num_supports > 1) and (i-1)/(num_supports-1) or 0.5
        local y_pos = kicker.y - FORMATION_WIDTH/2 + frac * FORMATION_WIDTH
        local x_pos = kicker.x + ADVANCE_OFFSET
        if team == 1 then x_pos = kicker.x - ADVANCE_OFFSET end
        positions[i] = {x = x_pos, y = y_pos}
    end
    for i, id in ipairs(filtered_ids) do
        local robot = Engine.get_robot_state(id, team)
        if robot then
            require("skills.SMove").process(id, team, positions[i])
        end
    end
    return positions
end

function PCoordinatedAttack:process()
    local team = self.team

    -- 1. Siempre ejecuta el arquero (ID 0)
    self.tactic_goalkeeper:process(0, team)

    -- 2. Consigue los robots de campo activos (IDs 1–5)
    local robots = {}
    local active_ids = {}
    for id = 1, 5 do
        local rob = Engine.get_robot_state(id, team)
        if rob and rob.active then
            table.insert(robots, rob)
            table.insert(active_ids, id)
        end
    end
    local ball = Engine.get_ball_state()
    if not ball or #robots == 0 then
        self.state = "done"
        return true
    end

    -- 3. Elige kicker: el más cerca de la pelota
    local kicker_idx = utils.get_closest_robot_to_point(robots, ball)
    local kicker_id = active_ids[kicker_idx]
    local kicker = Engine.get_robot_state(kicker_id, team)
    -- 4. El resto son supports
    local support_ids = {}
    for _, id in ipairs(active_ids) do
        if id ~= kicker_id then table.insert(support_ids, id) end
    end

    -- Al reiniciar play, limpia estado
    if self._last_kicker ~= kicker_id then
        self.state = "prepare"
        self._chosen_support = nil
        self.pass_tactic = nil
        self.kick_tactic = nil
        self._last_kicker = kicker_id
    end

    -- CHEQUEO CLAVE: Si la pelota está muy lejos de todos (ataque abortado)
    local min_dist = math.huge
    for _, rob in ipairs(robots) do
        local d = utils.distance(rob, ball)
        if d < min_dist then min_dist = d end
    end
    if min_dist > BALL_TOO_FAR_DIST then
        print("[PCoordinatedAttack] Balón demasiado lejos de todos los robots. Fin de ataque.")
        self.state = "done"
        return true
    end

    -- Estado 1: Preparar/capturar pelota
    if self.state == "prepare" then
        self.attack_start_frame = nil
        if utils.has_captured_ball(kicker, ball) then
            self.state = "attack"
            return false
        end
        local dist = utils.distance(kicker, ball)
        if dist < 0.8 then
            if SCaptureBall.process(kicker_id, team) then
                self.state = "attack"
            end
            return false
        else
            self.state = "done"
            return true
        end
    end

    -- Estado 2: Ataque (como PAttack)
    if self.state == "attack" then
        if not self.attack_start_frame then
            self.attack_start_frame = frame_count()
        end
        local current_frame = frame_count()
        if current_frame - self.attack_start_frame > ATTACK_TIMEOUT_FRAMES then
            self.state = "done"
            return true
        end
        if not utils.has_captured_ball(kicker, ball) then
            self.state = "done"
            return true
        end

        -- 1. INTENTA DISPARO DIRECTO
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3
        local shot_distance = utils.distance(ball, GOAL_POS)
        if utils.is_path_clear(ball, GOAL_POS, obstacles, clearance)
           and shot_distance <= MAX_SHOT_DISTANCE then
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new()
            end
            if self.kick_tactic:process(kicker_id, team) then
                self.state = "done"
                return true
            end
            return false
        end

        -- 2. Elige un support random SOLO UNA VEZ por play
        if not self._chosen_support then
            if #support_ids == 0 then
                self.state = "done"
                return true
            end
            self._chosen_support = support_ids[math.random(1, #support_ids)]
        end

        -- 3. SOLO los supports que NO son receptor se mueven a posición estratégica
        set_other_supports_positions(kicker, support_ids, self._chosen_support, team)

        -- 4. Ejecuta el pase de inmediato; TCoordinatedPass mueve y espera al receptor
        if not self.pass_tactic then
            self.pass_tactic = TCoordinatedPass.new(kicker_id, self._chosen_support, team, PASS_REGION)
        end
        if self.pass_tactic:process() then
            self.state = "done"
            return true
        end
        return false
    end
    return false
end

return PCoordinatedAttack
