-- Button.lua
local Button = {}
Button.__index = Button
local Color = require("utils.Color")

local styles = {
    { bg=Color:new(0.2,0.4,0.8), hover=Color:new(0.3,0.6,1), border=Color:new(1,1,1), text=Color:new(1,1,1) },
    { bg=Color:new(0.4,0.2,0.2), hover=Color:new(0.8,0.3,0.3), border=Color:new(1,1,1), text=Color:new(1,0.9,0.9) },
    { bg=Color:new(0.1,0.1,0.1), hover=Color:new(0.3,0.3,0.3), border=Color:new(0.7,0.7,0.7), text=Color:new(0.9,0.9,0.9) },
    { bg=Color:new(0,0.5,0),   hover=Color:new(0.2,0.8,0.2), border=Color:new(1,1,1), text=Color:new(1,1,1) },
    { bg=Color:new(0.8,0.8,0), hover=Color:new(1,1,0.2), border=Color:new(0.4,0.4,0.4), text=Color:new(0,0,0) }
}

function Button:new(x,y,w,h,text,onClick,styleIndex)
    local self = setmetatable({},Button)
    self.x,self.y,self.width,self.height = x,y,w,h
    self.text,self.onClick = text,onClick
    self.hovered,self.pressed = false,false
    self.style = styles[styleIndex] or styles[1]
    return self
end

function Button:update(mx,my)
    self.hovered = mx>=self.x and mx<=self.x+self.width
            and my>=self.y and my<=self.y+self.height
end

function Button:draw()
    -- фон
    (self.hovered and self.style.hover or self.style.bg):set()
    love.graphics.rectangle("fill",self.x,self.y,self.width,self.height,10,10)
    -- рамка
    self.style.border:set()
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line",self.x,self.y,self.width,self.height,10,10)
    -- текст
    self.style.text:set()
    local f=love.graphics.getFont()
    local tw,th = f:getWidth(self.text),f:getHeight()
    love.graphics.print(self.text,
            self.x+(self.width-tw)/2,
            self.y+(self.height-th)/2)
end

function Button:mousepressed(mx,my,btn)
    if btn==1 and self.hovered then self.onClick() end
end

return Button
