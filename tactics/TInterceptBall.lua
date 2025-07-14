local SIntercept = require("skills.intercept") -- O usa la skill que corresponda según tu carpeta

local TInterceptBall = {}
TInterceptBall.__index = TInterceptBall

function TInterceptBall.new()
    return setmetatable({ done = false }, TInterceptBall)
end

--- Intenta interceptar la pelota, usando la skill SIntercept.
-- Retorna true cuando la pelota ha sido capturada.
-- @param robot_id number
-- @param team number
-- @param intercept_point table {x, y} (opcional: si no se provee, intercepta en la posición de la pelota)
function TInterceptBall:process(robot_id, team, intercept_point)
    -- Por defecto, intercepta donde está la pelota
    local point = intercept_point or nil
    local completed = SIntercept.process(robot_id, team, point)
    self.done = completed
    return completed
end

function TInterceptBall:reset()
    self.done = false
end

function TInterceptBall:isDone()
    return self.done
end

return TInterceptBall
