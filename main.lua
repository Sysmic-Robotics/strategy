local Defense221 = require("routines.Defense221")
local TGoalkeeper  = require("tactics.TGoalKeeper")
local TDefendZone = require("tactics.TDefendZone")
local FieldZones = require("sysmickit.fieldzones")


-- Estado global de juego (ejemplo)
local world_class = require("sysmickit.world")


local TEAM_SETTING = {
    team  = 1,
    goalkeeper_id = 0,
    robots_ids = {1,2,3,4},
    play_side = "left"
}

local team_color = (TEAM_SETTING.team == 0) and "blue" or "yellow"
WORLD = world_class.new(team_color)

local game_state = {
    in_offense = true,
    in_defense = false,
    ref_command = "FORCE_START",
}

-- Instanciar la play defensiva y ofensiva

local defensive_play = Defense221.new(TEAM_SETTING)

function process()
    WORLD:process()
    TGoalkeeper.process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team, TEAM_SETTING.play_side)
    defensive_play:process()
    --TDefendZone:process(0,TEAM_SETTING.team, FieldZones.ZONE_0)

end
