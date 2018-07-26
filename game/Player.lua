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
	self.controller:update(self)
	self.lerp.x = self.body:getX()
	self.lerp.y = self.body:getY()

	if not menu then
		local move = self.controller.move
		local len = math.sqrt(move.x * move.x + move.y * move.y)
		if len > 1 then
			move.x = move.x / len
			move.y = move.y / len
		end
		self.body:applyForce(move.x * 100, move.y * 100)
	end
end

function Player:draw(lerp)
	self.lerp:setLerp(lerp)

	local r, g, b = unpack(Player.COLORS[self.index])
	love.graphics.setColor(r, g, b)
	love.graphics.ellipse("fill", self.lerp.x, self.lerp.y, Player.RADIUS)
	love.graphics.setColor(1, 1, 1)
end

return Player