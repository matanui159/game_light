local Map = require("game.Map")
local Server = require("net.Server")

local TextButton = require("ui.TextButton")
local SelectButton = require("ui.SelectButton")
local TextBox = require("ui.TextBox")

local MenuScene = Object:extend()

function MenuScene:new(font)
	self.font = font

	self.ip = TextBox(font, "ENTER IP...", 4, 1, 6)
	self.join = TextButton(font, "JOIN", 10, 1, 2)
	self.join.action = function()
		if pcall(scene.host.connect, scene.host, self.ip.input .. ":" .. Server.PORT) then
			self.join.text = "..."
		end
	end

	self.fullscreen = SelectButton(font, 3, 3, 4, {
		"FLLSCRN: OFF",
		"FLLSCRN: ON"
	}, config.fullscreen)
	self.fullscreen.change = function(index)
		config.fullscreen = index
		if config.fullscreen == 1 then
			love.window.setFullscreen(false)
		else
			love.window.setFullscreen(true)
		end
	end

	self.msaa = SelectButton(font, 3, 5, 4, {
		"MSAA: OFF",
		"MSAA: LOW",
		"MSAA: MED",
		"MSAA: HIGH"
	}, config.msaa)
	self.msaa.change = function(index)
		config.msaa = index
		scene.post:resize()
	end

	self.bloom = SelectButton(font, 9, 3, 4, {
		"BLOOM: OFF",
		"BLOOM: LOW",
		"BLOOM: MED",
		"BLOOM: HIGH"
	}, config.bloom)
	self.bloom.change = function(index)
		config.bloom = index
		scene.post:resize()
	end

	self.quit = TextButton(font, "QUIT", 6, 7, 4)
	self.quit.action = function()
		love.event.quit()
	end
end

function MenuScene:update()
	self.ip:update()
	self.join:update()
	self.fullscreen:update()
	self.msaa:update()
	self.bloom:update()
	self.quit:update()
end

function MenuScene:draw()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, Map.WIDTH, Map.HEIGHT)
	love.graphics.setColor(1, 1, 1)

	self.join:draw()
	self.ip:draw()
	self.fullscreen:draw()
	self.msaa:draw()
	self.bloom:draw()
	self.quit:draw()
end

function MenuScene:textinput(text)
	self.ip:textinput(text)
end

return MenuScene