-- Escenario: Solo robots 0, 1 y 2 de cada equipo activos
-- Los demás (3 a 10) son "desactivados" moviéndolos fuera del campo

-- Equipo azul (team = 0)
grsim.teleport_robot(0, 0, -2,  0, 0)
grsim.teleport_robot(1, 0, -2,  1, 0)
grsim.teleport_robot(2, 0, -2, -1, 0)

for id = 3, 10 do
    grsim.teleport_robot(id, 0, 100, 100, 0) -- Desactivados fuera del campo
end

-- Equipo amarillo (team = 1)
grsim.teleport_robot(0, 1,  2,  0, 3.14)
grsim.teleport_robot(1, 1,  2,  1, 3.14)
grsim.teleport_robot(2, 1,  2, -1, 3.14)

for id = 3, 10 do
    grsim.teleport_robot(id, 1, 100, 100, 0) -- Desactivados fuera del campo
end

-- Posición inicial de la pelota
grsim.teleport_ball(0, 0)