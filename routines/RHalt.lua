-- Utilizar para cuando los enemigos tengan la pelota en su lado

local Robot = require("sysmickit.robot")

local HALT = {}

HALT.__index = HALT

function HALT.new(team_setting)
    local self = setmetatable({}, HALT)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Id de robots del campo
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end

    return self
end

function HALT:process()
    -- Two defenders back
    self.robots[1]:Stop()
    self.robots[2]:Stop()
    self.robots[3]:Stop()
    self.robots[4]:Stop()
end

return HALT
