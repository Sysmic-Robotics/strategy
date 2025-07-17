local Engine = require("sysmickit.engine")
local Robot = require("sysmickit.robot")

local RBallPlacement = {}
RBallPlacement.__index = RBallPlacement

function RBallPlacement.new(team_setting)
    local self = setmetatable({}, RBallPlacement)
    self.team = team_setting.team
    self.robots_ids = team_setting.robots_ids
    self.robots = {}
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, self.team)
    end
    return self
end

function RBallPlacement:process(game_state)
    local ball = Engine.get_ball_state()
    local SAFE_DIST = 0.5   -- Distancia mínima según reglas (en metros)
    local ESCAPE_DIST = 0.7 -- Distancia segura a la que debe ir el robot

    for _, robot in ipairs(self.robots) do
        local state = robot:GetState()
        if state and ball then
            local dx = state.x - ball.x
            local dy = state.y - ball.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < SAFE_DIST then
                -- Usa math.atan2 para el ángulo correcto
                local angle = math.atan(dy, dx)
                local safe_x = ball.x + math.cos(angle) * ESCAPE_DIST
                local safe_y = ball.y + math.sin(angle) * ESCAPE_DIST
                robot:MoveDirect({x = safe_x, y = safe_y})
            else
                robot:Stop()
            end
        else
            robot:Stop()
        end
    end
end

return RBallPlacement
