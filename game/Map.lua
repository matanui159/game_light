local Map = Object:extend()

Map.WIDTH  = 16
Map.HEIGHT =  9

function Map:getTile(x, y)
	if self.data then
		if x < 0 or x >= Map.WIDTH or y < 0 or y >= Map.HEIGHT then
			return false
		else
			return self.data:getPixel(x, y) > 0.5
		end
	end
end

function Map:new(world, name)
	if not Map.load then
		Map.tiles = love.graphics.newImage("assets/tiles.png")
		Map.tiles:setFilter("nearest")
		Map.load = true
	end

	if name then
		self.name = name
		self.data = love.image.newImageData("assets/maps/" .. name .. ".png")
		self.body = love.physics.newBody(world)
		self.batch = love.graphics.newSpriteBatch(Map.tiles, Map.WIDTH * Map.HEIGHT, "static")

		for x = 0, Map.WIDTH - 1 do
			for y = 0, Map.HEIGHT - 1 do
				if self:getTile(x, y) then
					local shape = love.physics.newRectangleShape(x + 0.5, y + 0.5, 1, 1)
					love.physics.newFixture(self.body, shape)

					local qx = 0
					if self:getTile(x - 1, y) then
						qx = qx + 1
					end
					if self:getTile(x + 1, y) then
						qx = qx + 2
					end

					local qy = 0
					if self:getTile(x, y - 1) then
						qy = qy + 1
					end
					if self:getTile(x, y + 1) then
						qy = qy + 2
					end

					local quad = love.graphics.newQuad(qx, qy, 1, 1, 4, 4)
					self.batch:add(quad, x, y)
				end
			end
		end
	end
end

function Map:destroy()
	if self.body then
		self.body:destroy()
	end
end

function Map:draw()
	if self.batch then
		love.graphics.draw(self.batch)
	end
end

return Map