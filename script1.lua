local FaceMove = require("skills.face_ball_while_move")
local mover = FaceMove.new({ x = 0.0, y = -0.8 })

function process()
    return mover:process(0, 0)
end
