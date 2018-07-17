enet = require("enet")
Object = require("classic")
Resizable = require("Resizable")
Lerp = require("Lerp")

local GameScene = require("scene.GameScene")
local timer = 0
local clock = 0.05

function love.load()
	love.physics.setMeter(1)
	scene = GameScene()
end

function love.resize()
	Resizable.resizeAll()
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