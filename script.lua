print("Script initialized")

local Pass = require("tactics.pass")
local api  = require("sysmickit.lua_api")

-- Team & robot IDs
local team     = 0
local A, B, C  = 0, 1, 2

-- Where each should stand to receive
local posA     = { x = -1,  y =  0 }
local posB     = { x =  1,  y =  0 }
local posC     = { x =  0,  y =  1 }

-- One Pass instance for each leg
local passAB   = Pass.new()   -- A→B
local passBC   = Pass.new()   -- B→C
local passCA   = Pass.new()   -- C→A

-- 0 = A→B, 1 = B→C, 2 = C→A
local stage    = 0

function process()
    local tactic, from, to, target

    if stage == 0 then
      tactic, from, to, target = passAB, A, B, posB
    elseif stage == 1 then
      tactic, from, to, target = passBC, C, B, posC
    else  -- stage == 2
      tactic, from, to, target = passCA, A, C, posA
    end

    local done = tactic:process(from, to, team, target)
    if done then
      -- advance to next leg
      stage = (stage + 1) % 3

      -- re-create the fresh Pass instance for the leg we're about to run
      if stage == 0 then
          passAB = Pass.new()
      elseif stage == 1 then
          passBC = Pass.new()
      else
          passCA = Pass.new()
      end
    end
end
