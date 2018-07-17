local Client = require("net.Client")
local Server = require("net.Server")

local KeyboardController = require("game.controller.KeyboardController")
local GamepadController  = require("game.controller.GamepadController")

local Bloom = require("fx.Bloom")
local Map = require("game.Map")

local GameScene = Client:extend()

function GameScene:new()
	self.super.new(self)
	self.server = Server()
	self.host:connect("127.0.0.1:" .. Server.PORT)

	self.controllers = {
		KeyboardController()
	}
	for _, gamepad in ipairs(love.joystick.getJoysticks()) do
		if gamepad:isGamepad() then
			table.insert(self.controllers, GamepadController(gamepad))
		end
	end

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
				table.insert(self.next_controllers, table.remove(self.controllers, i))
				self:send({
					p = 0,
					a = "+"
				})
				break
			end
		end
	end
end

function GameScene:draw(lerp)
	if self.ready then
		self.bloom:preDraw()
		love.graphics.push()

		local width  = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		if width / height < Map.WIDTH / Map.HEIGHT then
			local scale = width / Map.WIDTH
			love.graphics.translate(0, (height - Map.HEIGHT * scale) / 2)
			love.graphics.scale(scale)
		else
			local scale = height / Map.HEIGHT
			love.graphics.translate((width - Map.WIDTH * scale) / 2, 0)
			love.graphics.scale(scale)
		end

		self.map:draw()
		for _, player in ipairs(self.players) do
			player:draw(lerp)
		end

		love.graphics.pop()
		self.bloom:postDraw()
	end
end

return GameScene