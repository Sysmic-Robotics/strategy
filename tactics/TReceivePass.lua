local pass_receiver = require("skills.pass_receiver")
local move = require("skills.SMove")
local aim = require("skills.SAim")

local TReceivePass = {}
TReceivePass.__index = TReceivePass

function TReceivePass.new()
    return setmetatable({ done = false }, TReceivePass)
end

--- Procesa la recepción del pase
-- @param robot_id number
-- @param team number
-- @param pass_point table {x, y}
-- @param permitir_captura boolean
function TReceivePass:process(robot_id, team, pass_point, permitir_captura)
    local completed = false
    if permitir_captura then
        -- Intenta capturar la pelota solo si está permitido
        completed = pass_receiver.process(robot_id, team, pass_point)
    else
        -- Solo posiciona y orienta hacia el punto
        local at_pos = move.process(robot_id, team, pass_point)
        local at_orient = aim.process(robot_id, team, pass_point, "mid")
        completed = false -- Nunca termina aquí
    end
    self.done = completed
    return completed
end

function TReceivePass:reset()
    self.done = false
end

function TReceivePass:isDone()
    return self.done
end

return TReceivePass
