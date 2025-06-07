-- tactics/passer.lua
local api  = require("sysmickit.lua_api")
local aim  = require("skills.aim")
local kick = require("skills.kick_to_point")

local passer = {}
passer.__index = passer

--- Crea una instancia de la táctica de pase.
function passer.new()
  return setmetatable({
    state = "aiming",
  }, passer)
end

--- Ejecuta la táctica para un robot que realiza un pase.
-- @param robot_id number ID del robot que pasa
-- @param team number  ID del equipo
-- @param target table coordenadas { x = ..., y = ... } donde se desea pasar
-- @return boolean true si debe seguir ejecutándose, false si terminó
function passer:process(robot_id, team, target)
  local robot = api.get_robot_state(robot_id, team)
  if not robot or not robot.active then
    print("[Passer] Robot inactivo")
    return false
  end

  if self.state == "aiming" then
    local still_aiming = aim.process(robot_id, team, target, "fast")
    if not still_aiming then
      self.state = "kicking"
    end
    return true

  elseif self.state == "kicking" then
    local still_kicking = kick(robot_id, team, target)
    if not still_kicking then
      print("[Passer] Pase ejecutado ✔️")
      return false -- Táctica completada
    end
    return true
  end

  return false
end

return passer
