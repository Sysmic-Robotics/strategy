print("Combined motion test for system ID / neural network initialized")

local robot_id = 0
local team = 0

-- === CONFIGURABLE PARAMETERS ===
local A_vx = 1.0      -- Amplitude for vx
local A_vy = 0.7      -- Amplitude for vy
local A_omega = 2.0   -- Amplitude for angular velocity

local f_vx = 0.2      -- Frequency for vx
local f_vy = 0.3      -- Frequency for vy
local f_omega = 0.4   -- Frequency for omega

local t0 = os.clock()

function process()
    local t = os.clock() - t0

    -- Generate smooth, sinusoidal input signals
    local vx = A_vx * math.sin(2 * math.pi * f_vx * t)
    local vy = A_vy * math.sin(2 * math.pi * f_vy * t)
    local omega = A_omega * math.sin(2 * math.pi * f_omega * t)

    -- Send to robot
    send_velocity(robot_id, team, vx, vy, omega)

    -- Optional logging for debugging
end