local Robot = require("sysmickit.robot")

local RDefendPos = {}
RDefendPos.__index = RDefendPos

function RDefendPos.new(team_setting)
    local self = setmetatable({}, RDefendPos)
    self.team = team_setting.team
    self.robots_ids = team_setting.robots_ids
    self.play_side = team_setting.play_side or "left"
    self.robots = {}
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, self.team)
    end
    return self
end

function RDefendPos:process()
    local positions = {
        {x = -2.5, y =  0},
        {x = -1.5, y =  0.0},
        {x = -1.5, y =  1.3},
        {x = -1.5, y = -1.3},
        {x = -0.8, y = 0},
    }
    if self.play_side == "right" then
        for i, pos in ipairs(positions) do
            pos.x = -pos.x
        end
    end

    for i, robot in ipairs(self.robots) do
        if positions[i] then
            robot:MoveDirect(positions[i])
        end
    end
end

return RDefendPos



