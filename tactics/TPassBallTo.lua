local SPivotKick = require("skills.SPivotKick")
local SCapture = require("skills.SCaptureBall")
local SPivotAim = require("skills.SPivotAim")

local TPassBallTo = {}
TPassBallTo.__index = TPassBallTo

function TPassBallTo.new()
    return setmetatable({ state = "capture" }, TPassBallTo)
end

--- Realiza un pase al punto objetivo (ej: posición del receptor)
-- Retorna true solo cuando el pase se completó.
-- @param robot_id number
-- @param team number
-- @param pass_point table {x, y} punto al que pasar
function TPassBallTo:process(robot_id, team, pass_point)
    if self.state == "capture" then
        if SCapture.process(robot_id, team) then
            self.state = "aim"
        end
        return false
    end

    if self.state == "aim" then
        if SPivotAim.process(robot_id, team, pass_point) then
            self.state = "kick"
        end
        return false
    end

    if self.state == "kick" then
        if SPivotKick.process(robot_id, team, pass_point) then
            self.state = "done"
            return true
        end
        return false
    end

    if self.state == "done" then
        return true
    end

    self.state = "capture"
    return false
end

function TPassBallTo:reset()
    self.state = "capture"
end

function TPassBallTo:isDone()
    return self.state == "done"
end

return TPassBallTo
