local Engine = require("sysmickit.engine")
local Robot = require("sysmickit.robot")

local RStop = {}
RStop.__index = RStop

function RStop.new(team_setting)
    local self = setmetatable({}, RStop)
    self.team = team_setting.team
    self.robots_ids = team_setting.robots_ids
    self.robots = {}
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, self.team)
    end
    return self
end

function RStop:assign_roles(roles) end

function RStop:is_done(game_state)
    return false
end

function RStop:process()
    local ball = Engine.get_ball_state()

    for i, robot in ipairs(self.robots) do
        local state = robot:GetState()
        if state and ball then
            local dx = state.x - ball.x
            local dy = state.y - ball.y
            local dist = math.sqrt(dx * dx + dy * dy)

            -- Si está a menos de 0.5m de la pelota, retrocede a 0.7m de distancia
            if dist < 0.5 then
                local angle = math.atan(dy, dx)
                local safe_x = ball.x + math.cos(angle) * 0.7
                local safe_y = ball.y + math.sin(angle) * 0.7
                robot:Move({x = safe_x, y = safe_y})
            else
                robot:Stop()
            end
        else
            robot:Stop()
        end
    end
end

return RStop

