-- Editor.lua
local Editor = {}
Editor.__index = Editor

function Editor:new()
    local self = setmetatable({},Editor)
    self.mode = "play"        -- "play" или "edit"
    self.objects = {}         -- { {type="enemy"/"block", x=..,y=..}, ... }
    self.selected = "enemy"
    return self
end

function Editor:update(dt)
    -- можно обновлять объекты при редактировании
end

function Editor:draw()
    if self.mode=="edit" then
        love.graphics.setColor(1,1,1)
        love.graphics.print("MODE: EDIT (TAB)", 10,10)
        love.graphics.print("Tool: "..self.selected.."  [1]Enemy [2]Block", 10,30)
        for _,o in ipairs(self.objects) do
            if o.type=="enemy" then love.graphics.setColor(1,0,0)
            else love.graphics.setColor(0.5,0.5,0.5) end
            love.graphics.rectangle("fill", o.x,o.y, 30,30)
        end
        love.graphics.setColor(1,1,1)
    else
        love.graphics.setColor(1,1,1)
        love.graphics.print("MODE: PLAY  (TAB)", 10,10)
    end
end

function Editor:keypressed(key)
    if key=="tab" then
        self.mode = (self.mode=="play") and "edit" or "play"
    elseif key=="1" then
        self.selected = "enemy"
    elseif key=="2" then
        self.selected = "block"
    end
end

function Editor:mousepressed(x,y,btn)
    if self.mode=="edit" and btn==1 then
        -- привязка к сетке 30px
        local gx,gy = x - x%30, y - y%30
        table.insert(self.objects, { type=self.selected, x=gx, y=gy })
    end
end

return Editor
