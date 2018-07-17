local Controller = require("game.controller.Controller")

local KeyboardController = Controller:extend()

function KeyboardController:join()
	return love.keyboard.isDown("return") or love.keyboard.isDown("space")
end

function KeyboardController:update()
	local move = self.move

	move.x = 0
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		move.x = move.x - 1
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		move.x = move.x + 1
	end

	move.y = 0
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		move.y = move.y - 1
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		move.y = move.y + 1
	end
end

return KeyboardController