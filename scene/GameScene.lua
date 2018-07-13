local Bloom = require("fx.Bloom")
local Map = require("game.Map")

local GameScene = Object:extend()

function GameScene:new(map)
	self.bloom = Bloom()
	self.world = love.physics.newWorld()
	self.map = Map(self.world, map)
end

function GameScene:update()
end

function GameScene:draw()
	self.bloom:preDraw()
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / 16, love.graphics.getHeight() / 9)

	self.map:draw()

	love.graphics.pop()
	self.bloom:postDraw()
end

return GameScene