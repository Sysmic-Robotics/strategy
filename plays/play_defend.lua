local Goalkeeper  = require("tactics.goalkeeper")
local Defender    = require("tactics.defender")
local Interceptor = require("tactics.interceptor")
local Support     = require("tactics.support")
local api         = require("sysmickit.lua_api")

local PlayDefend = {}
PlayDefend.__index = PlayDefend

local function mirror(team, pos)
    if team == 1 then
        return { x = -pos.x, y = -pos.y }
    end
    return pos
end

function PlayDefend.new()
    return setmetatable({
        goalie      = Goalkeeper.new(),
        defenders   = {
            Defender.new({ x = -0.8, y = -0.4 }),
            Defender.new({ x = -0.8, y = 0.4 })
        },
        interceptor = Interceptor.new(),
        supports    = { Support.new(), Support.new() },
    }, PlayDefend)
end

function PlayDefend:process(team)
    local ball = api.get_ball_state()
    if not ball then return end

    self.goalie:process(0, team)
    self.interceptor:process(1, team)

    local supportPos1 = mirror(team, { x = ball.x - 0.2, y = ball.y + 0.5 })
    local supportPos2 = mirror(team, { x = ball.x - 0.2, y = ball.y - 0.5 })

    self.supports[1]:update_target(supportPos1)
    self.supports[2]:update_target(supportPos2)

    for i,def in ipairs(self.defenders) do
        def:process(1 + i, team)
    end

    self.supports[1]:process(3, team)
    self.supports[2]:process(4, team)
end

return PlayDefend
