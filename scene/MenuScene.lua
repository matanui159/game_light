local Map = require("game.Map")
local Server = require("net.Server")

local TextButton = require("ui.TextButton")
local SelectButton = require("ui.SelectButton")
local TextBox = require("ui.TextBox")

local MenuScene = Object:extend()

function MenuScene:new(game, font)
	self.ip = TextBox(game, font, "ENTER IP...", 4, 1, 6)
	self.ip.change = function()
		self.join.text = "JOIN"
	end

	self.join = TextButton(game, font, "JOIN", 10, 1, 2)
	self.join.action = function()
		local ip = self.ip.input:gsub("%s+", "")
		local part = "%d%d?%d?"
		if ip:match(part .. "." .. part .. "." .. part .. "." .. part) then
			game.host:connect(ip .. ":" .. Server.PORT)
			self.join.text = "..."
		else
			self.join.text = "!!!"
		end
	end

	self.fullscreen = SelectButton(game, font, 3, 3, 4, {
		"FLLSCRN: OFF",
		"FLLSCRN: ON"
	}, config.fullscreen)
	self.fullscreen.change = function(index)
		config.fullscreen = index
		love.window.setFullscreen(index == 2)
	end

	self.msaa = SelectButton(game, font, 3, 5, 4, {
		"MSAA: OFF",
		"MSAA: LOW",
		"MSAA: MED",
		"MSAA: HIGH",
		"MSAA: ULTRA"
	}, config.msaa)
	self.msaa.change = function(index)
		config.msaa = index
		game.post:resize()
	end

	self.bloom = SelectButton(game, font, 9, 3, 4, {
		"BLOOM: OFF",
		"BLOOM: LOW",
		"BLOOM: MED",
		"BLOOM: HIGH",
		"BLOOM: ULTRA"
	}, config.bloom)
	self.bloom.change = function(index)
		config.bloom = index
		game.post:resize()
	end

	self.spark = SelectButton(game, font, 9, 5, 4, {
		"SPARK: OFF",
		"SPARK: LOW",
		"SPARK: MED",
		"SPARK: HIGH",
		"SPARK: ULTRA"
	}, config.spark)
	self.spark.change = function(index)
		config.spark = index
	end

	self.quit = TextButton(game, font, "QUIT", 6, 7, 4)
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
	self.spark:update()
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
	self.spark:draw()
	self.quit:draw()
end

function MenuScene:textinput(text)
	self.ip:textinput(text)
end

return MenuScene