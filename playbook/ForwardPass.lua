-- Play to advance with a coordinate pass to the goalie box

local TCoordinatePass = require("tactics.TCoordinatedPass")
local TKickToGoal = require("tactics.TKickToGoal")
local RoleSelector = require("playbook.RoleSelection")
local TGoalKeeper = require("tactics.TGoalKeeper")

local Play            = {}
Play.__index          = Play

function Play.new(team)
    return setmetatable({
        name        = "Forward pass",
        role_ids    = {},
        state       = "init",
        successful  = false,
        team = team,
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

function Play:process()
    if self.state == "init" then
        -- Select roles

        local roles = RoleSelector.assign_by_proximity_to_ball(self.team, {0,1,2}, 0)
        self.assign_roles(roles)
        -- Sequence 0
        self.sequence0_pass = TCoordinatePass.new(roles[1], roles[2], self.team, {x_min = 0, x_max = 4.5, y_min = -3.0, y_max = 3.0})
        self.goali = TGoalKeeper.new()

        -- When pass is done go to sequence 1
        self.sequence1_kick = TKickToGoal.new(roles[1], self.team)
        self.state = "pass"
    end
    --self.goali:process(self.role_ids[0], self.team)

    if self.state == "pass" then
        local pass_done = self.sequence0_pass:process()
        if pass_done then
            self.state = "shoot"
        end
    end

    if self.state == "shoot" then
        local shoot_done = self.sequence1_kick:process()
        if shoot_done then
            return true
        end
    end

end

return Play
