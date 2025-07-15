local Robot = require("sysmickit.robot")
local Engine = require("sysmickit.engine")
local utils = require("sysmickit.utils")

local TMoveClearArea = {}
TMoveClearArea.__index = TMoveClearArea

--- Create a new clear area movement tactic.
--- @param robotId number
--- @param team number
--- @param searchRegion table {x_min, x_max, y_min, y_max}
function TMoveClearArea.new(robotId, team, searchRegion)
    local robot = Robot.new(robotId, team)

    return setmetatable({
        robot = robot,
        team = team,
        region = searchRegion,
        targetPos = nil,
        searchTries = 30,
        safeRadius = 0.8
    }, TMoveClearArea)
end

function TMoveClearArea:findClearPosition()
    local others = {}
    local teammates, opponents

    if self.team == 0 then
        teammates = Engine.get_blue_team_state()
        opponents = Engine.get_yellow_team_state()
    else
        teammates = Engine.get_yellow_team_state()
        opponents = Engine.get_blue_team_state()
    end

    -- Add all opponents
    for _, robot in ipairs(opponents) do
        if robot.active then
            table.insert(others, robot)
        end
    end

    -- Add teammates except self
    for _, robot in ipairs(teammates) do
        if robot.active and robot.id ~= self.robot.id then
            table.insert(others, robot)
        end
    end

    -- Try finding a clear spot
    for _ = 1, self.searchTries do
        local candidate = {
            x = math.random() * (self.region.x_max - self.region.x_min) + self.region.x_min,
            y = math.random() * (self.region.y_max - self.region.y_min) + self.region.y_min
        }

        local clear = true
        for _, other in ipairs(others) do
            if utils.distance(candidate, other) < self.safeRadius then
                clear = false
                break
            end
        end

        if clear then
            return candidate
        end
    end

    return nil
end

function TMoveClearArea:process()
    if not self.targetPos then
        self.targetPos = self:findClearPosition()
    end

    if self.targetPos then
        return self.robot:Move(self.targetPos)
    else
        return false
    end
end

return TMoveClearArea
