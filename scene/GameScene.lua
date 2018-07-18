local Client = require("net.Client")
local Server = require("net.Server")

local Bloom = require("fx.Bloom")
local Map = require("game.Map")

local KeyboardController = require("game.controller.KeyboardController")
local GamepadController  = require("game.controller.GamepadController")

local Font = require("ui.Font")

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

	self.ui = {}
	self.ui.font = Font(self)
end

function GameScene:calcTransform()
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	if width / height < Map.WIDTH / Map.HEIGHT then
		local scale = width / Map.WIDTH
		local trans = (height - Map.HEIGHT * scale) / 2
		return 0, trans, scale
	else
		local scale = height / Map.HEIGHT
		local trans = (width - Map.WIDTH * scale) / 2
		return trans, 0, scale
	end
end

function GameScene:resize(tx, ty, scale)
	self.bloom:resize()
	self.ui.font:resize()
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

		local tx, ty, scale = self:calcTransform()
		love.graphics.push()
		love.graphics.translate(tx, ty)
		love.graphics.scale(scale)

		self.map:draw()
		for _, player in ipairs(self.players) do
			player:draw(lerp)
		end
		self.ui.font:print("Hello, World!", 4, 8, 8)

		love.graphics.pop()
		self.bloom:postDraw()
	end
end

return GameScene