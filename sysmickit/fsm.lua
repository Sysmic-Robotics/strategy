local FSM = {}
FSM.__index = FSM

-- Create a new FSM
function FSM.new(initial_state, fsm_name, debug)
    local self = setmetatable({}, FSM)
    self.states = {}
    self.fsm_name = fsm_name
    self.current = initial_state
    self.debug = debug or false
    self.done_state = nil  -- Name of the single done state
    return self
end

-- Enable or disable debug mode
function FSM:set_debug(enabled)
    self.debug = enabled
end

-- Set the single terminal state
function FSM:set_done_state(name)
    self.done_state = name
end

-- Check if FSM is in the terminal state
function FSM:is_done()
    return self.current == self.done_state
end

-- Add a new state
function FSM:add_state(name, state_table)
    self.states[name] = state_table
end

-- Transition to a new state
function FSM:change_state(name)
    if self.states[name] == nil then
        error("\n FSM: Unknown state: " .. tostring(name))
    end
    if self.debug then
        print(self.fsm_name .. " Transitioning from '" .. tostring(self.current) .. "' to '" .. name .. "'")
    end
    if self.current and self.states[self.current].on_exit then
        self.states[self.current].on_exit()
    end
    self.current = name
    if self.states[self.current].on_enter then
        self.states[self.current].on_enter()
    end
end

-- Update the FSM
function FSM:update(...)
    local state = self.states[self.current]
    if state and state.update then
        state.update(self, ...)
    end
end

-- Get current state name
function FSM:get_state()
    return self.current
end

return FSM