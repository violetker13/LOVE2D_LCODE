local Entity = require("Entities.Entity")

Enemy = setmetatable({}, {__index = Entity})
Enemy.__index = Enemy

function Enemy:new(x, y)
    local obj = Entity.new(self, x, y, 32, 32, 1)
    obj.speed = 100
    obj.color = {0, 0, 0}
    obj.maxHealth = 100
    obj.health = 100
    obj.damage = 10
    obj.attackCD = 0.1
    obj.cdTimer = 0
    obj.radius = 20
    obj.isAlive = true
    return obj
end

function Enemy:update(dt, player)
    if self.isAlive then
        local ex = self.x + self.size[1]/2
        local ey = self.y + self.size[2]/2
        local px = player.x + player.size[1]/2
        local py = player.y + player.size[2]/2

        local dx = px - ex
        local dy = py - ey
        local dist = math.sqrt(dx*dx + dy*dy)


        if dist > 0 then
            local vx, vy = dx/dist, dy/dist
            local nx = self.x + vx * self.speed * dt
            local ny = self.y + vy * self.speed * dt

            if dist > math.sqrt(self.size[1]+self.size[2])/2 + 10 then
                self.x = nx
                self.y = ny
            end

        end


        local attackRadius = self.size[1]/2 + 60
        if dist <= attackRadius then
            self.cdTimer = self.cdTimer - dt
            if self.cdTimer <= 0 then
                player:takeDamage(self.damage * dt)
                self.cdTimer = self.attackCD
            end
        else
            self.cdTimer = 0
        end
    end

end
function Enemy:takeDamage(amount)
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
function Enemy:draw()
    if self.isAlive then
        love.graphics.setColor(1, 0, 0, 0.2)
        local bw, bh = self.width, 6
        local bx, by = self.x, self.y - bh - 4
        love.graphics.circle("fill",
                self.x + self.size[1]/2,
                self.y + self.size[2]/2,
                math.sqrt(self.size[1]+self.size[2])/2 + 60
        )
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.size[1], self.size[2])
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", bx, by, bw * (self.health / self.maxHealth), bh)
        love.graphics.setColor(1, 1, 1)
    end

end

return Enemy
