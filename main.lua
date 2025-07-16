local Defense221 = require("routines.Defense221")
local TGoalkeeper  = require("tactics.TGoalKeeper")
-- Estado global de juego (ejemplo)

local TEAM_SETTING = {
    team  = 1,
    goalkeeper_id = 5,
    robots_ids = {0,1,2,3,4},
    play_side = "left"
}

local game_state = {
    in_offense = true,
    in_defense = false,
    ref_command = "FORCE_START",
}

-- Instanciar la play defensiva y ofensiva

local defensive_play = Defense221.new(TEAM_SETTING)

local goal_keeper = TGoalkeeper.new(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
function process()
    goal_keeper:process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
    defensive_play:process()
end
