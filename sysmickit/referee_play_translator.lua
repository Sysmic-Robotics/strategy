local RHalt = require("routines.RHalt")
local RStop = require("routines.RStop")
local RDefendPos = require("routines.RDefendPos")
local RKickoffWait = require("routines.RKickOff")
local RBallPlacement = require("routines.RBallPlacement")

local M = {}

function M.referee_play_translator(ref_command, team_setting)
    local my_team = team_setting.team  

    if ref_command == "HALT" then
        return RHalt.new(team_setting)

    elseif ref_command == "STOP" then
        return RStop.new(team_setting)

    elseif ref_command == "BALL_PLACEMENT_YELLOW" then
        if my_team == 1 then
            return RBallPlacement.new(team_setting)
        else
            return RBallPlacement.new(team_setting)
        end

    elseif ref_command == "BALL_PLACEMENT_BLUE" then
        if my_team == 0 then
            return RBallPlacement.new(team_setting)
        else
            return RBallPlacement.new(team_setting)
        end

    elseif ref_command == "PREPARE_KICKOFF_YELLOW" then
        if my_team == 1 then
            return RKickoffWait.new(team_setting)
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "PREPARE_KICKOFF_BLUE" then
        if my_team == 0 then
            return RKickoffWait.new(team_setting)
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "PREPARE_PENALTY_YELLOW" then
        return RDefendPos.new(team_setting)

    elseif ref_command == "PREPARE_PENALTY_BLUE" then
        return RDefendPos.new(team_setting)

    elseif ref_command == "DIRECT_FREE_YELLOW" then
        if my_team == 1 then
            return nil
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "DIRECT_FREE_BLUE" then
        if my_team == 0 then
            return nil
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "INDIRECT_FREE_YELLOW" then
        if my_team == 1 then
            return nil
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "INDIRECT_FREE_BLUE" then
        if my_team == 0 then
            return nil
        else
            return RDefendPos.new(team_setting)
        end

    elseif ref_command == "TIMEOUT_YELLOW" then
        return RDefendPos.new(team_setting)

    elseif ref_command == "TIMEOUT_BLUE" then
        return RDefendPos.new(team_setting)

    elseif ref_command == "GOAL_YELLOW" then
        return RDefendPos.new(team_setting)

    elseif ref_command == "GOAL_BLUE" then
        return RDefendPos.new(team_setting)

    else
        return nil  
    end
end

return M
