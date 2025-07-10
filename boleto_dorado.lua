-- El robot sigue una línea recta de varios puntos usando motion(robot, id)

local robot_id = 0
local team_id = 0

local Kpx = 0.0
local Kix = 0.0

local Kpy = 0.0
local Kiy = 0.0

local points = {
    {x = 0.8, y = 0},
    {x = -0.8, y = 0}
}
local current_target = 1

function process()
    local robot = get_robot_state(robot_id, team_id)
    local target = points[current_target]
    motion(robot_id, team_id, target, Kpx, Kix, Kpy, Kiy)
    local dx = target.x - robot.x
    local dy = target.y - robot.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist < 0.04 then
        current_target = 3 - current_target -- alterna entre 1 y 2
    end
end

