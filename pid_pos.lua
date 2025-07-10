-- PID para posición
local pid = {
    x = {kp = 2.0, ki = 0.0, kd = 0.0, prev_error = 0, integral = 0, integral_limit = 0.2, stuck_integral_limit = 2.0, stuck_counter = 0},
    y = {kp = 2.0, ki = 0.0, kd = 0.0, prev_error = 0, integral = 0, integral_limit = 0.2, stuck_integral_limit = 2.0, stuck_counter = 0},
}

local stuck_threshold = 0.005 -- velocidad mínima para considerar "estacionario"
local stuck_frames = 15       -- cuántos frames seguidos para considerar pegado

local function pid_update(axis, setpoint, measured, dt, measured_vel)
    local p = pid[axis]
    local error = setpoint - measured
    p.integral = p.integral + error * dt

    -- Detectar si está "pegado"
    if math.abs(measured_vel) < stuck_threshold then
        p.stuck_counter = p.stuck_counter + 1
    else
        p.stuck_counter = 0
    end

    -- Si está pegado, permitir mayor anti-windup
    local limit = p.integral_limit
    if p.stuck_counter > stuck_frames then
        limit = p.stuck_integral_limit
    end
    if p.integral > limit then
        p.integral = limit
    elseif p.integral < -limit then
        p.integral = -limit
    end

    local derivative = (error - p.prev_error) / dt
    local output = p.kp * error + p.ki * p.integral + p.kd * derivative
    p.prev_error = error

    -- --- FINE APPROACH ANTI-STICTION LOGIC ---
    local error_threshold = 0.01
    local min_output = 0.03
    if math.abs(error) < error_threshold then
        output = 0
    elseif math.abs(output) < min_output then
        output = min_output * (output >= 0 and 1 or -1)
    end
    -- -----------------------------------------

    return output
end

local function process(robot_id, team_id, target_point)
    local dt = 1/60
    local robot = get_robot_state(robot_id, team_id)
    local vx = pid_update('x', target_point.x, robot.x, dt, robot.vel_x)
    local vy = pid_update('y', target_point.y, robot.y, dt, robot.vel_y)
    send_velocity(robot_id, team_id, vx, vy, 0)
end

return {
    process = process,
    pid = pid
}
