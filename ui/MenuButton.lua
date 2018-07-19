local Button = require("ui.Button")
local MenuScene = require("scene.MenuScene")

local MenuButton = Button:extend()

function MenuButton:new(font)
	MenuButton.super.new(self, 15, 0, 1)
	self.font = font
end

function MenuButton:action()
	if scene.menu then
		scene.menu = nil
	else
		scene.menu = MenuScene(self.font)
	end
end

function MenuButton:draw()
	MenuButton.super.draw(self)
	love.graphics.setLineWidth(0.1)

	if scene.menu then
		love.graphics.line(15.25, 0.25, 15.75, 0.75)
		love.graphics.line(15.75, 0.25, 15.25, 0.75)
	else
		love.graphics.line(15.25, 0.3, 15.75, 0.3)
		love.graphics.line(15.25, 0.5, 15.75, 0.5)
		love.graphics.line(15.25, 0.7, 15.75, 0.7)
	end
	love.graphics.setColor(1, 1, 1)
end

return MenuButton