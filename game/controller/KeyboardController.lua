local Controller = require("game.controller.Controller")

local KeyboardController = Controller:extend()

function KeyboardController:new(scene)
	KeyboardController.super.new(self)
	self.scene = scene
end

function KeyboardController:join()
	return love.keyboard.isDown("return") or love.keyboard.isDown("space")
end

function KeyboardController:leave()
	return love.keyboard.isDown("escape") or love.keyboard.isDown("backspace")
end

function KeyboardController:update(menu, player)
	KeyboardController.super.update(self, menu)

	if not menu then
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

		local attack = self.attack
		if love.mouse.isDown(1) then
			local tx, ty, scale = self.scene:calcTransform()
			attack.x = (love.mouse.getX() - tx) / scale - player.lerp.x
			attack.y = (love.mouse.getY() - ty) / scale - player.lerp.y
		else
			attack.x = 0
			attack.y = 0
		end
	end
end

return KeyboardController