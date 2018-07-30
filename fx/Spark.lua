local Spark = Object:extend()

function Spark:new(scene)
	if not Spark.load then
		Spark.spark = love.graphics.newCanvas(6, 2)
		love.graphics.setCanvas(Spark.spark)
		love.graphics.rectangle("fill", 0, 0, 6, 2)
		love.graphics.setCanvas()
		Spark.load = true
	end

	local p = love.graphics.newParticleSystem(Spark.spark, 300)
	p:setParticleLifetime(0.3, 0.5)
	p:setSpread(math.pi)
	p:setRelativeRotation(true)
	p:setSizes(1, 0)

	self.particles = p
	self.scene = scene
	self.dt = 0
	self.lerp = 0
	
	self:resize()
end

function Spark:resize()
	local tx, ty, scale = self.scene:calcTransform()
	self.scale = scale
	self.particles:setSpeed(3 * scale, 5 * scale)
end

function Spark:setColor(r, g, b)
	self.particles:setColors(r, g, b, 1)
end

function Spark:emit(x, y, angle)
	local rate = {0, 2, 4, 8}
	self.particles:setPosition(x * self.scale, y * self.scale)
	self.particles:setDirection(angle)
	self.particles:emit(rate[config.spark])
end

function Spark:update(dt)
	self.particles:update((1 - self.lerp) * dt)
	self.dt = dt
	self.lerp = 0
end

function Spark:draw(lerp)
	self.particles:update((lerp - self.lerp) * self.dt)
	self.lerp = lerp

	love.graphics.push()
	love.graphics.scale(1 / self.scale)
	love.graphics.draw(self.particles)
	love.graphics.pop()
end

return Spark