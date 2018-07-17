local Font = Object:extend()

function Font:new(scene)
	self.scene = scene
	self:resize()
end

function Font:resize()
	self.scale = self.scene:calcTransform()
	self.font = love.graphics.newFont("assets/font/regular.ttf", self.scale / 2)
end

function Font:print(text, x, y, width)
	love.graphics.push()
	love.graphics.scale(1 / self.scale)
	love.graphics.setFont(self.font)
	love.graphics.printf(text, x * self.scale, (y + 0.15) * self.scale, width * self.scale, "center")
	love.graphics.pop()
end

return Font