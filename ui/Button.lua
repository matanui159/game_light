local Button = Object:extend()

function Button:new(scene, x, y, width)
	if not Button.load then
		Button.tiles = love.graphics.newImage("assets/tiles.png")
		Button.tiles:setFilter("linear", "nearest")
		Button.load = true
	end

	self.scene = scene
	self.x = x
	self.y = y
	self.width = width
	self.batch = love.graphics.newSpriteBatch(Button.tiles, width, "static")
	for i = 0, width - 1 do
		local qx = 0
		if i > 0 then
			qx = qx + 1
		end
		if i < width - 1 then
			qx = qx + 2
		end

		local quad = love.graphics.newQuad(qx * 10 + 1, 1, 8, 8, 40, 40)
		self.batch:add(quad, i, 0, 0, 1 / 8)
	end
	self.state = "default"
end

function Button:action()
end

function Button:update()
	if love.mouse.isDown(1) then
		if self.state ~= "missed" then
			local tx, ty, scale = self.scene:calcTransform()
			local x = (love.mouse.getX() - tx) / scale
			local y = (love.mouse.getY() - ty) / scale
			
			if x > self.x and x < self.x + self.width and y > self.y and y < self.y + 1 then
				self.state = "pressed"
			elseif self.state == "default" then
				self.state = "missed"
			else
				self.state = "active"
			end
		end
	else
		if self.state == "pressed" then
			self:action()
		end
		self.state = "default"
	end
end

function Button:draw(scene)
	if self.state == "pressed" then
		love.graphics.rectangle("fill", self.x, self.y, self.width, 1)
		love.graphics.setColor(0, 0, 0)
	else
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", self.x, self.y, self.width, 1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.batch, self.x, self.y)
	end
end

return Button