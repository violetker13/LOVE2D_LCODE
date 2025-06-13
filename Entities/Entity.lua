Entity = {}
Entity.__index = Entity

function Entity:new(x, y, w,h, zIndex)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.width = w or 32
    obj.height = h or 32
    obj.size = {w or 32, h or 32}  -- Добавлено для совместимости с Player
    obj.zIndex = zIndex or 0
    obj.maxHealth = 100
    obj.health = 100
    obj.speed = 0
    obj.TILE = 16
    obj.W = 256 * obj.TILE
    obj.H = 256 * obj.TILE  -- Исправлено с L на H
    return obj
end

function Entity:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Entity:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Entity:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self:die()
    end
end

function Entity:die()
    self.isAlive = false
end

function Entity:respawn(x, y)
    self.x = x or self.x
    self.y = y or self.y
    self.health = self.maxHealth
    self.isAlive = true
end

return Entity
