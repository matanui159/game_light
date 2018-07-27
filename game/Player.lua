local Controller = require("game.controller.Controller")

local Player = Object:extend()

Player.RADIUS = 0.25
Player.COLORS = {
	{1, 0, 1},
	{0, 1, 0},
	{0, 1, 1},
	{1, 1, 0}
}

function Player:new(world, x, y, index)
	self.lerp = Lerp()
	self.lerp.x = x
	self.lerp.y = y
	self.lerp.angle = 0
	self.attack = false

	local shape = love.physics.newCircleShape(Player.RADIUS)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.fixture = love.physics.newFixture(self.body, shape)
	self.body:setMass(1)
	self.body:setLinearDamping(20, 20)

	self.controller = Controller()
	self.index = index
end

function Player:update(dt, menu)
	self.lerp:update()
	self.lerp.x = self.body:getX()
	self.lerp.y = self.body:getY()

	if not menu then
		self.controller:update(self)
		local move = self.controller.move
		local len = math.sqrt(move.x * move.x + move.y * move.y)
		if len > 1 then
			move.x = move.x / len
			move.y = move.y / len
		end

		local attack = self.controller.attack
		if attack.x ~= 0 or attack.y ~= 0 then
			self.lerp.angle = math.atan2(attack.y, attack.x)
			if not self.attack then
				self.lerp.__values.angle.old = self.lerp.__values.angle.value
			end
			self.attack = true
		else
			self.attack = false
		end
		self.body:applyForce(move.x * 100, move.y * 100)
	else
		self.attack = false
	end
end

function Player:draw(lerp)
	self.lerp:setLerp(lerp)

	local r, g, b = unpack(Player.COLORS[self.index])
	love.graphics.setColor(r, g, b)
	love.graphics.ellipse("fill", self.lerp.x, self.lerp.y, Player.RADIUS)
	if self.attack then
		love.graphics.line(self.lerp.x, self.lerp.y, self.lerp.x + math.cos(self.lerp.angle), self.lerp.y + math.sin(self.lerp.angle))
	end
	love.graphics.setColor(1, 1, 1)
end

return Player