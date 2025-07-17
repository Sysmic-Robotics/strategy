-- Utilizar para cuando los enemigos tengan la pelota en su lado

local Robot = require("sysmickit.robot")
local FieldPerspective = require("sysmickit.fieldperspective")
local TDefendZone = require("tactics.TDefendZone")
local Baile = {}

Baile.__index = Baile

function Baile.new(team_setting)
    local self = setmetatable({}, Baile)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Id de robots del campo
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end

    self.time = 0
    self.toggle = false

    return self
end

function Baile:process()
    self.time = self.time + 1

    -- Every 60 frames (~1 second at 60fps), switch direction
    if self.time % 60 == 0 then
        self.toggle = not self.toggle
    end

    -- Choose target point based on toggle state
    local target = self.toggle and { x = 3.0, y = 0 } or { x = -3.0, y = 0 }

    for _, robot in ipairs(self.robots) do
        robot:Aim(target)
    end
end

return Baile
