local Engine = require("sysmickit.engine")

-- Simple Lua "class"
local RobotController = {}
RobotController.__index = RobotController

function RobotController.new(robot_id, team, behavior)
    local self = setmetatable({}, RobotController)

    -- IDs
    self.robot_id = robot_id or 0
    self.team = team or 0

    -- State & tunables
    self.STATE = "RETURNING"
    self.FIELD = { xmin = -1.5, xmax = 1.5, ymin = -1.0, ymax = 1.0 }
    self.NEAR_R = 0.1

    -- Seed RNG once (varied by id/team)
    math.randomseed(os.time() + self.robot_id * 97 + self.team * 131)

    -- Default behavior: random velocities (you can override below or via :set_behavior)
    self.behavior = behavior

    return self
end


function RobotController:out_of_bounds(state)
    if not state then return false end
    local f = self.FIELD
    return state.x < f.xmin or state.x > f.xmax
        or state.y < f.ymin or state.y > f.ymax
end

function RobotController:is_near_origin(state)
    if not state then return false end
    local x, y, r = state.x or 0, state.y or 0, self.NEAR_R
    return (x * x + y * y) <= (r * r)
end

function RobotController:process()
    if self.STATE == "RETURNING" then
        Engine.move_to(self.robot_id, self.team, { x = 0, y = 0 })
        local s = Engine.get_robot_state(self.robot_id, self.team)
        if self:is_near_origin(s) then
            self.STATE = "PLAYING"
        end
        return
    end

    -- PLAYING: run your custom behavior
    self.behavior()

    -- Safety: if we wander out, go back to RETURNING
    local s = Engine.get_robot_state(self.robot_id, self.team)
    if self:out_of_bounds(s) then
        self.STATE = "RETURNING"
    end
end

return RobotController

