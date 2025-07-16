local Engine           = require("sysmickit.engine")
local utils            = require("sysmickit.utils")
local SCaptureBall     = require("skills.SCaptureBall")
local TKickToGoal      = require("tactics.TKickToGoal")
local TCoordinatedPass = require("tactics.TCoordinatedPass")

local PCoordinatedAttack = {}
PCoordinatedAttack.__index = PCoordinatedAttack

local ATTACK_TIMEOUT_FRAMES = 180
local ADVANCE_OFFSET = 0.8
local FORMATION_WIDTH = 2.5
local BALL_TOO_FAR_DIST = 1

-- Posiciona supports de forma ofensiva (evita zonas prohibidas)
local function set_other_supports_positions(kicker, support_ids, chosen_support, team, play_side)
    local positions = {}
    local filtered_ids = {}
    for _, id in ipairs(support_ids) do
        if id ~= chosen_support then table.insert(filtered_ids, id) end
    end
    local num_supports = #filtered_ids
    local advance_offset = (play_side == "right") and -ADVANCE_OFFSET or ADVANCE_OFFSET
    for i=1, num_supports do
        local frac = (num_supports > 1) and (i-1)/(num_supports-1) or 0.5
        local y_pos = kicker.y - FORMATION_WIDTH/2 + frac * FORMATION_WIDTH
        local x_pos = kicker.x + advance_offset
        local pos = {x = x_pos, y = y_pos}
        pos = utils.clamp_to_field(pos)
        positions[i] = pos
    end
    for i, id in ipairs(filtered_ids) do
        local robot = Engine.get_robot_state(id, team)
        if robot then
            require("skills.SMove").process(id, team, positions[i])
        end
    end
    return positions
end

function PCoordinatedAttack.new(TEAM_SETTING)
    return setmetatable({
        state = "prepare",
        team = TEAM_SETTING.team,
        play_side = TEAM_SETTING.play_side, -- "left" o "right"
        pass_tactic = nil,
        kick_tactic = nil,
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

function PCoordinatedAttack:process()
    local team = self.team
    local play_side = self.play_side
    local GOAL_POS, GOAL_DIR = utils.get_goal_pos_and_direction(play_side)
    local MAX_SHOT_DISTANCE = 3
    local pass_region = utils.get_pass_region(play_side)

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

    if utils.is_in_restricted_area(ball) then
        print("[PCoordinatedAttack] Balón en área restringida/fuera de cancha. Fin de ataque.")
        self.state = "done"
        return true
    end

    local kicker_idx = utils.get_closest_robot_to_point(robots, ball)
    local kicker_id = active_ids[kicker_idx]
    local kicker = Engine.get_robot_state(kicker_id, team)
    local support_ids = {}
    for _, id in ipairs(active_ids) do
        if id ~= kicker_id then table.insert(support_ids, id) end
    end

    if self._last_kicker ~= kicker_id then
        self.state = "prepare"
        self._chosen_support = nil
        self.pass_tactic = nil
        self.kick_tactic = nil
        self._last_kicker = kicker_id
    end

    -- Pelota muy lejos: abortar ataque
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

    -- Captura pelota
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

    -- Ataque
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

        -- DISPARO DIRECTO
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3
        local shot_distance = utils.distance(ball, GOAL_POS)
        if utils.is_path_clear(ball, GOAL_POS, obstacles, clearance)
           and shot_distance <= MAX_SHOT_DISTANCE then
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new(self.play_side)
            end
            if self.kick_tactic:process(kicker_id, team) then
                self.state = "done"
                return true
            end
            return false
        end

        -- Support random (no receptor)
        if not self._chosen_support then
            if #support_ids == 0 then
                self.state = "done"
                return true
            end
            self._chosen_support = support_ids[math.random(1, #support_ids)]
        end

        -- Supports a posición (corrige posiciones prohibidas)
        set_other_supports_positions(kicker, support_ids, self._chosen_support, team, play_side)

        -- Pase (TCoordinatedPass cuida la lógica del receptor)
        if not self.pass_tactic then
            self.pass_tactic = TCoordinatedPass.new(
                kicker_id, self._chosen_support, team, pass_region, self.play_side)
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
