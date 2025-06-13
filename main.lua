local Player = require("Entities.Player")
local Enemy  = require("Entities.Enemy")
local Editor = require("Editor")
local Button = require("Button")

local TILE = 16
local W, H = 256 * TILE, 256 * TILE

local myfont

local heartBaseSize = 32

local heartPulseSpeed = 4
local heartX, heartY
local world = {}


cam = { x = 0, y = 0, followRadius = 0, speed = 2 }

local isFadingIn = false
local isFadingOut = false
local fadeAlpha = 0
local fadeSpeed = 0.5

local panning, panSX, panSY, mSX, mSY = false, 0, 0, 0, 0
local editor, player, enemy, btnRespawn

function getRandomWorldPosition()
    local x = love.math.random(0, W - 1)  -- -1 чтобы не выйти за границы
    local y = love.math.random(0, H - 1)
    return x, y
end
enemyWave = 1
enemies = {}

function spawnEnemies(count)
    enemies = {}
    for i = 1, count do
        local x, y = getRandomWorldPosition()
        table.insert(enemies, Enemy:new(x, y))
    end
end

spawnEnemies(enemyWave)


function updateCamera(dt, player)
    local px = player.x + player.size[1] / 2
    local py = player.y + player.size[2] / 2

    local dx = px - cam.x
    local dy = py - cam.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > cam.followRadius then
        local dirX = dx / dist
        local dirY = dy / dist
        local moveDist = (dist - cam.followRadius) * cam.speed * dt
        cam.x = cam.x + dirX * moveDist
        cam.y = cam.y + dirY * moveDist
    end


    cam.x = math.max(love.graphics.getWidth()/2, math.min(cam.x, W - love.graphics.getWidth()/2))
    cam.y = math.max(love.graphics.getHeight()/2, math.min(cam.y, H - love.graphics.getHeight()/2))
end

function love.load()

    love.window.setTitle("Game + Editor")
    myfont = love.graphics.newFont("assets/font.ttf", 24)
    love.graphics.setFont(myfont)

    for j = 1, 256 do
        world[j] = {}
        for i = 1, 256 do
            world[j][i] = { r = love.math.random(), g = love.math.random(), b = love.math.random() }
        end
    end

    editor = Editor:new()
    player = Player:new(W/2, H/2)

    btnRespawn = Button:new(
            love.graphics.getWidth()/2 - 100,
            love.graphics.getHeight()/2 - 20,
            200, 40,
            "Возродиться",
            function()
                player:respawn(getRandomWorldPosition())
                player.isAlive = true
            end,
            3
    )

    cam.x = player.x + player.size[1]/2
    cam.y = player.y + player.size[2]/2
end

function love.update(dt)
    if editor.mode == "play" then
        if player.isAlive then
            player:update(dt, enemies)
            updateCamera(dt, player)

            for i = #enemies, 1, -1 do
                local e = enemies[i]
                e:update(dt, player)
                if not e.isAlive then
                    table.remove(enemies, i)
                end
            end

            if #enemies == 0 then
                enemyWave = enemyWave * 2
                spawnEnemies(enemyWave)

                -- 🟢 Усиление игрока при новой волне:
                player:addSpeed(20)     -- +20 к скорости
                player:addDamage(1)     -- +1 к урону
            end

        else
            if isFadingOut then
                fadeAlpha = fadeAlpha + fadeSpeed * dt
                if fadeAlpha >= 1 then
                    fadeAlpha = 1
                    isFadingOut = false
                end
            elseif isFadingIn then
                fadeAlpha = fadeAlpha - fadeSpeed * dt
                if fadeAlpha <= 0 then
                    fadeAlpha = 0
                    isFadingIn = false
                end
            end
            local mx, my = love.mouse.getPosition()
            btnRespawn:update(mx, my)
        end
    else
        editor:update(dt)
    end

    local time = love.timer.getTime()
    local scale = 1 + math.sin(time * heartPulseSpeed) * 0.1

    heartX = btnRespawn.x - heartBaseSize * scale - 10
    heartY = btnRespawn.y + (btnRespawn.height - heartBaseSize * scale) / 2


end


function love.draw()
    if player.isAlive then
        love.graphics.push()
        love.graphics.translate(

                love.graphics.getWidth()/2 - cam.x,
                love.graphics.getHeight()/2 - cam.y
        )

        for j = 1, 256 do
            for i = 1, 256 do
                local t = world[j][i]
                local gray = (t.r + t.g + t.b) / 3
                love.graphics.setColor(gray, gray, gray)
                love.graphics.rectangle("fill", (i-1)*TILE, (j-1)*TILE, TILE, TILE)
            end
        end

        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", 0, 0, W, H)

        editor:draw()
        player:draw()
        for _, e in ipairs(enemies) do
            e:draw()
        end


        love.graphics.setColor(1,1,1,0.3)
        love.graphics.circle("line", cam.x, cam.y, cam.followRadius + 70)

        love.graphics.pop()
    else
        btnRespawn:draw()

        local text = "Вы умерли"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textX = btnRespawn.x + (btnRespawn.width - textWidth) / 2
        local textY = btnRespawn.y - 30 -- 30 пикселей выше кнопки

        love.graphics.setColor(1, 0, 0) -- красный цвет
        love.graphics.print(text, textX, textY)


    end

    if fadeAlpha > 0 then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)


    end
    love.graphics.setColor(1, 1, 1) -- белый цвет
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.mousepressed(x, y, btnNum)

    if not player.isAlive and btnNum == 1 then
        btnRespawn:mousepressed(x, y, btnNum)
        return
    end

end

function love.mousereleased(x, y, btnNum)
    if btnNum == 2 then panning = false end
end

function love.keypressed(key)
    editor:keypressed(key)
end
