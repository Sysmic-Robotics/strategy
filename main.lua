local SCaptureBall = require("skills.SCaptureBall")
-- Initialize FSM to move robot 0 of team 0 to (1.5, -2.0)
local robot_id = 0
local team_id = 0

-- Optional: enable debug messages
local capture_ball = SCaptureBall.new(robot_id, team_id)
function process()
    capture_ball:update()
end