local PCoordinatedAttack = require("plays.PCoordinatedAttack")

local game_state = {
    team = 0, -- o 1 si eres amarillo
    in_offense = true,
    in_defense = false,
    aborted = false,
}

-- IDs 1,2,3,4,5 son los de campo (0 es arquero y se ignora aquí)
local roles = { [0]=1, [1]=2, [2]=3, [3]=4, [4]=5 }  -- El primer valor es el kicker

local function swap_roles()
    -- Simple swap tipo "circular": el kicker va al final, el support random va adelante
    local kicker = roles[0]
    -- Elegir un nuevo kicker entre los demás
    local indices = {1,2,3,4}
    local new_kicker_idx = indices[math.random(1, #indices)]
    local new_kicker = roles[new_kicker_idx]
    -- Ahora reorganiza roles
    local new_roles = {}
    new_roles[0] = new_kicker
    local j = 1
    for i=0,4 do
        if roles[i] ~= new_kicker then
            new_roles[j] = roles[i]
            j = j + 1
        end
    end
    for i=0,4 do roles[i] = new_roles[i] end
    print(string.format("[PCoordinatedAttack] Swapped roles: kicker=%d, supports=%d,%d,%d,%d", roles[0], roles[1], roles[2], roles[3], roles[4]))
end

grsim.teleport_robot(1, 0, -3.2, -1.0, 0)
grsim.teleport_robot(2, 0, -3.2, -0.5, 0)
grsim.teleport_robot(3, 0, -3.2,  0.0, 0)
grsim.teleport_robot(4, 0, -3.2,  0.5, 0)
grsim.teleport_robot(5, 0, -3.2,  1.0, 0)
grsim.teleport_ball(-3, -0.2)

local play = PCoordinatedAttack.new()
play:assign_roles(roles)

local delay_frame = true

function process()
    if delay_frame then
        delay_frame = false
        return
    end

    if play:is_done(game_state) then
        swap_roles()
        play = PCoordinatedAttack.new()
        play:assign_roles(roles)
        delay_frame = true
    else
        play:process(game_state)
    end
end
