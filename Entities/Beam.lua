local Beam = {}
Beam.__index = Beam

local MathUtils = require("utils.MathUtils")

function Beam:new(x, y, dirX, dirY, length, duration, damage)
    local obj = setmetatable({}, Beam)
    obj.x = x
    obj.y = y
    obj.dirX = dirX
    obj.dirY = dirY
    obj.length = length or 500
    obj.duration = duration or 0.05
    obj.timer = obj.duration
    obj.damage = damage or 1 -- ← использовать переданный урон
    return obj
end


function Beam:checkHit(enemy)
    local beamEndX = self.x + self.dirX * self.length
    local beamEndY = self.y + self.dirY * self.length

    local dist = MathUtils.distanceToSegment(
            enemy.x + enemy.width / 2,  -- Центр врага
            enemy.y + enemy.height / 2,
            self.x, self.y,
            beamEndX, beamEndY
    )
    return dist <= (enemy.radius or 16)
end

function Beam:update(dt, enemies)
    self.timer = self.timer - dt

    for _, enemy in ipairs(enemies) do
        if enemy.isAlive and self:checkHit(enemy) then
            enemy:takeDamage(self.damage)
        end
    end
end

function Beam:isDead()
    return self.timer <= 0
end

function Beam:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.setLineWidth(3)
    love.graphics.line(
            self.x, self.y,
            self.x + self.dirX * self.length,
            self.y + self.dirY * self.length
    )
    love.graphics.setLineWidth(1)
end

return Beam
