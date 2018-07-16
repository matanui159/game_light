local Client = require("net.Client")
local Server = require("net.Server")

local KeyboardController = require("game.controller.KeyboardController")
local Bloom = require("fx.Bloom")

local GameScene = Client:extend()

function GameScene:new()
	self.super.new(self)
	self.server = Server()
	self.host:connect("127.0.0.1:" .. Server.PORT)

	self.bloom = Bloom()
end

function GameScene:receive(data, peer)
	if data.a == "=" and not self.keyboard then
		self.next_controller = KeyboardController()
		self:send({
			p = 0,
			a = "+"
		})
		self.keyboard = true
	end
	self.super.receive(self, data, peer)
end

function GameScene:update(dt)
	if self.map.name then
		self.ready = true
	end
	self.server:update(dt)
	self.super.update(self, dt)
end

function GameScene:draw(lerp)
	self.bloom:preDraw()
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / 16, love.graphics.getHeight() / 9)

	if self.ready then
		self.map:draw()
		for _, player in ipairs(self.players) do
			player:draw(lerp)
		end
	end

	love.graphics.pop()
	self.bloom:postDraw()
end

return GameScene