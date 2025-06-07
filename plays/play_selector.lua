local PlayAttack = require("plays.play_attack")
local PlayDefend = require("plays.play_defend")
local api        = require("sysmickit.lua_api")
local utils      = require("sysmickit.utils")

local Selector = {}

local attack = PlayAttack.new()
local defend = PlayDefend.new()
local current = nil

local function we_have_ball(team)
    local ball = api.get_ball_state()
    if not ball then return false end
    for id = 0, 5 do
        local r = api.get_robot_state(id, team)
        if r and r.active then
            if utils.distance(r, ball) < 0.2 then
                return true
            end
        end
    end
    return false
end

function Selector.process(team)
    if we_have_ball(team) then
        current = attack
    else
        current = defend
    end
    current:process(team)
end

return Selector
