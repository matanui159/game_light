local Button = require("ui.Button")
local MenuScene = require("scene.MenuScene")

local MenuButton = Button:extend()

function MenuButton:new(scene, font)
	MenuButton.super.new(self, scene, 15, 0, 1)
	self.font = font
end

function MenuButton:action()
	if self.scene.menu then
		self.scene.menu = nil
	else
		self.scene.menu = MenuScene(self.scene, self.font)
	end
end

function MenuButton:draw()
	MenuButton.super.draw(self)
	love.graphics.setLineWidth(0.1)

	if self.scene.menu then
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