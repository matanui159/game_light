local Client = require("net.Client")

local Map = require("game.Map")
local Player = require("game.Player")

local BotController = require("game.controller.BotController")
local RemoteController = require("game.controller.RemoteController")

local Server = Client:extend()

Server.PORT = 2852

function Server:new()
	self.super.new(self, "*:" .. Server.PORT)
	for _, player in ipairs(self.players) do
		player.controller = BotController()
	end
	self:newGame()
end

function Server:mapData()
	return love.data.pack("string", ">Bc1s", 0, "m", self.map.name)
end

function Server:newGame()
	self.map = Map(self.world, "test")
	self.host:broadcast(self:mapData())
	for index, player in ipairs(self.players) do
		local x = 1.5
		if index % 2 == 0 then
			x = 14.5
		end

		local y = 1.5
		if index >= 3 then
			y = 7.5
		end

		player.body:setPosition(x * 100, y * 100)
		local data = love.data.pack("string", ">Bc1nnnnnB",
			index, "p",
			x,
			y,
			0,
			0,
			1,
			1
		)
	end
end

function Server:isRemote()
	return true
end

function Server:isLocal()
	return true
end

function Server:connect(peer)
	local data = love.data.pack("string", ">Bc1s", 0, "m", self.map.name)
	peer:send(data)
end

function Server:action(peer, index, action, data)
	if action == "+" then
		for i, player in ipairs(self.players) do
			if player.controller:is(BotController) then
				player.peer = peer
				player.controller = RemoteController()

				local data = love.data.pack("string", ">Bc1", i, "+")
				peer:send(data)
				break
			end
		end
	else
		self.super.action(self, peer, index, action, data)
	end
end

return Server