local Button = require("ui.Button")

local FullscreenButton = Button:extend()

FullscreenButton.load = false
FullscreenButton.X = 14
FullscreenButton.Y = 0
FullscreenButton.SIZE = 16

function FullscreenButton:new()
	if not FullscreenButton.load then
		FullscreenButton.fullscreen = love.graphics.newImage("assets/ui/fullscreen.png")
		FullscreenButton.fullscreen:setFilter("linear", "nearest")

		FullscreenButton.window = love.graphics.newImage("assets/ui/window.png")
		FullscreenButton.window:setFilter("linear", "nearest")
		FullscreenButton.load = true
	end
	self.super.new(self, FullscreenButton.X, FullscreenButton.Y, 1)
	self.fullscreen = false
end

function FullscreenButton:action()
	self.fullscreen = not self.fullscreen
	love.window.setFullscreen(self.fullscreen)
end

function FullscreenButton:draw()
	self.super.draw(self)
	if self.fullscreen then
		love.graphics.draw(
			FullscreenButton.window,
			FullscreenButton.X,
			FullscreenButton.Y,
			0,
			1 / FullscreenButton.SIZE
		)
	else
		love.graphics.draw(
			FullscreenButton.fullscreen,
			FullscreenButton.X,
			FullscreenButton.Y,
			0,
			1/ FullscreenButton.SIZE
		)
	end
end

return FullscreenButton