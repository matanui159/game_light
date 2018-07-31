local Client = require("net.Client")
local MessageServer = require("net.MessageServer")

local Map = require("game.Map")
local Player = require("game.Player")

local BotController = require("game.controller.BotController")
local RemoteController = require("game.controller.RemoteController")

local Server = Client:extend()

Server.PORT = 2852

function Server:new()
	Server.super.new(self, Server.PORT)
	for _, player in ipairs(self.players) do
		player.controller = BotController(self.world, self.map, self.players, player)
		player.score = 0
	end

	self.message = MessageServer(function(msg)
		self:send({
			a = "z",
			z = msg
		})
	end)

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
	local maps = {
		"main",
		"paths",
		"lines",
		"dots",
		"box",
		"center",
		"race",
		"jm"
	}

	self.map:destroy()
	self.map = Map(self.world, maps[math.random(#maps)])
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

	self.end_timer = 0
	collectgarbage()
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
		player.controller = BotController(self.world, self.map, self.players, player)
		player.peer = nil
		player.ignore = false
		self.message:queuePlayer(" HAS LEFT", data.p, 4)
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

				self.message:queuePlayer(" HAS JOINED", i, 4)
				if data.k then
					self.message:queueColor("USE WASD TO MOVE", i, 2)
					self.message:queueColor("USE MOUSE TO ATTACK", i, 2)
					self.message:queueColor("PRESS ESC TO LEAVE", i, 2)
				else
					self.message:queueColor("USE LTHUMB TO MOVE", i, 2)
					self.message:queueColor("USE RTHUMB TO ATTACK", i, 2)
					self.message:queueColor("PRESS B TO LEAVE", i, 2)
				end
				break
			end
		end
	else
		Server.super.receive(self, data, peer)
	end
end

function Server:update(dt)
	Server.super.update(self, dt)

	local rank = self.message:update(dt)
	if rank > 0 then
		local sorted = {
			self.players[1],
			self.players[2],
			self.players[3],
			self.players[4]
		}
		table.sort(sorted, function(a, b)
			return a.score > b.score
		end)

		local msg = {
			"IN THE LEAD",
			"SECOND",
			"ALMOST LAST",
			"LAST"
		}
		local player = sorted[rank]
		self.message:queuePlayer(" IS " .. msg[rank] .. " WITH " .. player.score .. " POINTS", player.index)
		self.message:update(0)
	end

	local over, winner = self:gameOver()
	if over then
		if self.end_timer == 0 then
			if winner then
				self.message:queuePlayer(" WON A ROUND", winner.index, 3)
				winner.score = winner.score + 1
			end
		end

		self.end_timer = self.end_timer + dt
		if self.end_timer >= 1 then
			self:newGame()
		end
	end
end

return Server