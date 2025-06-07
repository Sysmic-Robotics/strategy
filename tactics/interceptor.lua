local api       = require("sysmickit.lua_api")
local intercept = require("skills.intercept")
local aim       = require("skills.aim")

local Interceptor = {}
Interceptor.__index = Interceptor

function Interceptor.new()
    return setmetatable({}, Interceptor)
end

function Interceptor:process(robotId, team)
    local ball = api.get_ball_state()
    if not ball then return end
    intercept.process(robotId, team, { x = ball.x, y = ball.y })
    aim.process(robotId, team, ball, "fast")
end

return Interceptor
