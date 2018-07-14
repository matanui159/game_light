local Controller = require("game.controller.Controller")

local Player = Object:extend()

local RADIUS = 0.3

local COLORS = {
	{0.8, 0.1, 0.1},
	{0.1, 0.8, 0.1},
	{0.1, 0.1, 0.8},
	{0.8, 0.8, 0.2}
}

function Player:new(world, x, y, index)
	self.lerp = Lerp()
	self.lerp.x = x
	self.lerp.y = y

	local shape = love.physics.newCircleShape(RADIUS * 100)
	self.body = love.physics.newBody(world, x * 100, y * 100, "dynamic")
	self.fixture = love.physics.newFixture(self.body, shape)
	self.body:setLinearDamping(30, 30)

	self.controller = Controller()
	self.index = index
end

function Player:update(dt, scene)
	self.lerp:update()
	self.controller:update()
	self.lerp.x = self.body:getX() / 100
	self.lerp.y = self.body:getY() / 100

	local move = self.controller.move
	local len = math.sqrt(move.x * move.x + move.y * move.y)
	if len > 1 then
		move.x = move.x / len
		move.y = move.y / len
	end
	self.body:applyForce(move.x * 100 * 300, move.y * 100 * 300)
end

function Player:draw(lerp)
	self.lerp:setLerp(lerp)

	love.graphics.setColor(unpack(COLORS[self.index]))
	love.graphics.ellipse("fill", self.lerp.x, self.lerp.y, RADIUS)
	love.graphics.setColor(1, 1, 1)
end

return Player