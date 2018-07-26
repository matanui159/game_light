enet = require("enet")
Object = require("classic")
Lerp = require("Lerp")

local Config = require("Config")
local GameScene = require("scene.GameScene")
local timer = 0
local CLOCK = 0.05

function love.load()
	love.keyboard.setKeyRepeat(true)
	love.physics.setMeter(1)

	config = Config()
	if config.fullscreen == 2 then
		love.window.setFullscreen(true)
	end

	scene = GameScene()
end

function love.resize()
	scene:resize()
end

function love.update(dt)
	timer = timer + dt
	if timer >= CLOCK then
		scene:update(CLOCK)
		timer = timer - CLOCK
		if timer > CLOCK then
			timer = CLOCK
		end
	end
end

function love.draw()
	scene:draw(timer / CLOCK)
end

function love.textinput(text)
	scene:textinput(text)
end

function love.keypressed(key)
	if key == "backspace" then
		love.textinput("\b")
	end
end