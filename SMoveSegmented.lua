local pid_pos = require("pid_pos")


local approach_distance = 0.07 -- distancia para cambiar de etapa (en metros)



local function process(robot_id, team_id, target_point)
    
    local robot = get_robot_state(robot_id, team_id)
    local dx = target_point.x - robot.x
    local dy = target_point.y - robot.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > approach_distance then
        -- Etapa 1: Avanzar directo apuntando al objetivo
        move_to(robot_id, team_id, target_point)
        face_to(robot_id, team_id, target_point,4,0.7,0.0)
        return false
    else
        -- Etapa 2: Aproximación fina con PID
        pid_pos.process(robot_id, team_id, target_point)
        if dist < 0.07 then -- muy muy cerca
            print("Llegué")
            return true
        else
            return false
        end
    end
end

return {
    process = process
}
