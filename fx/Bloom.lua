local Bloom = Resizable:extend()

function Bloom:new()
	self.super.new(self)
	if not Bloom.load then
		Bloom.blur = {}
		Bloom.blur.shader = love.graphics.newShader([[
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
		self:resize()
		Bloom.load = true
	end
end

function Bloom:resize()
	Bloom.blur.c1 = love.graphics.newCanvas()
	Bloom.blur.c2 = love.graphics.newCanvas()

	Bloom.main = love.graphics.newCanvas(
		love.graphics.getWidth(),
		love.graphics.getHeight(),
		{msaa = 4}
	)
end

function Bloom:pass(from, to, offset)
	love.graphics.setCanvas(to)
	love.graphics.clear()
	Bloom.blur.shader:send("offset", {offset / love.graphics.getWidth(), offset / love.graphics.getHeight()})
	love.graphics.draw(from)
end

function Bloom:preDraw()
	love.graphics.setCanvas(Bloom.main)
	love.graphics.clear()
end

function Bloom:postDraw()
	love.graphics.setShader(Bloom.blur.shader)
	love.graphics.setBlendMode("alpha", "premultiplied")

	self:pass(Bloom.main,    Bloom.blur.c1, 0.5)
	self:pass(Bloom.blur.c1, Bloom.blur.c2, 1.5)
	self:pass(Bloom.blur.c2, Bloom.blur.c1, 2.5)
	self:pass(Bloom.blur.c1, Bloom.blur.c2, 2.5)
	self:pass(Bloom.blur.c2, Bloom.blur.c1, 3.5)
	
	love.graphics.setCanvas()
	love.graphics.setShader()
	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.draw(Bloom.main)
	love.graphics.draw(Bloom.blur.c1)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return Bloom