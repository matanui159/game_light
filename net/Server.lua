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
		player.controller = BotController()
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

	for index, player in ipairs(self.players) do
		local x = 1.5
		if index % 2 == 0 then
			x = 14.5
		end

		local y = 1.5
		if index >= 3 then
			y = 7.5
		end

		player.body:setPosition(x, y)
		self:send({
			p = index,
			a = "p",
			x = x,
			y = y
		})
	end
end

function Server:isLocal()
	return true
end

function Server:connect(peer)
	self:sendMap(peer)
end

function Server:disconnect(peer)
	for _, player in ipairs(self.players) do
		if player.peer == peer then
			player.controller = BotController()
			player.peer = nil
		end
	end
end

function Server:receive(data, peer)
	if data.a == "+" then
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

return Server