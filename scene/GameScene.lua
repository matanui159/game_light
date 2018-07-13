local Map = require("game.Map")

local GameScene = Object:extend()

function GameScene:new(map)
	self.world = love.physics.newWorld()
	self.map = Map(self.world, map)
end

function GameScene:update()
end

function GameScene:draw()
	self.map:draw()
end

return GameScene