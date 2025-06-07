-- tactics/receiver.lua
local api           = require("sysmickit.lua_api")
local pass_receiver = require("skills.pass_receiver")

local receiver = {}
receiver.__index = receiver

--- Crea una nueva instancia de la táctica de recepción.
function receiver.new()
  return setmetatable({
    state = "waiting",
  }, receiver)
end

--- Ejecuta la táctica de recepción para el robot especificado.
-- @param robot_id number ID del robot receptor
-- @param team number ID del equipo
-- @return boolean true si debe seguir ejecutándose, false si terminó
function receiver:process(robot_id, team)
  local robot = api.get_robot_state(robot_id, team)
  if not robot or not robot.active then
    print("[Receiver] Robot inactivo")
    return false
  end

  if self.state == "waiting" then
    local still_receiving = pass_receiver.process(robot_id, team)
    if not still_receiving then
      print("[Receiver] Pase recibido correctamente 🧲")
      return false -- Táctica completada
    end
    return true
  end

  return false
end

return receiver
