local Engine = require("sysmickit.engine")
local utils  = require("sysmickit.utils")
local SCaptureBall = require("skills.SCaptureBall")
local SMove = require("skills.SMove")

local PBallPlacement = {}
PBallPlacement.__index = PBallPlacement

local SAFE_DIST = 0.5  -- Distancia para los no-placers
local PLACER_ID = 0    -- Por ahora, robot 0 siempre coloca la pelota

function PBallPlacement.new()
    return setmetatable({placer_id = PLACER_ID}, PBallPlacement)
end

function PBallPlacement:assign_roles(roles)
    -- Opcionalmente permitir setear el placer desde fuera
    if roles and roles.placer_id then
        self.placer_id = roles.placer_id
    end
end

function PBallPlacement:is_done(game_state)
    -- Consideramos terminado cuando la pelota está cerca del punto objetivo
    local ball = Engine.get_ball_state()
    local target = Engine.get_ballplacement_target and Engine.get_ballplacement_target() or {x = 0, y = 0}
    if not ball or not target then return false end
    return utils.distance(ball, target) < 0.12  -- 12 cm
end

function PBallPlacement:process(game_state)
    local team = game_state.team or 0
    local ball = Engine.get_ball_state()
    local target = Engine.get_ballplacement_target and Engine.get_ballplacement_target() or {x = 0, y = 0}
    if not ball or not target then return end

    for robot_id = 0, 5 do
        if robot_id == self.placer_id then
            -- Acercarse, capturar y llevar la pelota al objetivo
            if SCaptureBall.process(robot_id, team) then
                SMove.process(robot_id, team, target)
            end
        else
            -- Mantenerse lejos del balón
            local robot = Engine.get_robot_state(robot_id, team)
            if robot and utils.distance(robot, ball) < SAFE_DIST then
                local dx = robot.x - ball.x
                local dy = robot.y - ball.y
                local len = math.sqrt(dx * dx + dy * dy)
                if len > 1e-3 then
                    local retreat = {
                        x = ball.x + dx * (SAFE_DIST / len),
                        y = ball.y + dy * (SAFE_DIST / len)
                    }
                    Engine.move_to(robot_id, team, retreat)
                else
                    Engine.move_to(robot_id, team, {x = robot.x + 0.7, y = robot.y})
                end
            else
                Engine.stop_robot(robot_id, team)
            end
        end
    end
end

return PBallPlacement
