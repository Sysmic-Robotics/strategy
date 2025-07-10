local robot_id = 0
local team_id = 0
local frame_counter = 0
local setup_time = 6
local race_time = 2
local total_counter = 0
local start_point = { x = 0.7, y = 0 }
local start_face = { x = 0.7, y = -2}
local end_point = { x = 0.8, y = 1 }

local pause_time = 1 -- segundos de pausa después de la carrera

local y_velocity = -2
local x_velocity = 0
function process()
    -- Ir al punto de partida mirando hacia él
    if frame_counter < 60 * setup_time then
        dribbler(robot_id,team_id,0)
        motion(robot_id, team_id, start_point)
        face_to(robot_id, team_id, start_face,1,4.7,0.0)
    -- Pausa antes de la carrera
    elseif frame_counter < 60 * (setup_time + pause_time) then
        send_velocity(robot_id, team_id, 0, 0, 0)
        -- face_to(robot_id, team_id, end_point,4,0.7,0.0)
    -- Carrera: avanzar hacia el punto de destino
    elseif frame_counter < 60 * (setup_time + pause_time + race_time) then
        send_velocity(robot_id, team_id, x_velocity, y_velocity, 0)
        
        
    else
        -- Detener y reiniciar ciclo
        send_velocity(robot_id, team_id, 0, 0, 0)
        frame_counter = 0
        total_counter = total_counter + 1
        return
    end
    frame_counter = frame_counter + 1
end
