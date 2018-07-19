local Font = Object:extend()

function Font:new()
	self:resize()
end

function Font:resize()
	local tx, ty, scale = scene:calcTransform()
	self.scale = scale
	self.font = love.graphics.newFont("assets/font/bold.ttf", scale / 2)
end

function Font:print(text, x, y, width)
	love.graphics.push()
	love.graphics.scale(1 / self.scale)
	love.graphics.setFont(self.font)
	love.graphics.printf(text, x * self.scale, (y + 0.15) * self.scale, width * self.scale, "center")
	love.graphics.pop()
end

return Font