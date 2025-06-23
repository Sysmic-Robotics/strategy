print("Script initialized")

local api = require("sysmickit.lua_api")

robotId = 0
team = 0
point = {
    x= 0.0 , y=0.0
}
kp_vel = 0.5
ki_vel = 0.01

function process()
  api.motion(robotId, team, point, kp_vel, ki_vel)
   --api.move_to(robotId, team, point)
  --send_velocity(robotId,team,0.0,0.0,0.9)
end
