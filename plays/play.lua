-- Play.lua
local Play = {}
Play.__index = Play

function Play.new(name)
  local self = setmetatable({}, Play)
  self.name = name or "Unnamed Play"
  self.roles = {}          -- map: role_id → behavior function
  self.stage = {}          -- map: role_id → integer stage
  self.opponent_roles = {} -- map: opponent_role_id → actual robot ID
  self.is_applicable = function() return true end
  self.should_terminate = function() return false end
  self.active = true
  return self
end

function Play:set_applicability(fn)
  self.is_applicable = fn
end

function Play:set_termination(fn)
  self.should_terminate = fn
end

function Play:assign_opponent_role(index, selector_fn)
  self.opponent_roles[index] = selector_fn()
end

function Play:add_role(role_id, behavior_fn)
  self.roles[role_id] = behavior_fn
  self.stage[role_id] = 0
end

function Play:reset()
  for role_id in pairs(self.roles) do
    self.stage[role_id] = 0
  end
  self.active = true
end

function Play:process()
  if not self.active then return end
  if self.should_terminate and self.should_terminate() then
    print("[Play] Terminated: " .. self.name)
    self.active = false
    self:reset()
    return
  end

  for role_id, behavior in pairs(self.roles) do
    behavior(role_id, self.stage, self.opponent_roles)
  end
end

return Play
