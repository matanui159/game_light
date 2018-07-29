local Controller = require("game.controller.Controller")

local GamepadController = Controller:extend()

function GamepadController:new(gamepad)
	GamepadController.super.new(self)
	self.gamepad = gamepad
end

function GamepadController:join()
	return self.gamepad:isGamepadDown("a", "start")
end

function GamepadController:leave()
	return self.gamepad:isGamepadDown("b", "back")
end

function GamepadController:update(menu)
	GamepadController.super.update(self, menu)

	if not menu then
		local move = self.move
		move.x = self.gamepad:getGamepadAxis("leftx")
		move.y = self.gamepad:getGamepadAxis("lefty")
		
		local len = math.sqrt(move.x * move.x + move.y * move.y)
		if len < 0.2 then
			move.x = 0
			move.y = 0
		end

		local attack = self.attack
		attack.x = self.gamepad:getGamepadAxis("rightx")
		attack.y = self.gamepad:getGamepadAxis("righty")
		
		local len = math.sqrt(attack.x * attack.x + attack.y * attack.y)
		if len < 0.2 then
			attack.x = 0
			attack.y = 0
		end
	end
end

return GamepadController