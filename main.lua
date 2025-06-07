local AdvanceWithPass = require("plays.ForwardPass")

local game_state = {
    team = 0,
    in_offense = true,
    in_defense = false,
    aborted = false,
}

local roles = { [0] = 0, [1] = 1 }

local function swap_roles()
    roles[0], roles[1] = roles[1], roles[0]
    print(string.format("[AdvanceWithPass] Swapped roles: [0] = %d, [1] = %d", roles[0], roles[1]))
end

-- Teleport robots and ball
grsim.teleport_robot(0, 0, 0, -0.5, 0)
grsim.teleport_robot(1, 0, 0, 0.5, 0)
grsim.teleport_ball(0, 0)

-- Initialize play and delay state
local play = AdvanceWithPass.new()
play:assign_roles(roles)

local delay_frame = true

function process()
    -- Skip one frame after teleport so ball state updates
    if delay_frame then
        delay_frame = false
        return
    end

    if play:is_done(game_state) then
        swap_roles()
        play = AdvanceWithPass.new()
        play:assign_roles(roles)
        delay_frame = true -- wait again after reset
    else
        play:process(game_state)
    end
end
