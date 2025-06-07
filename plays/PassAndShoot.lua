-- plays/PassAndShoot.lua
local TCoordinatePass = require("tactics.TCoordinatedPass")  -- Or your pass tactic module
local TKickToGoal = require("tactics.TKickToGoal")      -- Your goal-kick tactic module

local Play = {}
Play.__index = Play

function Play.new()
    return setmetatable({
        name = "PassAndShoot",
        role_ids = {},           -- Assigned robot roles
        state = "init",
    }, Play)
end

--- Called by the play manager to check if this play should be active
function Play:is_applicable(game_state)
    return game_state.in_offense and not game_state.aborted
end

--- Called to check whether this play is completed or should be stopped
function Play:is_done(game_state)
    return not game_state.in_offense or game_state.aborted
end

--- Assign role IDs to be used by this play
--- @param roles table { [0] = robot_id_0, [1] = robot_id_1, ... }
function Play:assign_roles(roles)
    self.role_ids = roles
end

--- Run the play for one simulation/control cycle
--- @param game_state table
function Play:process(game_state)
    local id0 = self.role_ids[0]
    local id1 = self.role_ids[1]

    if not id0 or not id1 then
        print("[PassAndShoot] Role IDs not assigned!")
        return
    end

    if self.state == "init" then
        self.pass_tactic = TCoordinatePass:new()
        self.shoot_tactic = TKickToGoal:new()
        self.state = "pass"
    end

    if self.state == "pass" then
        local pass_done = self.pass_tactic:process(id0, id1, game_state.team, { x = -4.5, y = 0 })
        if pass_done then
            print("[PassAndShoot] Pass completed, switching to shoot.")
            self.state = "shoot"
        end
    elseif self.state == "shoot" then
        self.shoot_tactic:process(id1, game_state.team)
    end
end

return Play