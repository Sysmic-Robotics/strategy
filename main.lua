local pid_pos = require("pid_pos")
local SMoveSegmented = require("SMoveSegmented")

local robot_id = 0
local team_id = 0

-- Ajusta aquí la ganancia proporcional para Ziegler-Nichols
pid_pos.pid.x.kp = 2
pid_pos.pid.y.kp = 2
pid_pos.pid.x.ki = 0.0
pid_pos.pid.y.ki = 0.0
pid_pos.pid.x.kd = 0.5
pid_pos.pid.y.kd = 0.5
-- Genera puntos en línea recta sobre y=0 desde x=0.8 hasta x=-0.8
local distancia_entre_puntos = 0.2
local points = {}
for x = 0.8, -0.8, -distancia_entre_puntos do
    table.insert(points, {x = x, y = 0})
end
points[#points+1] = {x = -0.8, y = 0} -- asegura que termina en x=-0.8

local current_target = 1
local terminado = false

function process()
    if terminado then
        move_to(robot_id, team_id, {x=0, y=0})
        face_to(robot_id,team_id, {x=0,y=0},4,0.7,0.0)
        return
    end
    local target_point = points[current_target]
    if not target_point then
        print("Secuencia terminada (no hay más puntos)")
        terminado = true
        move_to(robot_id, team_id, {x=0, y=0})
        face_to(robot_id,team_id, {x=0,y=0},4,0.7,0.0)
        return
    end
    local arrived = SMoveSegmented.process(robot_id, team_id, target_point)
    if arrived then
        print(string.format("Llegué a: (%.2f, %.2f)", target_point.x, target_point.y))
        current_target = current_target + 1
        if current_target > #points then
            print("Secuencia terminada")
            terminado = true
            move_to(robot_id, team_id, {x=0, y=0})
        else
            print(string.format("Nuevo objetivo: (%.2f, %.2f)", points[current_target].x, points[current_target].y))
        end
    end
end
