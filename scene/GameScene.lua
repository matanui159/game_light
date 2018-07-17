local Client = require("net.Client")
local Server = require("net.Server")

local KeyboardController = require("game.controller.KeyboardController")
local Bloom = require("fx.Bloom")

local GameScene = Client:extend()

function GameScene:new()
	self.super.new(self)
	self.server = Server()
	self.host:connect("127.0.0.1:" .. Server.PORT)

	self.controllers = {
		KeyboardController()
	}
	self.next_controllers = {}

	self.bloom = Bloom()
end

function GameScene:update(dt)
	if self.map.name then
		self.ready = true
	end
	self.server:update(dt)
	self.super.update(self, dt)

	if self.ready then
		for i, controller in ipairs(self.controllers) do
			if controller:join() then
				table.insert(self.next_controllers, table.remove(self.controllers, index))
				self:send({
					p = 0,
					a = "+"
				})
			end
		end
	end
end

function GameScene:draw(lerp)
	if self.ready then
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
end

return GameScene