local Controller = require("game.controller.Controller")

local BotController = Controller:extend()

function BotController:new(map, player)
	BotController.super.new(self)
	self.map = map
	self.player = player
	self.pos = {
		x = math.floor(player.lerp.x),
		y = math.floor(player.lerp.y)
	}
	self:bot()
end

function BotController:setMove(x, y)
	if x == -self.move.x and y == -self.move.y then
		return false
	elseif self.map:getTile(self.pos.x, self.pos.y) then
		return false
	else
		self.move.x = x
		self.move.y = y
	end
end

function BotController:update()
	local x = math.floor(player.lerp.x)
	local y = math.floor(player.lerp.y)
	if x ~= self.pos.x or y ~= self.pos.y then
		self.pos.x = x
		self.pos.y = y
		self:bot()
	end
end

function BotController:bot()
	local mx, my = self:randomBot()
	local use_x = math.random() * (mx + my) < my
	local mx = mx / math.abs(mx)
	local my = my / math.abs(my)
	if use_x then
		-- TODO: see if there is a sign function in standard lua
	
	else
	end
end

function BotController:randomBot()
	return math.random() - 0.5, math.random() - 0.5
end

return BotController