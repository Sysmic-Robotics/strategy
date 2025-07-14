-- PI Controller Class
PIController = {}
PIController.__index = PIController


-- Constructor
function PIController:new(kp, ki, dt)
    local self = setmetatable({}, PIController)
    self.kp = kp or 0.0       -- Proportional gain
    self.ki = ki or 0.0       -- Integral gain
    self.dt = dt or 1.0       -- Time step
    self.integral = 0.0       -- Integral term
    return self
end

-- Reset the controller state
function PIController:reset()
    self.integral = 0.0
end

function PIController:set_gains(kp, ki)
    self.kp = kp
    self.ki = ki
end

-- Update method: calculates the control output
function PIController:update(setpoint, measurement)
    local error = setpoint - measurement
    self.integral = self.integral + error * self.dt
    local output = self.kp * error + self.ki * self.integral
    return output
end

return PIController
