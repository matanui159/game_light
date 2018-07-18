local Button = require("ui.Button")

local CloseButton = Button:extend()

CloseButton.X = 15
CloseButton.Y = 0

function CloseButton:new()
	self.super.new(self, CloseButton.X, CloseButton.Y, 1)
end

function CloseButton:action()
	love.event.quit()
end

function CloseButton:draw()
	self.super.draw(self)
	love.graphics.setColor(1, 0, 0)
	love.graphics.setLineWidth(0.1)

	love.graphics.line(
		CloseButton.X + 0.3,
		CloseButton.Y + 0.3,
		CloseButton.X + 0.7,
		CloseButton.Y + 0.7
	)

	love.graphics.line(
		CloseButton.X + 0.7,
		CloseButton.Y + 0.3,
		CloseButton.X + 0.3,
		CloseButton.Y + 0.7
	)

	love.graphics.setColor(1, 1, 1)
end

return CloseButton