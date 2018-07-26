local Post = Object:extend()

function Post:new()
	if not Post.load then
		Post.shader = {}
		Post.shader.blur = love.graphics.newShader([[
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
		Post.load = true
	end
	self.canvas = {}
	self:resize()
end

function Post:resize()
	local msaa = {0, 2, 4, 8}
	self.canvas.main = love.graphics.newCanvas(
		love.graphics.getWidth(),
		love.graphics.getHeight(),
		{msaa = msaa[config.msaa]}
	)

	local div = {16, 8, 4, 2}
	self.mul = 1 / div[config.bloom]
	local width  = love.graphics.getWidth()  * self.mul
	local height = love.graphics.getHeight() * self.mul
	self.canvas.c1 = love.graphics.newCanvas(width, height)
	self.canvas.c2 = love.graphics.newCanvas(width, height)
end

function Post:blur(from, to, offset)
	love.graphics.setCanvas(to)
	love.graphics.clear()
	Post.shader.blur:send("offset", {offset / love.graphics.getWidth(), offset / love.graphics.getHeight()})
	love.graphics.draw(from)
end

function Post:preDraw()
	love.graphics.setCanvas(self.canvas.main)
	love.graphics.clear()
end

function Post:postDraw()
	love.graphics.setBlendMode("alpha", "premultiplied")

	if config.bloom > 1 then
		love.graphics.setShader(Post.shader.blur)

		love.graphics.push()
		love.graphics.scale(self.mul)
		self:blur(self.canvas.main, self.canvas.c1, 0.5)
		love.graphics.pop()

		self:blur(self.canvas.c1, self.canvas.c2, 1.5)
		self:blur(self.canvas.c2, self.canvas.c1, 2.5)

		if config.bloom >= 3 then
			self:blur(self.canvas.c1, self.canvas.c2, 2.5)
			self:blur(self.canvas.c2, self.canvas.c1, 3.5)
		end

		if config.bloom >= 4 then
			self:blur(self.canvas.c1, self.canvas.c2, 1.5)
			self:blur(self.canvas.c2, self.canvas.c1, 2.5)
			self:blur(self.canvas.c1, self.canvas.c2, 2.5)
			self:blur(self.canvas.c2, self.canvas.c1, 3.5)
		end

		love.graphics.setShader()
		love.graphics.setCanvas()
		love.graphics.setBlendMode("add", "premultiplied")

		love.graphics.push()
		love.graphics.scale(1 / self.mul)
		love.graphics.draw(self.canvas.c1)
		love.graphics.pop()
	end
	
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas.main)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return Post