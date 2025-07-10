local SCaptureBall = require("skills.SCaptureBall")
local SPivot = require("skills.SPivotKick")
-- Initialize FSM to move robot 0 of team 0 to (1.5, -2.0)
local robot_id = 0
local team_id = 0
local frame_counter = 0
local setup_time = 5
local race_time = 2.4
local total_counter = 0
local ball
-- Optional: enable debug messages
local capture_ball = SCaptureBall.new(robot_id, team_id)
local orbit_radius = 0.2 -- radio de giro en metros
local orbit_speed = (math.pi / 180)/2  -- velocidad angular (radianes por frame)
local orbit_angle = 0

function process()
    --capture_ball:update()
    -- Orbitar alrededor del punto (0,0)
    local center = { x = 0.0, y = 0.0 }
    local px = center.x + orbit_radius * math.cos(orbit_angle)
    local py = center.y + orbit_radius * math.sin(orbit_angle)
    move_to(robot_id, team_id, { x = px, y = py })
    face_to(robot_id, team_id, { x = center.x, y = center.y })
    send_velocity(robot_id,team_id,0,-0.5,0)
    orbit_angle = orbit_angle + orbit_speed
    if orbit_angle > 2 * math.pi then
        orbit_angle = orbit_angle - 2 * math.pi
    end
    frame_counter = frame_counter + 1
end