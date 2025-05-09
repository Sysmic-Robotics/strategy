print("Script initialized")


--local mark = require("skills.mark")
local kick = require("skills.kick_to_point")
local intercept = require("skills.intercept")
local Pass = require("tactics.pass")
local api = require("sysmickit.lua_api")

local team   = 0
local A, B   = 0, 1
local posA   = { x = -1, y = 0.0 }
local posB   = { x =  1, y = 0.0 }

local passAB = Pass.new()
local passBA = Pass.new()
local stage  = 0           -- 0: use passAB, 1: passBA


function process()
  local tactic, from, to, target
  if stage == 0 then
    tactic = passAB
    from, to, target = A, B, posB
  else
    tactic = passBA
    from, to, target = B, A, posA
  end

  local done = tactic:process(from, to, team, target)
  if done then
      -- swap stage *and* get a fresh new instance if you prefer
      stage = 1 - stage
      -- you can also reset by recreating it:
      if stage == 0 then
        passAB = Pass.new()
      else
        passBA = Pass.new()
      end
  end
end