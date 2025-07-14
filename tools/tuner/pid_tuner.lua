-- pid_tuner.lua
local PIController = require("tools.tuner.pid")
local Twiddle = require("tools.tuner.twiddle")

local PIDTuner = {}
PIDTuner.__index = PIDTuner

-- axis debe ser "vx" o "vy"
function PIDTuner:new(axis, dt)
    local self = setmetatable({}, PIDTuner)

    self.axis = axis
    self.dt = dt

    self.controller = PIController:new(0.0, 0.0, dt)

    self.error_sum = 0
    self.error_count = 0

    -- Función que devuelve el error promedio acumulado
    local function get_error()
        local avg = self.error_sum / math.max(self.error_count, 1)
        self.error_sum = 0
        self.error_count = 0
        return avg
    end

    self.twiddle = Twiddle:new(self.controller, get_error, {1.0, 0.0}, {0.01, 0.001}, 0.01)

    return self
end

function PIDTuner:tune(id, team, vel_ref)
    local state = get_robot_state(id, team)
    local o = state.orientation
    local cos_o = math.cos(-o)
    local sin_o = math.sin(-o)

    -- Convertir velocidades globales a locales
    local vx_local = state.vel_x * cos_o - state.vel_y * sin_o
    local vy_local = state.vel_x * sin_o + state.vel_y * cos_o

    local vel_local = (self.axis == "vx") and vx_local or vy_local
    local error = vel_ref - vel_local

    -- Acumular error para Twiddle
    self.error_sum = self.error_sum + error^2
    self.error_count = self.error_count + 1

    -- Calcular acción de control
    local control = self.controller:update(vel_ref, vel_local)

    -- Enviar velocidad ajustada (solo en el eje indicado)
    local vx_cmd = (self.axis == "vx") and (vel_ref + control) or 0
    local vy_cmd = (self.axis == "vy") and (vel_ref + control) or 0
    send_velocity(id, team, vx_cmd, vy_cmd, 0)

    -- Ejecutar Twiddle cada 60 pasos
    if self.error_count >= 60 then
        if not self.twiddle:step() then
            print(string.format("%s gains: Kp=%.3f, Ki=%.3f", self.axis, self.controller.kp, self.controller.ki))
        end
    end
end

return PIDTuner
