slocal SCaptureBall = require("skills.SCaptureBall")
local SPivot = require("skills.SPivotKick")
-- Initialize FSM to move robot 0 of team 0 to (1.5, -2.0)
local robot_id = 0
local team_id = 0
local frame_counter = 0
local setup_time = 5
local race_time = 2.4
local total_counter = 0;
-- Optional: enable debug messages
local capture_ball = SCaptureBall.new(robot_id, team_id)
-- Estado para el cuadrado
local square = {
    {x = 1.1, y = 0},
    {x = 1.1, y = 0.8},
    {x = -0.8, y = 0.8},
    {x = -0.8, y = 0},
}
local num_corners = #square
local square_idx = 1
local pause_counter = 0
local in_pause = false
local laps = 0
local threshold = 0.05
function process()
    --capture_ball:update()
    local pause_time = 1 -- segundos de pausa
    if laps >= 10 then
        send_velocity(robot_id, team_id, 0, 0, 0)
        return
    end
    local current_idx = square_idx
    local next_idx = current_idx % num_corners + 1
    local to = square[next_idx]
    if in_pause then
        send_velocity(robot_id, team_id, 0, 0, 0)
        pause_counter = pause_counter + 1
        if pause_counter >= 60 * pause_time then
            in_pause = false
            pause_counter = 0
            square_idx = next_idx
            if next_idx == 1 then
                laps = laps + 1
            end
        end
        return
    end
    -- Solo entrar en pausa si realmente llegó al destino
    local robot = get_robot_state and get_robot_state(robot_id, team_id) or {x=0, y=0}
    local dx = robot.x - to.x
    local dy = robot.y - to.y
    if not in_pause and math.sqrt(dx*dx + dy*dy) < threshold then
        in_pause = true
        pause_counter = 0
        send_velocity(robot_id, team_id, 0, 0, 0)
        return
    end
    -- Moverse al siguiente vértice usando el controlador PIUD
    motion(robot_id, team_id, { x = to.x, y = to.y }, 2.44, 8, 2.870, 1.869)
    face_to(robot_id, team_id, to)
end