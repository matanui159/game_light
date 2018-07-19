local Map = require("game.Map")
local TextButton = require("ui.TextButton")
local SelectButton = require("ui.SelectButton")

local MenuScene = Object:extend()

function MenuScene:new(font)
	self.font = font

	self.fullscreen = SelectButton(font, 3, 2, 4, {
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

	self.msaa = SelectButton(font, 3, 4, 4, {
		"MSAA: OFF",
		"MSAA: 2x",
		"MSAA: 4x",
		"MSAA: 8x",
		"MSAA: 16x"
	}, config.msaa)
	self.msaa.change = function(index)
		config.msaa = index
		scene.bloom:resize()
	end

	self.bloom = SelectButton(font, 9, 2, 4, {
		"BLOOM: OFF",
		"BLOOM: LOW",
		"BLOOM: MED",
		"BLOOM: HIGH",
		"BLOOM: ULTRA"
	}, config.bloom)
	self.bloom.change = function(index)
		config.bloom = index
		scene.bloom:resize()
	end

	self.quit = TextButton(font, "QUIT", 9, 4, 4)
	self.quit.action = function()
		love.event.quit()
	end
end

function MenuScene:update()
	self.fullscreen:update()
	self.msaa:update()
	self.bloom:update()
	self.quit:update()
end

function MenuScene:draw()
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", 0, 0, Map.WIDTH, Map.HEIGHT)
	love.graphics.setColor(1, 1, 1)

	self.fullscreen:draw()
	self.msaa:draw()
	self.bloom:draw()
	self.quit:draw()
end

return MenuScene