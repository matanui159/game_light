local Controller = require("game.controller.Controller")

local KeyboardController = Controller:extend()

function KeyboardController:join()
	return love.keyboard.isDown("space")
end

function KeyboardController:update()
	self.move.x = 0
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		self.move.x = self.move.x - 1
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		self.move.x = self.move.x + 1
	end

	self.move.y = 0
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		self.move.y = self.move.y - 1
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		self.move.y = self.move.y + 1
	end
end

return KeyboardController