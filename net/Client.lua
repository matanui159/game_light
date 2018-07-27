local binser = require("net.binser")
local Map = require("game.Map")
local Player = require("game.Player")
local RemoteController = require("game.controller.RemoteController")

local Client = Object:extend()

function Client:new(port)
	if port then
		self.port = port
		self.host = enet.host_create("*:" .. self.port)
		while not self.host do
			self.port = self.port + 1
			self.host = enet.host_create("*:" .. self.port)
		end
	else
		self.host = enet.host_create()
	end

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

function Client:connect()
	for _, player in ipairs(self.players) do
		player.controller = RemoteController()
	end
end

function Client:disconnect()
end

function Client:send(data, peer, fast)
	local ser = binser.s(data)
	local mode = "reliable"
	if fast then
		mode = "unreliable"
	end

	if peer then
		peer:send(ser, 0, mode)
	else
		self.host:broadcast(ser, 0, mode)
	end
end

function Client:receive(data, peer)
	local player = self.players[data.p]

	if data.a == "m" then
		self.map:destroy()
		self.map = Map(self.world, data.m)
	end

	if data.a == "+" then
		player.peer = peer
		player.controller = table.remove(self.next_controllers)
	end

	if data.a == "p" or (data.a == "=" and self:isRemote(player)) then
		player.body:setPosition(data.x, data.y)
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
			self:receive(binser.dn(event.data), event.peer)
		end
		event = self.host:service()
	end

	self.world:update(dt)
	for index, player in ipairs(self.players) do
		player:update(dt, self.world, self.menu)
		if self:isLocal(player) then
			self:send({
				p = index,
				a = "=",
				x = player.lerp.x,
				y = player.lerp.y
			}, nil, true)
		end
	end

	self.host:flush()
end

return Client