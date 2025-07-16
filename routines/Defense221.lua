local utils = require("sysmickit.utils")
local Robot = require("sysmickit.robot")
local FieldZones = require("sysmickit.fieldzones")
local Vector2D = require("sysmickit.vector2D")
local Engine = require("sysmickit.engine")

--Plays
local DefensiveZonePlay = require("plays.DefensiveZonePlay")
local MidfieldZonePlay = require("plays.MidfieldZonePlay")
local OffensiveZonePlay = require("plays.OffensiveZonePlay")

local Defense221 = {}
Defense221.__index = Defense221

function Defense221.new(team_setting)
    local self = setmetatable({}, Defense221)
    self.team = team_setting.team
    self.robots = {}
    self.robots_ids = team_setting.robots_ids -- Debe traer SOLO los 5 robots de campo (sin arquero)
    for i, id in ipairs(self.robots_ids) do
        self.robots[i] = Robot.new(id, team_setting.team)
    end
    self.done = false
    return self
end

function Defense221:process()
    local ball = Engine.get_ball_state()
    if not ball then return end

    if FieldZones.is_in_zone(ball, FieldZones.LEFT_ABOVE)
    or FieldZones.is_in_zone(ball, FieldZones.LEFT_BELOW) then
        DefensiveZonePlay.run(self.robots, ball, self.team)
        return
    end

    if FieldZones.is_in_zone(ball, FieldZones.MIDFIELD) then
        MidfieldZonePlay.run(self.robots, ball, self.team)
        return
    end

    if FieldZones.is_in_zone(ball, FieldZones.RIGHT_ABOVE)
    or FieldZones.is_in_zone(ball, FieldZones.RIGHT_BELOW) then
        OffensiveZonePlay.run(self.robots, ball, self.team)
        return
    end

end

return Defense221