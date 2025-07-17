---@class Engine
local Engine = {}

---
--- Moves the specified robot to the given point.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table A table containing the target coordinates with keys `x` and `y`.
--- @return nil
function Engine.move_to(robotId, team, point)
    move_to(robotId, team, point)
end

--- Moves the specified robot to the given point without planning.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table A table containing the target coordinates with keys `x` and `y`.
--- @return nil
function Engine.move_direct(robotId, team, point)
    move_direct(robotId, team, point)
end

---
--- Returns a table representing the robot's state.
---
--- The returned table includes:
--- * id: number
--- * team: number
--- * x: number
--- * y: number
--- * vel_x: number
--- * vel_y: number
--- * orientation: number
--- * active: boolean
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return table The robot state table.
function Engine.get_robot_state(robotId, team)
    if type(robotId) ~= "number" then
        error("[Engine] Invalid robotId: expected number, got " .. type(robotId), 2)
    end
    if type(team) ~= "number" then
        error("[Engine] Invalid team: expected number, got " .. type(team), 2)
    end

    return get_robot_state(robotId, team)
end

--- Get the positions of all robots on a team (only 2 robots: ID 0 and 1)
--- @return table A list of robot positions { {x, y}, {x, y} }
function Engine.get_all_robots_positions()
    local robots = {}
    local team = 1
    for id = 0, 1 do
        local result = Engine.get_robot_state(id, team)
        if result and result.x and result.y then
            table.insert(robots, { x = result.x, y = result.y })
        end
    end
    return robots
end


---
--- Rotates the robot to face the specified target coordinates.
---
--- Rotates the robot to face a target point using a PID controller.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table A table containing the target coordinates with keys `x` and `y`.
--- @param kp number? (optional) Proportional gain. Default is 1.0.
--- @param ki number? (optional) Integral gain. Default is 1.0.
--- @param kd number? (optional) Derivative gain. Default is 0.1.
--- @return nil
function Engine.face_to(robotId, team, point, kp, ki, kd)
    kp = kp or 3.5
    ki = ki or 0.7
    kd = kd or 0.1
    face_to(robotId, team, point, kp, ki, kd)
end


---
--- Returns a table representing the ball's state.
---
--- The returned table includes:
--- * x: number
--- * y: number
---
--- @return table The ball state table.
function Engine.get_ball_state()
    return get_ball_state()
end

---
--- Activates the robot's kick in the X direction.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return nil
function Engine.kickx(robotId, team)
    kickx(robotId, team)
end

---
--- Activates the robot's kick in the Z direction.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return nil
function Engine.kickz(robotId, team)
    kickz(robotId, team)
end

---
--- Sets the dribbler speed for the robot.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param speed number The dribbler speed (0–10).
--- @return nil
function Engine.dribbler(robotId, team, speed)
    if type(speed) ~= "number" then
        error("[Engine.dribbler] Invalid type for 'speed': expected number, got " .. type(speed))
    end

    if speed < 0 then
        speed = 0
    end
    if speed > 4 then
        speed = 4
    end
    dribbler(robotId, team, speed)
end


---
--- Sends a velocity command to the specified robot.
---
--- Sets the translational and rotational velocities for the robot.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier (e.g., 0 = blue, 1 = yellow).
--- @param vx number Velocity in the X direction (m/s).
--- @param vy number Velocity in the Y direction (m/s).
--- @param vtetha number Rotational velocity (rad/s).
--- @return nil
function Engine.send_velocity(robotId, team, vx, vy, vtetha)
    send_velocity(robotId, team, vx, vy, vtetha)
end

---
--- Retrieves the current referee command as a string.
---
--- This reflects the latest command issued by the referee system,
--- such as "HALT", "STOP", "NORMAL_START", etc.
---
--- @return string The current referee command.
function Engine.get_ref_message()
    return get_ref_message()
end

---
--- Retrieves the current state of the blue team robots.
---
--- Returns a list of robot state tables, each containing:
--- * id: number
--- * team: number
--- * x: number
--- * y: number
--- * vel_x: number
--- * vel_y: number
--- * orientation: number
--- * active: boolean
-------------------------------------------------------------------
--- @return table[] List of blue team robot states.
function Engine.get_blue_team_state()
    local all_robots = get_blue_team_state()
    local active_robots = {}

    for _, robot in pairs(all_robots) do
        if robot.active then
            table.insert(active_robots, robot)
        end
    end
    return active_robots
end
------------------------------------------------------------------------
---
--- Retrieves the current state of the yellow team robots.
---
--- Returns a list of robot state tables, each containing:
--- * id: number
--- * team: number
--- * x: number
--- * y: number
--- * vel_x: number
--- * vel_y: number
--- * orientation: number
--- * active: boolean
---
--- @return table[] List of yellow team robot states.
function Engine.get_yellow_team_state()
    local all_robots = get_yellow_team_state()
    local active_robots = {}

    for _, robot in pairs(all_robots) do
        if robot.active then
            table.insert(active_robots, robot)
        end
    end
    return active_robots
end


-- Devuelve todos los oponentes del equipo dado (como lista de posiciones)
function Engine.get_opponents(team)
    -- Para SSL: 0=blue, 1=yellow
    local opponent_team = (team == 0) and 1 or 0
    local opponents = {}
    -- Puedes cambiar el rango máximo de id según tu liga (a veces es hasta 5, otras hasta 10)
    for id = 0, 10 do
        local opp = Engine.get_robot_state(id, opponent_team)
        if opp and opp.x and opp.y then
            table.insert(opponents, {x = opp.x, y = opp.y})
        end
    end
    return opponents
end

-- Devuelve la posición de todos los aliados activos del equipo dado
function Engine.get_allies(team)
    local allies = {}
    for id = 0, 10 do
        local ally = Engine.get_robot_state(id, team)
        if ally and ally.x and ally.y then
            table.insert(allies, {x = ally.x, y = ally.y})
        end
    end
    return allies
end


return Engine