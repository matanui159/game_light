enet = require("enet")
Object = require("classic")
Lerp = require("Lerp")

local GameScene = require("scene.GameScene")
local timer = 0
local clock = 0.05

function love.load()
	love.physics.setMeter(1)
	scene = GameScene()
end

function love.resize()
	scene:resize()
end

function love.update(dt)
	timer = timer + dt
	if timer >= clock then
		scene:update(clock)
		timer = timer % clock
	end
end

function love.draw()
	scene:draw(timer / clock)
end