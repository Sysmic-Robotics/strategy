local PBasic221Global = require("plays.PBasic221")
local PCoordinatedAttack = require("plays.PCoordinatedAttack")
local TGoalkeeper      = require("tactics.TGoalkeeper")

-- Estado global de juego (ejemplo)
local game_state = {
    team = 0,        -- 0 para azul, 1 para amarillo
    in_offense = true,
    in_defense = false,
    aborted = false,
}

local TEAM_SETTING = {
    team  = 0,
    goalkeeper_id = 0
}

local goal_keeper = TGoalkeeper.new(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
-- Instanciar la play defensiva y ofensiva
--local defensive_play = PBasic221Global.new(game_state.team)
--local offensive_play = PCoordinatedAttack.new(game_state.team)

function process()
    goal_keeper:process(TEAM_SETTING.goalkeeper_id, TEAM_SETTING.team)
    --[[
    if game_state.in_defense then
        local finished_defense = defensive_play:process(game_state)
        if finished_defense then
            game_state.in_offense = true
            game_state.in_defense = false
            -- Reinicia la ofensiva por si acaso
            offensive_play = PCoordinatedAttack.new(team)
        end
    elseif game_state.in_offense then
        local finished_offense = offensive_play:process(game_state)
        if finished_offense then
            game_state.in_defense = true
            game_state.in_offense = false
            -- Reinicia la defensiva por si acaso
            defensive_play = PBasic221Global.new(game_state.team)
        end
    end
    --]]
end
