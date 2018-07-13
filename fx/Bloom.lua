local Bloom = Object:extend()

function Bloom:new()
	if not Bloom.load then
		Bloom.mul = 1
		if love.system.getOS() == "Android" then
			Bloom.mul = 0.1
		end
		local width  = love.graphics.getWidth()  * Bloom.mul
		local height = love.graphics.getHeight() * Bloom.mul
		Bloom.main = love.graphics.newCanvas()

		Bloom.blur = {}
		Bloom.blur.shader = love.graphics.newShader([[
			extern vec2 offset;
			vec4 effect(vec4 color, Image image, vec2 coord, vec2 pos) {
				vec4 result = vec4(0.0);
				result += Texel(image, coord + vec2(-1.0, -1.0) * offset);
				result += Texel(image, coord + vec2(+1.0, -1.0) * offset);
				result += Texel(image, coord + vec2(+1.0, +1.0) * offset);
				result += Texel(image, coord + vec2(-1.0, +1.0) * offset);
				return result / 4.0 * color;
			}
		]])
		Bloom.blur.c1 = love.graphics.newCanvas(width, height)
		Bloom.blur.c2 = love.graphics.newCanvas(width, height)

		Bloom.load = true
	end
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
	love.graphics.push()
	love.graphics.scale(Bloom.mul)
	self:pass(Bloom.main, Bloom.blur.c1, 0.5)
	love.graphics.pop()

	self:pass(Bloom.blur.c1, Bloom.blur.c2, 1.5)
	self:pass(Bloom.blur.c2, Bloom.blur.c1, 2.5)
	self:pass(Bloom.blur.c1, Bloom.blur.c2, 2.5)
	self:pass(Bloom.blur.c2, Bloom.blur.c1, 3.5)
	
	love.graphics.setCanvas()
	love.graphics.setShader()
	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.draw(Bloom.main)
	love.graphics.draw(Bloom.blur.c1, 0, 0, 0, 1 / Bloom.mul)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return Bloom