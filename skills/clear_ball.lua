-- skills/clear_ball_smart.lua
local api     = require("sysmickit.lua_api")
local utils   = require("sysmickit.utils")
local capture = require("skills.capture_ball")

local Clear = {}
Clear.__index = Clear

--- Crea una nueva instancia de la skill clear_ball_smart
function Clear.new(team)
    local self = setmetatable({}, Clear)
    self.state = "capture"
    self.team = team or 0
    self.target = { x = 0, y = 0 } -- se calculará dinámicamente
    self.timer = 0
    return self
end

--- Ejecuta un despeje fuerte hacia el lado contrario del área propia
--- @param robotId number
--- @param team number
--- @return boolean true si se realizó el despeje
function Clear:process(robotId, team)
    local robot = api.get_robot_state(robotId, team)
    local ball = api.get_ball_state()
    if not robot or not ball then return false end

    if self.state == "capture" then
        local has_ball = capture.process(robotId, team, 10)
        if has_ball then
            -- Calcular dirección segura: despejar hacia el lado rival
            if team == 0 then
                self.target = { x = 1.2, y = 0.0 }
            else
                self.target = { x = -1.2, y = 0.0 }
            end
            self.state = "align"
        end
        return false

    elseif self.state == "align" then
        api.dribbler(robotId, team, 7)
        api.face_to(robotId, team, self.target, 1.0, 0.0, 0.1)
        local angle_to_target = math.atan(self.target.y - robot.y, self.target.x - robot.x)
        local angle_diff = utils.angle_diff(robot.orientation, angle_to_target)

        if math.abs(angle_diff) < 0.05 then
            self.timer = 0
            self.state = "wait_before_kick"
        end
        return false

    elseif self.state == "wait_before_kick" then
        self.timer = self.timer + 1
        if self.timer > 5 then  -- espera corta (~0.1s)
            self.state = "kick"
        end
        return false

    elseif self.state == "kick" then
        api.kickx(robotId, team)
        self.state = "capture"
        return true
    end

    return false
end

return Clear
