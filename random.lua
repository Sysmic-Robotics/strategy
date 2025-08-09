local Engine = require("sysmickit.engine")
local robot_id = 0
local team = 0

local function rand_range(a, b)
    return a + (b - a) * math.random()
end

local V_MAX = 3.0       -- max linear speed (m/s)
local OMEGA_MAX = 5.5   -- max angular speed (rad/s)

local function random_process() 
    local vx_rand     = rand_range(-V_MAX, V_MAX)
    local vy_rand     = rand_range(-V_MAX, V_MAX)
    local omega_rand  = rand_range(-OMEGA_MAX, OMEGA_MAX)

    Engine.send_velocity(robot_id, team, vx_rand, vy_rand, omega_rand)
end

local TEST_FRAMEWORK = require("test_framework")
local test_framework = TEST_FRAMEWORK.new(robot_id, team, random_process)
function process()
    test_framework:process()
end
