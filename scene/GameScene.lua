local Client = require("net.Client")
local Server = require("net.Server")

local Bloom = require("fx.Bloom")
local Map = require("game.Map")

local KeyboardController = require("game.controller.KeyboardController")
local GamepadController  = require("game.controller.GamepadController")

local Font = require("ui.Font")
local MenuButton = require("ui.MenuButton")

local GameScene = Client:extend()

function GameScene:new()
	scene = self
	GameScene.super.new(self)
	self:disconnect()
	self.bloom = Bloom()

	self.ui = {}
	self.ui.font = Font()
	self.ui.menu = MenuButton(self.ui.font)
end

function GameScene:connect(peer)
	if peer ~= self.local_peer then
		self.server:destroy()
		self.server = nil
		self.remote_peer = perr
	end

	GameScene.super.connect(self)
	self.controllers = {
		KeyboardController()
	}
	for _, gamepad in ipairs(love.joystick.getJoysticks()) do
		if gamepad:isGamepad() then
			table.insert(self.controllers, GamepadController(gamepad))
		end
	end
	self.next_controllers = {}
	self.menu = nil
end

function GameScene:disconnect(peer)
	if peer == self.remote_peer then
		self.server = Server()
		self.local_peer = self.host:connect("127.0.0.1:" .. self.server.port)
	end
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

	if self.server then
		self.server:update(dt)
	end
	GameScene.super.update(self, dt)

	if self.ready then
		if self.menu then
			self.menu:update()
		else
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

		self.ui.menu:update()
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

		if self.menu then
			self.menu:draw()
		end

		self.ui.menu:draw()

		love.graphics.pop()
		self.bloom:postDraw()
	end
end

function GameScene:textinput(text)
	if self.menu then
		self.menu:textinput(text)
	end
end

return GameScene