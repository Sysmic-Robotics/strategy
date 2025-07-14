local TPassBallTo = require("tactics.TPassBallTo")
local TReceivePass = require("tactics.TReceivePass")

local PPass = {}
PPass.__index = PPass

function PPass.new()
    local self = setmetatable({
        pass_tactic = TPassBallTo.new(),
        receive_tactic = TReceivePass.new(),
        roles = { [0] = 0, [1] = 1 }, -- Asigna los IDs como necesites
        pass_point = { x = 2.0, y = 0.0 },
        state = "preparando_pase"
    }, PPass)
    return self
end

function PPass:process(game_state)
    local passer_id = self.roles[0]
    local receiver_id = self.roles[1]
    local team = game_state.team or 0

    if self.state == "preparando_pase" then
        local pass_ok = self.pass_tactic:process(passer_id, team, self.pass_point)
        -- El receptor SOLO espera y se orienta, no captura
        self.receive_tactic:process(receiver_id, team, self.pass_point, false)
        if pass_ok then
            self.state = "esperando_recepcion"
        end
        return false
    end

    if self.state == "esperando_recepcion" then
        -- Ahora el receptor sí puede capturar
        local received = self.receive_tactic:process(receiver_id, team, self.pass_point, true)
        if received then
            self.state = "hecho"
            return true
        end
        return false
    end

    if self.state == "hecho" then
        return true
    end
    return false
end

function PPass:reset()
    self.pass_tactic:reset()
    self.receive_tactic:reset()
    self.state = "preparando_pase"
end

function PPass:is_done()
    return self.state == "hecho"
end

function PPass:assign_roles(roles_table)
    self.roles = roles_table
end

return PPass
