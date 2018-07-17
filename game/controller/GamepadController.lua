local Controller = require("game.controller.Controller")

local GamepadController = Controller:extend()

function GamepadController:new(gamepad)
	self.super.new(self)
	self.gamepad = gamepad
end

function GamepadController:join()
	return self.gamepad:isGamepadDown("a")
end

function GamepadController:update()
	local move = self.move
	move.x = self.gamepad:getGamepadAxis("leftx")
	move.y = self.gamepad:getGamepadAxis("lefty")
	
	local len = math.sqrt(move.x * move.x + move.y * move.y)
	if len < 0.2 then
		move.x = 0
		move.y = 0
	end
end

return GamepadController