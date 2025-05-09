print("Script initialized")


--local mark = require("skills.mark")
local kick = require("skills.kick_to_point")
local intercept = require("skills.intercept")
local pass = require("tactics.pass")
local api = require("sysmickit.lua_api")
team = 0

function process()
  pass.pass(0, 1, team, { x = 0.0, y = 0.0 })
end
