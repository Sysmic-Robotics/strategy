--[[
    twiddle.lua
    ------------------------------
    Implementación del algoritmo Twiddle (búsqueda coordinada)
    para ajuste automático de un controlador PI (Proporcional–Integral).

    Este algoritmo busca minimizar un error (por ejemplo, el error cuadrático medio
    entre la referencia y la salida del sistema) ajustando los parámetros Kp y Ki.

    USO:
        local Twiddle = require("twiddle")
        local twiddle = Twiddle:new(controller, get_error_func, {Kp_inicial, Ki_inicial}, {dKp, dKi}, tolerancia)

        -- Dentro del ciclo principal:
        local terminado = twiddle:step()
        if terminado then
            print("Ajuste de PID completado.")
        end

    ARGUMENTOS:
        controller        → Objeto del controlador que debe tener un método set_gains(kp, ki)
        get_error_func    → Función que devuelve el error actual acumulado (ej. error cuadrático medio)
        initial_gains     → Tabla con valores iniciales de {Kp, Ki}
        dp                → Tabla con incrementos iniciales {dKp, dKi} para explorar
        tolerance         → Valor mínimo de la suma de dp para considerar que el ajuste ha terminado

    FUNCIONAMIENTO:
        - El algoritmo prueba aumentar o disminuir uno de los parámetros (Kp o Ki)
        - Si el error mejora, se guarda el cambio y se aumenta dp
        - Si el error empeora, se revierte el cambio y se disminuye dp
        - Se repite hasta que dp[1] + dp[2] < tolerance

    MÉTODOS:
        Twiddle:new(...)         → Constructor del objeto
        Twiddle:step()           → Ejecuta un paso del algoritmo
        Twiddle:next_param()     → Internamente, cambia al siguiente parámetro a ajustar

    NOTAS:
        - Se puede extender fácilmente para incluir Kd (control derivativo)
        - Ideal para robots o sistemas donde no se dispone de un modelo matemático preciso
]]

local Twiddle = {}
Twiddle.__index = Twiddle

function Twiddle:new(controller, get_error_func, initial_gains, dp, tolerance)
    return setmetatable({
        controller = controller,
        get_error = get_error_func,
        p = {table.unpack(initial_gains)},
        dp = {table.unpack(dp)},
        best_err = math.huge,
        tolerance = tolerance or 0.001,
        i = 1,
        state = "init",
    }, self)
end


function Twiddle:step()
    if (self.dp[1] + self.dp[2]) < self.tolerance then
        return true  -- Tuning complete
    end

    local i = self.i
    local p = self.p
    local dp = self.dp
    local err

    if self.state == "init" then
        p[i] = p[i] + dp[i]
        self.controller:set_gains(p[1], p[2])
        self.state = "first_test"
    elseif self.state == "first_test" then
        err = self.get_error()
        if err < self.best_err then
            self.best_err = err
            dp[i] = dp[i] * 1.1
            self:next_param()
        else
            p[i] = p[i] - 2 * dp[i]
            self.controller:set_gains(p[1], p[2])
            self.state = "second_test"
        end
    elseif self.state == "second_test" then
        err = self.get_error()
        if err < self.best_err then
            self.best_err = err
            dp[i] = dp[i] * 1.1
        else
            p[i] = p[i] + dp[i]
            dp[i] = dp[i] * 0.9
        end
        self:next_param()
    end

    return false  -- Tuning still in progress
end

function Twiddle:next_param()
    self.i = self.i % 2 + 1  -- switch between kp (1) and ki (2)
    self.state = "init"
end

return Twiddle
