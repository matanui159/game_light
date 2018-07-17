local Controller = require("game.controller.Controller")

local KeyboardController = Controller:extend()

function KeyboardController:join()
	return love.keyboard.isDown("space")
end

function KeyboardController:update()
	self.move.x = 0
	if love.keyboard.isDown("a") then
		self.move.x = self.move.x - 1
	end
	if love.keyboard.isDown("d") then
		self.move.x = self.move.x + 1
	end

	self.move.y = 0
	if love.keyboard.isDown("w") then
		self.move.y = self.move.y - 1
	end
	if love.keyboard.isDown("s") then
		self.move.y = self.move.y + 1
	end
end

return KeyboardController