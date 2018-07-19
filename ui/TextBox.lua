local TextButton = require("ui.TextButton")

local TextBox = TextButton:extend()

function TextBox:new(font, place, x, y, width)
	TextBox.super.new(self, font, "", x, y, width)
	self.place = place
	self.input = ""
end

function TextBox:update()
	if love.timer.getTime() % 2 < 1 then
		self.text = self.input .. " "
	else
		self.text = self.input .. "_"
	end
end

function TextBox:draw()
	TextBox.super.draw(self)
	if self.input == "" then
		love.graphics.setColor(1, 1, 1, 0.2)
		self.font:print(self.place, self.x, self.y, self.width)
		love.graphics.setColor(1, 1, 1)
	end
end

function TextBox:textinput(text)
	if text == "\b" then
		self.input = self.input:sub(1, -2)
	else
		self.input = self.input .. text
	end
end

return TextBox