local Engine = require("sysmickit.engine")
local robot_id = 0
local team = 0

local function rand_range(a, b)
    return a + (b - a) * math.random()
end

local V_MAX = 2.0       -- max linear speed (m/s)
local OMEGA_MAX = 5.5   -- max angular speed (rad/s)
local MAX_FRAMES = 120

local function get_new_vels()
    local vx_rand     = rand_range(-V_MAX, V_MAX)
    local vy_rand     = rand_range(-V_MAX, V_MAX)
    local omega_rand  = rand_range(-OMEGA_MAX, OMEGA_MAX)
    return {vx_rand, vy_rand, omega_rand}
end
local vels = get_new_vels()
local function random_process()
    Engine.send_velocity(robot_id, team, vels[1], vels[2], vels[3])
end

local TEST_FRAMEWORK = require("test_framework")

local test_framework = TEST_FRAMEWORK.new(robot_id, team, random_process)
local frames = 0

function process()
    test_framework:process()
    if frames > MAX_FRAMES then
        vels = get_new_vels()
        frames = 0
    end
    frames = frames + 1
end
