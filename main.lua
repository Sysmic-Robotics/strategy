local Defense221 = require("routines.Defense221")
local TGoalkeeper  = require("tactics.TGoalKeeper")
local HaltPlay = require("routines.RHalt")
local RBallPlacement = require("routines.RBallPlacement")
-- Estado global de juego (ejemplo)
local world_class = require("sysmickit.world")
local Engine = require("sysmickit.engine")
local FieldZone = require("sysmickit.fieldzones")
local REFEERE_TO_GAME_STATE = require("sysmickit.referee_play_translator")
local utils = require("sysmickit.utils")
local Robot = require("sysmickit.robot")
local OurKickOff = require("routines.OurKickOff")
local TheirKickOff = require("routines.TheirKickOff")
local Baile = require("routines.Baile")

local TEAM_SETTING = {
    team  = 0,
    goalkeeper_id = 0,
    robots_ids = {3,2,1,4},
    play_side = "left"
}

local team_color = (TEAM_SETTING.team == 0) and "blue" or "yellow"
WORLD = world_class.new(team_color)

local in_offense = true
local in_defense = false

--  Play
local defensive_play = Defense221.new(TEAM_SETTING)

-- Special cases
local our_kick_off = OurKickOff.new(TEAM_SETTING)
local their_kick_off = TheirKickOff.new(TEAM_SETTING)
local halt = HaltPlay.new(TEAM_SETTING)
local ball_placement_play = RBallPlacement.new(TEAM_SETTING)
local baile = Baile.new(TEAM_SETTING)

local game_state = "PLAY"
local ref_command = "HALT"
function process()
    WORLD:process()
    ref_command = Engine.get_ref_message()
    game_state = REFEERE_TO_GAME_STATE.referee_play_translator(ref_command, TEAM_SETTING)
    if game_state == "PLAY" then
        -- Aqui las plays normales
        TGoalkeeper.process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team, TEAM_SETTING.play_side)
        --defensive_play:process()
    elseif game_state == "TIME_OUT" then
        baile:process()
    elseif game_state == "BALL_PLACEMENT" then
        ball_placement_play:process()
    elseif game_state == "OUR_PREPARE_KICK_OFF" then
        -- DEFEND OUR SIDE
        our_kick_off:process()
    elseif game_state == "THEIR_PREPARE_KICK_OFF" then
        -- TO THEIR SIDE
        their_kick_off:process()
    elseif game_state == "NORMAL_START" then
        local robot_in_center = utils.get_robot_in_center_circle(WORLD:get_allies())
        if not (robot_in_center == nil) then
            local robot = Robot.new(robot_in_center.id, robot_in_center.team)
            robot:PivotKick({x=0,y=-1})
        end
    elseif game_state == "HALT" then
        halt:process()
    end

    

end