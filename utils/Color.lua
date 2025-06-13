-- Color.lua
local Color = {}
Color.__index = Color

-- r,g,b,a — числа 0..1
function Color:new(r, g, b, a)
    local self = setmetatable({}, Color)
    self.r = r or 1
    self.g = g or 1
    self.b = b or 1
    self.a = a or 1
    return self
end

function Color:set()
    love.graphics.setColor(self.r, self.g, self.b, self.a)
end

return Color
