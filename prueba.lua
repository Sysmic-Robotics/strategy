local Engine         = require("sysmickit.engine")
local PAttack        = require("plays.PAttack")
local PStop          = require("plays.PStop")
local PHalt          = require("plays.PHalt")
local PBallPlacement = require("plays.PBallPlacement")

local game_state = {
    team = 0, -- blue
    in_offense = true,
    in_defense = false,
    aborted = false,
}

local roles = { [0] = 0, [1] = 1 }

local function swap_roles()
    roles[0], roles[1] = roles[1], roles[0]
    print(string.format("[PAttack] Swapped roles: [0] = %d, [1] = %d", roles[0], roles[1]))
end

-- Teletransportar robots y pelota solo al inicio
--grsim.teleport_robot(0, 0, -3.2, -0.5, 0)
--grsim.teleport_robot(1, 0, -3.2, 0.5, 0)
--grsim.teleport_ball(-3, -0.2)

-- Instanciar plays
local play_attack = PAttack.new()
play_attack:assign_roles(roles)

local play_stop          = PStop.new()
local play_halt          = PHalt.new()
local play_ballplacement = PBallPlacement.new()

local delay_frame = true

function process()
    if delay_frame then
        delay_frame = false
        return
    end

    -- Leer mensaje del árbitro
    --local ref_cmd = Engine.get_ref_message()
    -- print("[MAIN] Ref command:", ref_cmd)

    if "STOP" == "STOP" then
        play_ballplacement:process(game_state)
        return
    end
end

