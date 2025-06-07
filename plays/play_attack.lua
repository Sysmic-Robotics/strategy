local Attacker  = require("tactics.attacker")
local Receiver  = require("tactics.receiver")
local Support   = require("tactics.support")
local Defender  = require("tactics.defender")
local api       = require("sysmickit.lua_api")

local PlayAttack = {}
PlayAttack.__index = PlayAttack

local function mirror(team, pos)
    if team == 1 then
        return { x = -pos.x, y = -pos.y }
    end
    return pos
end

function PlayAttack.new()
    return setmetatable({
        attacker  = Attacker.new(),
        receiver  = Receiver.new(),
        support   = Support.new(),
        defenders = {
            Defender.new({ x = -0.6, y = -0.3 }),
            Defender.new({ x = -0.6, y = 0.3 }),
            Defender.new({ x = -1.1, y = 0.0 }),
        },
    }, PlayAttack)
end

function PlayAttack:process(team)
    local ball = api.get_ball_state()
    if not ball then return end

    self.attacker:process(0, team)
    self.receiver:process(1, team)

    local supportPos = mirror(team, { x = ball.x - 0.3, y = ball.y })
    self.support:update_target(supportPos)
    self.support:process(2, team)

    for i,def in ipairs(self.defenders) do
        def:process(2 + i, team)
    end
end

return PlayAttack
