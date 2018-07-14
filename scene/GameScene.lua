local Client = require("net.Client")
local Server = require("net.Server")

local KeyboardController = require("game.controller.KeyboardController")
local TouchController = require("game.controller.TouchController")
local Bloom = require("fx.Bloom")

local GameScene = Client:extend()

function GameScene:new()
	self.super.new(self)
	self.server = Server()
	self.host:connect("127.0.0.1:" .. Server.PORT)
	if love.system.getOS() == "Android" then
		self.next_controller = TouchController
	end

	self.bloom = Bloom()
end

function GameScene:action(peer, index, action, data)
	if action == "=" and not self.keyboard then
		self.next_controller = KeyboardController()
		local data = love.data.pack("string", ">Bc1", 1, "+")
		peer:send(data)
		self.keyboard = true
	end
	self.super.action(self, peer, index, action, data)
end

function GameScene:update(dt)
	self.server:update(dt)
	self.super.update(self, dt)
end

function GameScene:draw(lerp)
	self.bloom:preDraw()
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / 16, love.graphics.getHeight() / 9)

	self.map:draw()
	for _, player in ipairs(self.players) do
		player:draw(lerp)
	end

	love.graphics.pop()
	self.bloom:postDraw()
end

return GameScene