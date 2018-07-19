local TextButton = require("ui.TextButton")

local SelectButton = TextButton:extend()

function SelectButton:new(font, x, y, width, options, default)
	SelectButton.super.new(self, font, options[default], x, y, width)
	self.options = options
	self.index = default
end

function SelectButton.change(index)
end

function SelectButton:action()
	self.index = self.index + 1
	if self.index > #self.options then
		self.index = 1
	end
	self.text = self.options[self.index]
	self.change(self.index)
end

return SelectButton