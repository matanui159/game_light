local Font = Object:extend()

function Font:new(scene)
	self.scene = scene
	self:resize()
end

function Font:resize()
	local tx, ty, scale = self.scene:calcTransform()
	self.scale = scale
	self.font = love.graphics.newFont("assets/font/bold.ttf", scale / 2)
end

function Font:print(text, x, y, width)
	love.graphics.push()
	love.graphics.scale(1 / self.scale)
	love.graphics.setFont(self.font)
	love.graphics.print(
		text,
		(x + width / 2) * self.scale - self.font:getWidth(text) / 2,
		(y + 0.15) * self.scale
	)
	love.graphics.pop()
end

return Font