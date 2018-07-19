enet = require("enet")
Object = require("classic")
Lerp = require("Lerp")

local Config = require("Config")
local GameScene = require("scene.GameScene")
local timer = 0
local CLOCK = 0.05

function love.load()
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
		timer = timer % CLOCK
	end
	print(love.timer.getFPS())
end

function love.draw()
	scene:draw(timer / CLOCK)
end