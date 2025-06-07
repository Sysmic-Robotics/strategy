local api       = require("sysmickit.lua_api")
local face_move = require("skills.face_ball_while_move")
local mark      = require("skills.mark")

local Defender = {}
Defender.__index = Defender

function Defender.new(home)
    return setmetatable({ home = home or { x = -1.0, y = 0.0 }, offset = home and home.offset or 0 }, Defender)
end

local function mirror(team, pos)
    if team == 1 then
        return { x = -pos.x, y = -pos.y }
    end
    return pos
end

function Defender:process(robotId, team)
    local ball = api.get_ball_state()
    if not ball then return end

    local ownHalf = (team == 0 and ball.x < 0) or (team == 1 and ball.x > 0)
    local target
    if ownHalf then
        local gx = team == 0 and -1.4 or 1.4
        target = { x = gx, y = ball.y + (self.offset or 0) }
        mark.process(robotId, team, target)
    else
        target = mirror(team, self.home)
    end
    if not self.mover then
        self.mover = face_move.new(target)
    end
    self.mover.target = target
    self.mover:process(robotId, team)
end

return Defender
