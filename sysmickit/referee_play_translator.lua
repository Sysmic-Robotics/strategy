local M = {}

function M.referee_play_translator(ref_command, team_setting)
    local my_team = team_setting.team

    if ref_command == "HALT" then
        return "HALT"
    elseif ref_command == "STOP" then
        return "STOP"
    elseif ref_command == "FORCE_START" then
        return "PLAY"
    elseif ref_command == "NORMAL_START" then
        return "NORMAL_START"
    elseif ref_command == "PREPARE_KICKOFF_YELLOW" then
        if my_team == 1 then
            return "OUR_PREPARE_KICK_OFF"
        else
            return "THEIR_PREPARE_KICK_OFF"
        end
    
    elseif ref_command == "PREPARE_KICKOFF_BLUE" then
        if my_team == 0 then
            return "OUR_PREPARE_KICK_OFF"
        else
            return "THEIR_PREPARE_KICK_OFF"
        end
    elseif ref_command == "PREPARE_KICKOFF_YELLOW" then
        if my_team == 1 then
            return "OUR_PREPARE_KICK_OFF"
        else
            return "THEIR_PREPARE_KICK_OFF"
        end
    elseif ref_command == "TIME_OUT_BLUE" then
        return "TIME_OUT"
    elseif ref_command == "TIME_OUT_YELLOW" then
        return "TIME_OUT"
    else
        return "PLAY"
    end

end


return M