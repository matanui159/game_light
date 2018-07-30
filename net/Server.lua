local Client = require("net.Client")

local Map = require("game.Map")
local Player = require("game.Player")

local BotController = require("game.controller.BotController")
local RemoteController = require("game.controller.RemoteController")

local Server = Client:extend()

Server.PORT = 2852

function Server:new()
	Server.super.new(self, Server.PORT)
	for _, player in ipairs(self.players) do
		player.controller = BotController(self.map, player)
	end
	self:newGame()
end

function Server:sendMap(peer)
	self:send({
		p = 0,
		a = "m",
		m = self.map.name
	}, peer)
end

function Server:newGame()
	self.map = Map(self.world, "test")
	self:sendMap()

	for i, player in ipairs(self.players) do
		local x = 1.5
		if i % 2 == 0 then
			x = 14.5
		end

		local y = 1.5
		if i >= 3 then
			y = 7.5
		end

		player.body:setPosition(x, y)
		player.lerp.health = 1
		self:send({
			p = i,
			a = "p",
			x = x,
			y = y,
			h = 1
		})

		if player.peer then
			player.ignore = true
		end

		local controller = player.controller
		if controller:is(BotController) then
			controller.map = self.map
		end
	end
end

function Server:isRemote(player)
	if player.ignore then
		return false
	else
		return Server.super.isRemote(self, player)
	end
end

function Server:isLocal()
	return true
end

function Server:connect(peer)
	self:sendMap(peer)
end

function Server:disconnect(peer)
	for i, player in ipairs(self.players) do
		if player.peer == peer then
			self:receive({
				p = i,
				a = "-"
			}, peer)
		end
	end
end

function Server:receive(data, peer)
	local player = self.players[data.p]

	if data.a == "-" then
		player.controller = BotController(self.map, player)
		player.peer = nil
		player.ignore = false
	end

	if data.a == "p" then
		if peer == player.peer then
			player.ignore = false
		end
	elseif data.a == "+" then
		for i, player in ipairs(self.players) do
			if player.controller:is(BotController) then
				player.peer = peer
				player.controller = RemoteController()

				self:send({
					p = i,
					a = "+"
				}, peer)
				break
			end
		end
	else
		Server.super.receive(self, data, peer)
	end
end

function Server:update(dt)
	Server.super.update(self, dt)
	if self:gameOver() then
		self:newGame()
	end
end

return Server