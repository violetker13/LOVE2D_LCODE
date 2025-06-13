local Entity = require("Entities.Entity")
local Beam = require("Entities.Beam")


Player = setmetatable({}, {__index = Entity})
Player.__index = Player

function Player:new(x, y)
    local obj = Entity.new(self, x, y, 32, 32, 2)
    obj.speed = 200
    obj.color = {0, 1, 0}
    obj.maxHealth = 10
    obj.health = 10
    obj.isAlive = true
    obj.beams = {}
    obj.shootCooldown = 0.05
    obj.shootTimer = 0
    obj.damage = 1 -- ← базовый урон игрока
    return obj
end


function Player:addSpeed(x)
    self.speed = x + self.speed
end
function Player:addDamage(x)
    self.damage = self.damage + x
end





function Player:respawn(x, y)
    self.x = x or self.x
    self.y = y or self.y
    self.health = self.maxHealth
    self.isAlive = true
end

function Player:update(dt, enemies)
    local vx, vy = 0, 0

    if love.keyboard.isDown("w") then vy = vy - 1 end
    if love.keyboard.isDown("s") then vy = vy + 1 end
    if love.keyboard.isDown("a") then vx = vx - 1 end
    if love.keyboard.isDown("d") then vx = vx + 1 end

    local len = math.sqrt(vx * vx + vy * vy)
    if len > 0 then
        vx = vx / len
        vy = vy / len
    end

    local speed = self.speed
    local nx = self.x + vx * speed * dt
    local ny = self.y + vy * speed * dt

    nx = math.max(0, math.min(nx, self.W - self.width))
    ny = math.max(0, math.min(ny, self.H - self.height))

    self.x, self.y = nx, ny

    self.shootTimer = self.shootTimer - dt

    if love.mouse.isDown(1) and self.shootTimer <= 0 then
        local mx, my = love.mouse.getPosition()
        local wx = mx - love.graphics.getWidth()/2 + cam.x
        local wy = my - love.graphics.getHeight()/2 + cam.y

        local dx = wx - (self.x + self.width/2)
        local dy = wy - (self.y + self.height/2)
        local len = math.sqrt(dx*dx + dy*dy)

        if len > 0 then
            dx = dx / len
            dy = dy / len
            table.insert(self.beams, Beam:new(
                    self.x + self.width/2,
                    self.y + self.height/2,
                    dx, dy,
                    nil, nil,
                    self.damage
            ))
            self.shootTimer = self.shootCooldown
        end

    end


    for i = #self.beams, 1, -1 do
        local beam = self.beams[i]
        beam:update(dt, enemies)
        if beam:isDead() then
            table.remove(self.beams, i)
        end
    end




end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    local bw, bh = self.width, 6
    local bx, by = self.x, self.y - bh - 4
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", bx, by, bw * (self.health / self.maxHealth), bh)
    love.graphics.setColor(1, 1, 1)
    for _, beam in ipairs(self.beams) do
        beam:draw()
    end

end

return Player