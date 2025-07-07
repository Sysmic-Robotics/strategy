local robotId = 0
local team = 0


local field_limits = {
    x = {-0.5, 0.5},
    y = {-0.5, 0.5}
}
local function is_out_of_bounds(x, y)
    return x < field_limits.x[1] or x > field_limits.x[2]
        or y < field_limits.y[1] or y > field_limits.y[2]
end

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end


function process()
    local robot = get_robot_state(robotId, team)
    local pos = {x = robot.x, y = robot.y}
    --capture_ball:update()
    --smove:update()
    if not returning_home then
        send_velocity(robotId, team, 1, 0, 0)
    --motion(robotId, team, pt, 0.5 ,0.1 , 0.5, 0.1)


    if returning_home then
        move_to(robotId, team, {x=0, y = 0})
        if distance(pos, {x=0,y=0}) < 0.1 then
            returning_home = false
        end
        return
    end
    if is_out_of_bounds(pos.x, pos.y) then
        returning_home = true
        return
    end

end