local Button = require("ui.Button")
local MenuScene = require("scene.MenuScene")

local MenuButton = Button:extend()

function MenuButton:new()
	self.super.new(self, 15, 0, 1)
end

function MenuButton:action()
	scene.menu = MenuScene
end

function MenuButton:draw()
	self.super.draw(self)
	love.graphics.setLineWidth(0.1)
	love.graphics.line(15.25, 0.3, 15.75, 0.3)
	love.graphics.line(15.25, 0.5, 15.75, 0.5)
	love.graphics.line(15.25, 0.7, 15.75, 0.7)
	love.graphics.setColor(1, 1, 1)
end

return MenuButton