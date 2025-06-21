---@class LuaAPI
local LuaAPI = {}

---
--- Moves the specified robot to the given point.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table A table containing the target coordinates with keys `x` and `y`.
--- @return nil
function LuaAPI.move_to(robotId, team, point)
    move_to(robotId, team, point)
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
function LuaAPI.get_robot_state(robotId, team)
    return get_robot_state(robotId, team)
end

---
--- Rotates the robot to face a target point using a PID controller.
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param point table A table with `x` and `y` coordinates.
--- @param kp number? Proportional gain (default: 1.0).
--- @param ki number? Integral gain (default: 1.0).
--- @param kd number? Derivative gain (default: 0.1).
function LuaAPI.face_to(robotId, team, point, kp, ki, kd)
    -- Default PID values
    kp = tonumber(kp) or 1.0
    ki = tonumber(ki) or 1.0
    kd = tonumber(kd) or 0.1

    -- Validate inputs
    if type(robotId) ~= "number" or type(team) ~= "number" then
        error("Invalid robotId or team: both must be numbers")
    end

    if type(point) ~= "table" or type(point.x) ~= "number" or type(point.y) ~= "number" then
        error("Invalid point: must be a table with numeric 'x' and 'y'")
    end

    -- Call the native base function
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
function LuaAPI.get_ball_state()
    return get_ball_state()
end

---
--- Activates the robot's kick in the X direction.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return nil
function LuaAPI.kickx(robotId, team)
    kickx(robotId, team)
end

---
--- Activates the robot's kick in the Z direction.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @return nil
function LuaAPI.kickz(robotId, team)
    kickz(robotId, team)
end

---
--- Sets the dribbler speed for the robot.
---
--- @param robotId number The ID of the robot.
--- @param team number The team identifier.
--- @param speed number The dribbler speed (0–10).
--- @return nil
function LuaAPI.dribbler(robotId, team, speed)
    if type(speed) ~= "number" then
        error("[LuaAPI.dribbler] Invalid type for 'speed': expected number, got " .. type(speed))
    end

    if speed < 0 then
        speed = 0
    end
    if speed > 7 then
        speed = 7
    end
    dribbler(robotId, team, speed)
end

return LuaAPI
