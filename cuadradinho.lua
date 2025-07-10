local robot_id = 0
local team_id = 0
local frame_counter = 0
local setup_time = 6
local race_time = 2
local total_counter = 0
local pause_time = 0.5 -- segundos de pausa después de la carrera

local square_points = {
    { x = 0.7, y = 0.7 },      -- punto 1
    { x = 0.7, y = -0.7 },      -- punto 2
    { x = -0.7, y = -0.7 },      -- punto 3
    { x = -0.7, y = 0.7 }       -- punto 4
}
local current_point = 1

local function next_square_index(idx)
    return (idx % 4) + 1
end

function process()
    -- Ir al punto actual mirando hacia el siguiente
    local next_point = next_square_index(current_point)
    if frame_counter < 60 * setup_time then
        dribbler(robot_id,team_id,0)
        motion(robot_id, team_id, square_points[current_point], 1.0, 2.0, 1.0,2.0)--,1.0, 15.2, 1.0, 15.2)
        --face_to(robot_id, team_id, {x=0,y=0}, 5.0, 25.0, 0.0)

    elseif frame_counter < 60 * (setup_time + pause_time) then
        face_to(robot_id, team_id, {x=0,y=0}, 5.0, 25.0, 0.0)
        send_velocity(robot_id, team_id, 0, 0, 0)
    else
        -- Detener y avanzar al siguiente punto del cuadrado
        send_velocity(robot_id, team_id, 0, 0, 0)
        frame_counter = 0
        total_counter = total_counter + 1
        current_point = next_point
        return
    end
    frame_counter = frame_counter + 1
end
