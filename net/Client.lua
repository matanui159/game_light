local Map = require("game.Map")
local Player = require("game.Player")
local RemoteController = require("game.controller.RemoteController")

local Client = Object:extend()

function Client:new(address)
	self.host = enet.host_create(address)
	self.peers = {}
	self.world = love.physics.newWorld()
	self.map = Map(self.world)
	self.players = {}
	for i = 1, 4 do
		self.players[i] = Player(self.world, 8, 4.5, i)
	end
end

function Client:destroy()
	self.host:destroy()
end

function Client:isRemote(player)
	return player.controller:is(RemoteController)
end

function Client:isLocal(player)
	return not self:isRemote(player)
end

function Client:connect(peer)
	for _, player in ipairs(self.players) do
		player.controller = RemoteController()
	end
end

function Client:action(peer, index, action, data)
	local player = self.players[index]

	if action == "m" then
		local map = love.data.unpack(">s", data)
		self.map:destroy()
		self.map = Map(self.world, map)
	end

	if action == "+" then
		player.peer = peer
		player.controller = self.next_controller
	end

	if action == "p" or (action == "=" and self:isRemote(player)) then
		local x, y, ax, ay, health, visible = love.data.unpack(">nnnnnB", data)
		player.body:setPosition(x * 100, y * 100)
	end
end

function Client:update(dt)
	local event = self.host:service()
	while event do
		if event.type == "connect" then
			self.peers[event.peer] = true
			self:connect(event.peer)
		elseif event.type == "disconnect" then
			self:disconnect(event.peer)
			self.peers[event.peer] = nil
		elseif event.type == "receive" then
			local p, action, index = love.data.unpack(">Bc1", event.data)
			self:action(event.peer, p, action, event.data:sub(index))
		end
		event = self.host:service()
	end

	self.world:update(dt)
	for index, player in ipairs(self.players) do
		player:update(dt)
		if self:isLocal(player) then
			local data = love.data.pack("string", ">Bc1nnnnnB",
				index, "=",
				player.lerp.x,
				player.lerp.y,
				0,
				0,
				1,
				1
			)
			self.host:broadcast(data)
		end
	end

	self.host:flush()
end

return Client