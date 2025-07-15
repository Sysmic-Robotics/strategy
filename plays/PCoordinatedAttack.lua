local Engine          = require("sysmickit.engine")
local utils           = require("sysmickit.utils")
local SCaptureBall    = require("skills.SCaptureBall")
local TKickToGoal     = require("tactics.TKickToGoal")
local TCoordinatedPass= require("tactics.TCoordinatedPass")

local PCoordinatedAttack = {}
PCoordinatedAttack.__index = PCoordinatedAttack

local PASS_REGION = {
    x_min = -4.5,
    x_max = 6.0,
    y_min = -3.0,
    y_max = 3.0
}

local function goal_pos_for_team(team)
    -- Opponent goal depending on our side
    if team == 0 then
        return { x = 4.5, y = 0 }
    else
        return { x = -4.5, y = 0 }
    end
end
local MAX_SHOT_DISTANCE = 2.7   -- metros desde el arco
local ATTACK_TIMEOUT_FRAMES = 240  -- 4 segundos si el loop corre a 60 Hz
local SUPPORT_READY_DIST = 0.25    -- cuán cerca debe estar el support a su destino para recibir el pase
local ADVANCE_OFFSET = 0.8
local FORMATION_WIDTH = 2.5

function PCoordinatedAttack.new()
    return setmetatable({
        state = "prepare",
        role_ids = {},
        pass_tactic = nil,
        kick_tactic = nil,
        attack_start_frame = nil,
        _chosen_support = nil,
        _support_positions = {},
    }, PCoordinatedAttack)
end

function PCoordinatedAttack:assign_roles(roles)
    self.role_ids = roles
end

function PCoordinatedAttack:is_done(game_state)
    return self.state == "done"
end
@@ -115,73 +122,71 @@ function PCoordinatedAttack:process(game_state)
        end
    end

    -- Estado 2: Ataque (idéntico a la lógica dos robots, pero con supports)
    if self.state == "attack" then
        if not self.attack_start_frame then
            self.attack_start_frame = frame_count()
        end

        local current_frame = frame_count()
        if current_frame - self.attack_start_frame > ATTACK_TIMEOUT_FRAMES then
            print("[PCoordinatedAttack] ¡Timeout de ataque! Reiniciando play por seguridad.")
            self.state = "done"
            return
        end

        if not utils.has_captured_ball(kicker, ball) then
            print("[PCoordinatedAttack] Perdí la pelota, termino play.")
            self.state = "done"
            return
        end

        -- 1. INTENTA SIEMPRE EL DISPARO PRIMERO (tal como PAttack original)
        local obstacles = Engine.get_opponents(team)
        local clearance = 0.3
        local goal_pos = goal_pos_for_team(team)
        local shot_distance = utils.distance(ball, goal_pos)
        if utils.is_path_clear(ball, goal_pos, obstacles, clearance)
           and shot_distance <= MAX_SHOT_DISTANCE then
            if not self.kick_tactic then
                self.kick_tactic = TKickToGoal.new()
            end
            if self.kick_tactic:process(kicker_id, team) then
                print("[PCoordinatedAttack] Disparo realizado, termino play.")
                self.state = "done"
            end
            return
        end

        -- 2. TODOS LOS SUPPORTS AVANZAN INMEDIATO AL ENTRAR EN ATTACK
        self._support_positions = set_support_positions(kicker, support_ids, team)

        -- 3. Elige un support random SOLO UNA VEZ por play
        if not self._chosen_support then
            self._chosen_support = support_ids[math.random(1, #support_ids)]
        end

        -- 4. Continuamente intenta mover el support seleccionado hacia su
        --    posición objetivo pero ya no espera a que llegue para pasar.
        local idx = nil
        for i, id in ipairs(support_ids) do
            if id == self._chosen_support then idx = i end
        end
        if idx then
            local target_pos = self._support_positions[idx]
            require("skills.SMove").process(self._chosen_support, team, target_pos)