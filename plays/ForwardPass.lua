-- Play to advance with a coordinate pass to the goalie box

local TCoordinatePass = require("tactics.TCoordinatedPass")
local TKickToGoal     = require("tactics.TKickToGoal")
local Play            = {}
Play.__index          = Play

local PASS_REGION = {
    x_min = 0,
    x_max = 4.5,
    y_min = -3.0,
    y_max = 3.0
}

function Play.new()
    return setmetatable({
        name        = "ForwardPass",
        role_ids    = {},
        state       = "init",
        successful  = false,
    }, Play)
end

function Play:is_applicable(game_state)
    return game_state.in_offense and not game_state.aborted
end

function Play:is_done(game_state)
    return not game_state.in_offense or game_state.aborted or self.successful
end

function Play:assign_roles(roles)
    self.role_ids = roles
end

function Play:process(game_state)
    local id0 = self.role_ids[0]
    local id1 = self.role_ids[1]
    if not id0 or not id1 then return end

    if self.state == "init" then
        self.pass_tactic  = TCoordinatePass.new()
        self.shoot_tactic = TKickToGoal.new()
        self.state = "pass"
    end

    if self.state == "pass" then
        local pass_done = self.pass_tactic:process(id0, id1, game_state.team, PASS_REGION)
        if pass_done then
            self.successful = true
        end
    end
end

return Play
