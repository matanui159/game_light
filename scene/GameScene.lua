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

function GameScene:preDraw()
	self.bloom:preDraw()
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / 16, love.graphics.getHeight() / 9)

	self.map:draw()
end

function GameScene:postDraw()
	love.graphics.pop()
	self.bloom:postDraw()
end

function GameScene:draw()
	self:preDraw()
	self:postDraw()
end

return GameScene