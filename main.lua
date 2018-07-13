Object = require("classic")
Lerp = require("Lerp")

local GameScene = require("scene.GameScene")
local timer = 0
local clock = 0.02

function love.load()
	scene = GameScene("test")
end

function love.update(dt)
	timer = timer + dt
	if timer >= clock then
		scene:update(dt)
		timer = timer % clock
	end
end

function love.draw()
	scene:draw(timer / clock)
end