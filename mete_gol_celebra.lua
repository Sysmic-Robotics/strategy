local SCaptureBall = require("skills.SCaptureBall")
local SPivotKick = require("skills.SPivotKick")
local robot_id = 0
local team_id = 0
local state = "kick"
local wait_counter = 0
local victory_counter = 0
local victory_time = 2 * 60 -- 2 segundos a 60 fps
local wait_time = 3 * 60    -- 3 segundos a 60 fps

function process()
    if state == "kick" then
        local kicked = SPivotKick.process(robot_id, team_id, { x = 1.2, y = 0 })
        if kicked then
            state = "goto_center"
        end
    elseif state == "goto_center" then
        move_to(robot_id, team_id, { x = 0, y = 0 })
        face_to(robot_id, team_id, { x = 0, y = 0 })
        local api = require("sysmickit.lua_api")
        local robot = api.get_robot_state(robot_id, team_id)
        local dx = robot.x - 0
        local dy = robot.y - 0
        if math.sqrt(dx*dx + dy*dy) < 0.05 then
            state = "victory"
            victory_counter = 0
        end
    elseif state == "victory" then
        -- Rotar en el lugar (celebración)
        send_velocity(robot_id, team_id, 0, 0, 10.0)
        victory_counter = victory_counter + 1
        if victory_counter >= victory_time then
            state = "wait"
            wait_counter = 0
            send_velocity(robot_id, team_id, 0, 0, 0)
        end
    elseif state == "wait" then
        -- Esperar 3 segundos
        send_velocity(robot_id, team_id, 0, 0, 0)
        wait_counter = wait_counter + 1
        if wait_counter >= wait_time then
            state = "kick"
        end
    end
end
