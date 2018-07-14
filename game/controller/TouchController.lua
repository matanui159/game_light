local Controller = require("game.controller.Controller")

local TouchController = Controller:extend()

function TouchController:update()
	local touch = love.touch.getTouches(touch)[1]
	if touch then
		local x, y = love.touch.getPosition(touch)
		self.move.x = x - love.graphics.getWidth() / 2
		self.move.y = y - love.graphics.getHeight() / 2
	end
end

return TouchController