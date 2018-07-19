local Bloom = Object:extend()

function Bloom:new()
	if not Bloom.load then
		Bloom.shader = love.graphics.newShader([[
			extern vec2 offset;
			vec4 effect(vec4 color, Image image, vec2 coord, vec2 pos) {
				vec4 result = vec4(0.0);
				result += Texel(image, coord + vec2(-1.0, -1.0) * offset);
				result += Texel(image, coord + vec2(+1.0, -1.0) * offset);
				result += Texel(image, coord + vec2(+1.0, +1.0) * offset);
				result += Texel(image, coord + vec2(-1.0, +1.0) * offset);
				return result / 4.0;
			}
		]])
		Bloom.load = true
	end
	self.blur = {}
	self:resize()
end

function Bloom:resize()
	self.mul = 1 / 8
	if config.bloom >= 3 then
		self.mul = 1 / 4
		if config.bloom >= 4 then
			self.mul = 1 / 2
		end
	end
	local width  = love.graphics.getWidth()  * self.mul
	local height = love.graphics.getHeight() * self.mul

	self.blur.c1 = love.graphics.newCanvas(width, height)
	self.blur.c2 = love.graphics.newCanvas(width, height)

	local msaa = {0, 2, 4, 8}
	self.main = love.graphics.newCanvas(
		love.graphics.getWidth(),
		love.graphics.getHeight(),
		{msaa = msaa[config.msaa]}
	)
end

function Bloom:pass(from, to, offset)
	love.graphics.setCanvas(to)
	love.graphics.clear()
	Bloom.shader:send("offset", {offset / love.graphics.getWidth(), offset / love.graphics.getHeight()})
	love.graphics.draw(from)
end

function Bloom:preDraw()
	love.graphics.setCanvas(self.main)
	love.graphics.clear()
end

function Bloom:postDraw()
	love.graphics.setBlendMode("alpha", "premultiplied")

	if config.bloom > 1 then
		love.graphics.setShader(Bloom.shader)

		love.graphics.push()
		love.graphics.scale(self.mul)
		self:pass(self.main, self.blur.c1, 0.5)
		love.graphics.pop()

		self:pass(self.blur.c1, self.blur.c2, 1.5)
		self:pass(self.blur.c2, self.blur.c1, 2.5)

		if config.bloom >= 3 then
			self:pass(self.blur.c1, self.blur.c2, 2.5)
			self:pass(self.blur.c2, self.blur.c1, 3.5)
		end

		if config.bloom >= 4 then
			self:pass(self.blur.c1, self.blur.c2, 1.5)
			self:pass(self.blur.c2, self.blur.c1, 2.5)
			self:pass(self.blur.c1, self.blur.c2, 2.5)
			self:pass(self.blur.c2, self.blur.c1, 3.5)
		end

		love.graphics.setShader()
		love.graphics.setCanvas()
		love.graphics.setBlendMode("add", "premultiplied")

		love.graphics.push()
		love.graphics.scale(1 / self.mul)
		love.graphics.draw(self.blur.c1)
		love.graphics.pop()
	end
	
	love.graphics.setCanvas()
	love.graphics.draw(self.main)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return Bloom