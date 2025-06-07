-- stp_parser.lua
local Play = require("plays.play")
local FileReader = require("sysmickit.file_reader")

local Pass = require("tactics.pass")
local ReceivePass = require("skills.pass_receiver")
local Shoot = require("skills.kick_to_point")

-- Mock API functions
local function get_closest_opponent_to_ball()
  print("[mock api] Returning dummy opponent ID: 2")
  return 1
end

local function is_in_offense(team)
  --print("[mock api] Assuming team " .. tostring(team) .. " is in offense.")
  return true
end

-- Parser function
local function parse_stp_file(filename, team)
  local play = nil
  local current_role = nil

  local reader = FileReader.new(filename)
  for line in reader:lines() do
    local trimmed = line:match("^%s*(.-)%s*$")

    if trimmed:match("^PLAY") then
      local name = trimmed:match("^PLAY%s+(.+)")
      play = Play.new(name)

    elseif trimmed:match("^APPLICABLE offense") then
      play:set_applicability(function()
        return is_in_offense(team)
      end)

    elseif trimmed:match("^DONE aborted !offense") then
      play:set_termination(function()
        return not is_in_offense(team)
      end)

    elseif trimmed:match("^ROLE%s+(%d+)") then
      current_role = tonumber(trimmed:match("^ROLE%s+(%d+)"))
      play.stage[current_role] = 0

    elseif trimmed == "END" then
      current_role = nil

    elseif current_role and play then
      local cmd, args = trimmed:match("^(%S+)%s+(.+)")
      if cmd == "pass" then
        local target_id = tonumber(args)
        if not target_id then
          error("Invalid target_id for pass command: " .. tostring(args))
        end

        play:add_role(current_role, function(id, stage)
          if stage[id] == 0 and Pass:process(id, target_id, team, {x=0,y=0}) then
            stage[id] = 1
          end
        end)

      elseif cmd == "receive_pass" then
        local x, y, radius = args:match("{([%d%-%.]+),%s*([%d%-%.]+)}%s+(%d+)")
        play:add_role(current_role, function(id, stage)
          if stage[id] == 0 then
            local done = ReceivePass.process(id, team, {
              center = { x = tonumber(x), y = tonumber(y) },
              radius = tonumber(radius)
            })
            if done then
              stage[id] = 1
            end
          end
        end)

      elseif cmd == "shoot" then
        local x, y = args:match("{([%d%-%.]+),%s*([%d%-%.]+)}")
        play:add_role(current_role, function(id, stage)
          if stage[id] == 1 then
            Shoot(id, team, { x = tonumber(x), y = tonumber(y) })
          end
        end)
      end
    end
  end

  reader:close()
  return play
end

return parse_stp_file
