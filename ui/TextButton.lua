local Button = require("ui.Button")

local TextButton = Button:extend()

function TextButton:new(font, text, x, y, width)
	TextButton.super.new(self, x, y, width)
	self.font = font
	self.text = text
end

function TextButton:draw()
	TextButton.super.draw(self)
	self.font:print(self.text, self.x, self.y, self.width)
	love.graphics.setColor(1, 1, 1)
end

return TextButton