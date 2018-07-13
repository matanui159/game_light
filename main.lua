Object = require("classic")
Lerp = require("Lerp")
res = {}

local GameScene = require("scene.GameScene")
local scene
local timer = 0
local clock = 0.02

function love.load()
	love.graphics.setDefaultFilter("nearest")
	res.tiles = love.graphics.newImage("assets/tiles.png")

	res.shader = {}
	res.shader.blur = love.graphics.newShader([[
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

	res.canvas = {}
	res.canvas.mul = 1
	if love.system.getOS() == "Android" then
		res.canvas.mul = 0.1
	end
	local width  = love.graphics.getWidth()  * res.canvas.mul
	local height = love.graphics.getHeight() * res.canvas.mul

	love.graphics.setDefaultFilter("linear")
	res.canvas.main = love.graphics.newCanvas()
	res.canvas.blur1 = love.graphics.newCanvas(width, height)
	res.canvas.blur2 = love.graphics.newCanvas(width, height)

	scene = GameScene("test")
end

function love.update(dt)
	timer = timer + dt
	if timer >= clock then
		scene:update(dt)
		timer = timer % clock
	end
end

local function blur(from, to, offset)
	love.graphics.setCanvas(to)
	love.graphics.clear()
	res.shader.blur:send("offset", {offset / love.graphics.getWidth(), offset / love.graphics.getHeight()})
	love.graphics.draw(from)
end

function love.draw()
	love.graphics.setCanvas(res.canvas.main)
	love.graphics.clear()
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / 16, love.graphics.getHeight() / 9)
	scene:draw(timer / clock)
	love.graphics.pop()

	love.graphics.setShader(res.shader.blur)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.push()
	love.graphics.scale(res.canvas.mul)
	blur(res.canvas.main,  res.canvas.blur1, 0.5)
	love.graphics.pop()

	blur(res.canvas.blur1, res.canvas.blur2, 1.5)
	blur(res.canvas.blur2, res.canvas.blur1, 2.5)
	blur(res.canvas.blur1, res.canvas.blur2, 2.5)
	blur(res.canvas.blur2, res.canvas.blur1, 3.5)
	
	love.graphics.setCanvas()
	love.graphics.setShader()
	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.draw(res.canvas.main)
	love.graphics.draw(res.canvas.blur1, 0, 0, 0, 1 / res.canvas.mul)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end