
local RobotClass = require("sysmickit.robot")
local utils = require("sysmickit.utils")
local robot = RobotClass.new(1,0)
local Engine = require("sysmickit.engine")
function process()
    --[[
    local ball =  Engine.get_ball_state()
    local robot = Engine.get_robot_state(0,0)
    if utils.has_captured_ball(robot, ball) then
        print("true")
    end
    ]]
    if robot:CaptureBall() then
        print("true")
    end
end
