local Controller = require("game.controller.Controller")

local BotController = Controller:extend()

function BotController:new(world, map, all_players, player)
	BotController.super.new(self)
	self.world = world
	self.map = map
	self.all_players = all_players
	self.player = player
	self.timer = 0
	self.pos = {
		x = math.floor(player.lerp.x),
		y = math.floor(player.lerp.y)
	}
	self:bot()
end

function BotController:sign(val)
	if val < 0 then
		return -1
	else
		return 1
	end
end

function BotController:getPlayers(callback)
	for i, player in ipairs(self.all_players) do
		if player ~= self.player and player.lerp.health > 0 then
			callback(player)
		end
	end
end

function BotController:getClosest()
	local close = {}
	self:getPlayers(function(player)
		local dx = player.lerp.x - self.player.lerp.x
		local dy = player.lerp.y - self.player.lerp.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if not close.dist or dist < close.dist then
			close.dist = dist
			close.dx = dx
			close.dy = dy
		end
	end)
	return close
end

function BotController:setMove(x, y)
	if x == -self.move.x and y == -self.move.y then
		return false
	elseif self.map:getTile(self.pos.x + x, self.pos.y + y) then
		return false
	else
		self.move.x = x
		self.move.y = y
		return true
	end
end

function BotController:update()
	local x = math.floor(self.player.lerp.x)
	local y = math.floor(self.player.lerp.y)
	if x ~= self.pos.x or y ~= self.pos.y then
		self.pos.x = x
		self.pos.y = y
		self:bot()
	end

	self.timer = self.timer + 1
	if self.timer == 10 then
		local close = {}
		self:getPlayers(function(player)
			local hit = true
			self.world:rayCast(
				self.player.lerp.x,
				self.player.lerp.y,
				player.lerp.x,
				player.lerp.y,
				function(fixture)
					if fixture:getUserData() ~= player then
						hit = false
					end
					return -1
				end
			)

			if hit then
				local dx = player.lerp.x - self.player.lerp.x
				local dy = player.lerp.y - self.player.lerp.y
				local dist = math.sqrt(dx * dx + dy * dy)
				if not close.dist or dist < close.dist then
					close.dist = dist
					close.dx = dx
					close.dy = dy
					close.player = player
				end
			end
		end)

		if close.player then
			local angle = math.atan2(close.dy, close.dx) + math.random() / 5 - 0.1
			self.attack.x = math.cos(angle)
			self.attack.y = math.sin(angle)
		else
			self.attack.x = 0
			self.attack.y = 0
		end

		self.timer = 0
	end
end

function BotController:damage(x, y)
	self:bot(x, y)
end

function BotController:bot(x, y)
	local mx, my = self:randomBot()
	if x == nil or y == nil then
		local count = 0
		self:getPlayers(function()
			count = count + 1
		end)

		if count == 1 then
			if math.random(2) == 1 then
				mx, my = self:attackBot()
			end
		elseif count > 0 then
			if self.player.index <= 2 then
				mx, my = self:attackBot()
			elseif self.player.index == 3 then
				mx, my = self:defendBot()
			end
		end
	else
		self:setMove(0, 0)
		mx = self.player.lerp.x - x
		my = self.player.lerp.y - y
	end

	local use_x = math.random() * (mx + my) < my
	mx = self:sign(mx)
	my = self:sign(my)

	if use_x and self:setMove(mx, 0) then
	elseif self:setMove(0, my) then
	elseif not use_x and self:setMove(mx, 0) then
	elseif use_x and self:setMove(0, -my) then
	elseif self:setMove(-mx, 0) then
	elseif not use_x and self:setMove(0, -my) then
	else
		self.move.x = -self.move.x
		self.move.y = -self.move.y
	end
end

function BotController:attackBot()
	local close = self:getClosest()
	return close.dx, close.dy
end

function BotController:defendBot()
	local close = self:getClosest()
	return -close.dx, -close.dy
end

function BotController:randomBot()
	return math.random() - 0.5, math.random() - 0.5
end

return BotController