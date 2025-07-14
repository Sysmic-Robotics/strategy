local PAttack = require("plays.PAttack")

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

grsim.teleport_robot(0, 0, -3.2, -0.5, 0)
grsim.teleport_robot(1, 0, -3.2, 0.5, 0)
grsim.teleport_ball(-3, -0.2)

local play = PAttack.new()
play:assign_roles(roles)

local delay_frame = true

function process()
    if delay_frame then
        delay_frame = false
        return
    end

    if play:is_done(game_state) then
        swap_roles()
        play = PAttack.new()
        play:assign_roles(roles)
        delay_frame = true
    else
        play:process(game_state)
    end
end
