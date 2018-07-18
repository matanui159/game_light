local Button = Object:extend()

function Button:new(x, y, width)
	if not Button.load then
		Button.up = love.graphics.newImage("assets/ui/button/up.png")
		Button.up:setFilter("nearest", "linear")

		Button.down = love.graphics.newImage("assets/ui/button/down.png")
		Button.down:setFilter("nearest", "linear")
		Button.load = true
	end

	self.batch = love.graphics.newSpriteBatch(Button.up, size, "static")
	for i = 0, size - 1 do
		local qx = 0
		if i > 0 then
			qx = qx + 1
		end
		if i < size - 1 then
			qx = qx + 2
		end

		local quad = love.graphics.newQuad(qx * 18 + 1, 1, 16, 16, 72, 18)
		self.batch:add(quad, i, 0, 0, 1 / 16)
	end
end

function Button:draw()
	
end