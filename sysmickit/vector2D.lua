local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2D)
end

function Vector2D:__add(v)
    return Vector2D.new(self.x + v.x, self.y + v.y)
end

function Vector2D:__sub(v)
    return Vector2D.new(self.x - v.x, self.y - v.y)
end

function Vector2D:__mul(scalar)
    return Vector2D.new(self.x * scalar, self.y * scalar)
end

function Vector2D:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

-- Use for fast computations
function Vector2D:length_squared()
    return self.x * self.x + self.y * self.y
end

function Vector2D:normalized()
    local len = self:length()
    if len == 0 then
        return Vector2D.new(0, 0)
    end
    return self * (1 / len)
end

function Vector2D:__tostring()
    return string.format("Vector2D(%.2f, %.2f)", self.x, self.y)
end

function Vector2D:dot(other)
    return self.x * other.x + self.y * other.y
end

--- Get the angle (in radians) between this vector and another.
-- Positive result means counterclockwise from self to other.
-- @param other Vector2D
-- @return number angle in radians
function Vector2D:angle_to(other)
    local dot = self:dot(other)
    local det = self.x * other.y - self.y * other.x -- 2D determinant
    if dot == 0 then
        return 0
    end
    return math.atan(det, dot)
end

function Vector2D:cross(other)
    return self.x * other.y - self.y * other.x
end



return Vector2D
