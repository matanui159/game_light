local Client = require("net.Client")
local Server = require("net.Server")
local MessageClient = require("net.MessageClient")

local Post = require("fx.Post")
local Spark = require("fx.Spark")
local Map = require("game.Map")

local RemoteController = require("game.controller.RemoteController")
local KeyboardController = require("game.controller.KeyboardController")
local GamepadController  = require("game.controller.GamepadController")

local Font = require("ui.Font")
local MenuButton = require("ui.MenuButton")

local GameScene = Client:extend()

function GameScene:new(config)
	GameScene.super.new(self, nil, true)
	self:disconnect()
	self.post = Post()

	self.ui = {}
	self.ui.font = Font(self)
	self.ui.menu = MenuButton(self, self.ui.font)
	self.message = MessageClient(self.ui.font)
	
	self.music = love.audio.newSource("assets/audio/music.mp3", "stream")
	self.music:setLooping(true)
	self.music:play()

	self.lerp = Lerp()
	self.lerp.fade = 1

	for i, player in ipairs(self.players) do
		player.sound = love.audio.newSource("assets/audio/lazer.ogg", "static")
		player.sound:setLooping(true)
		player.sound:setPitch(i * 0.5)
		player.sound:setVolume(0.5)
	end
end

function GameScene:connect(peer)
	if peer ~= self.local_peer then
		self.server:destroy()
		self.server = nil
		self.remote_peer = peer
	end

	GameScene.super.connect(self)
	self.controllers = {
		KeyboardController(self)
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

function GameScene:receive(data, peer)
	if data.a == "z" then
		self.message:recvMessage(data.z)
	end
	GameScene.super.receive(self, data, peer)
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

function GameScene:resize()
	self.post:resize()
	self.ui.font:resize()

	for i, player in ipairs(self.players) do
		player:resize()
	end
	
	collectgarbage()
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
						a = "+",
						k = controller:is(KeyboardController)
					})
					break
				end
			end

			for i, player in ipairs(self.players) do
				local controller = player.controller
				if controller:leave() then
					table.insert(self.controllers, controller)
					player.controller = RemoteController()
					self:send({
						p = i,
						a = "-"
					})
				end
			end
		end

		self.ui.menu:update()
	end

	self.message:update(dt)

	for i, player in ipairs(self.players) do
		local attack = player.controller.attack
		if player.lerp.health <= 0 then
			player.sound:pause()
		elseif attack.x == 0 and attack.y == 0 then
			player.sound:pause()
		else
			-- player.sound:setPitch(math.sin(love.timer.getTime()) * 0.25 + 0.75)
			player.sound:play()
		end
	end

	self.lerp:update()
	if self:gameOver() then
		self.lerp.fade = self.lerp.fade + dt
		if self.lerp.fade > 1 then
			self.lerp.fade = 1
		end
	else
		self.lerp.fade = self.lerp.fade - 3 * dt
		if self.lerp.fade < 0 then
			self.lerp.fade = 0
		end
	end
end

function GameScene:draw(lerp)
	if self.ready then
		self.post:preDraw()

		local tx, ty, scale = self:calcTransform()
		love.graphics.push()
		love.graphics.translate(tx, ty)
		love.graphics.scale(scale)

		self.message:draw(lerp)

		for _, player in ipairs(self.players) do
			player:draw(lerp)
		end
		self.map:draw()

		self.lerp:setLerp(lerp)
		love.graphics.setColor(1, 1, 1, self.lerp.fade)
		love.graphics.rectangle("fill", 0, 0, 16, 9)
		love.graphics.setColor(1, 1, 1)

		if self.menu then
			self.menu:draw()
		end

		self.ui.menu:draw()

		love.graphics.pop()
		self.post:postDraw()
	end
end

function GameScene:textinput(text)
	if self.menu then
		self.menu:textinput(text)
	end
end

return GameScene