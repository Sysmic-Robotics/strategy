local Defense221 = require("routines.Defense221")
local TGoalkeeper  = require("tactics.TGoalKeeper")
local TDefendZone = require("tactics.TDefendZone")
local FieldZones = require("sysmickit.fieldzones")
local HaltPlay = require("routines.RHalt")
local Engine = require("sysmickit.engine")
local RefereePlay = require("sysmickit.referee_play_translator")
local RBallPlacement = require("routines.RBallPlacement")
-- Estado global de juego (ejemplo)
local world_class = require("sysmickit.world")


local TEAM_SETTING = {
    team  = 0,
    goalkeeper_id = 0,
    robots_ids = {0,1,2,3,4,5},
    play_side = "left"
}

local team_color = (TEAM_SETTING.team == 0) and "blue" or "yellow"
WORLD = world_class.new(team_color)

local game_state = {
    in_offense = true,
    in_defense = false
}

-- Instanciar la play defensiva y ofensiva

local defensive_play = Defense221.new(TEAM_SETTING)
local halt = HaltPlay.new(TEAM_SETTING)
local ball_placement_play = RBallPlacement.new(TEAM_SETTING)

local ref_command = "BALL_PLACEMENT"
function process()
    --WORLD:process()
    --ref_command = Engine.get_ref_message()
    if ref_command == "PLAY" then
        -- Aqui las plays normales
        TGoalkeeper.process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team, TEAM_SETTING.play_side)
        defensive_play:process()
    elseif ref_command == "BALL_PLACEMENT" then
        ball_placement_play:process()
    end

    

end
