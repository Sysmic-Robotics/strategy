local Defense221 = require("routines.Defense221")
local TGoalkeeper      = require("tactics.TGoalkeeper")
local Engine = require("sysmickit.engine")
-- Estado global de juego (ejemplo)

local TEAM_SETTING = {
    team  = 0,
    goalkeeper_id = 5,
    robots_ids = {0,1,2,3},
}

local game_state = {
    team = 0,        -- 0 para azul, 1 para amarillo
    in_offense = true,
    in_defense = false,
    aborted = false,
    ref_command = "FORCE_START",
}

-- Instanciar la play defensiva y ofensiva

local defensive_play = Defense221.new(TEAM_SETTING)

--local offensive_play = PCoordinatedAttack.new(game_state.team)

local goal_keeper = TGoalkeeper.new(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
function process()
    goal_keeper:process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
    defensive_play:process()
    if game_state.in_defense then
        --if finished_defense then
        --    game_state.in_offense = true
        --    game_state.in_defense = false
            -- Reinicia la ofensiva por si acaso
        --    offensive_play = PCoordinatedAttack.new(team)
        --end
    elseif game_state.in_offense then
        --[[
        local finished_offense = offensive_play:process(game_state)
        if finished_offense then
            game_state.in_defense = true
            game_state.in_offense = false
            -- Reinicia la defensiva por si acaso
            defensive_play = PBasic221Global.new(game_state.team)
        end
        ]]--
    end
end
