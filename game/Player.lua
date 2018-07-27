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
	self.attack = false

	local shape = love.physics.newCircleShape(Player.RADIUS)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	self.body:setMass(1)
	self.body:setLinearDamping(20, 20)

	self.controller = Controller()
	self.index = index
end

function Player:update(dt, world, menu)
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
		self.body:applyForce(move.x * 100, move.y * 100)

		local attack = self.controller.attack
		if attack.x ~= 0 or attack.y ~= 0 then
			self.attack = true
			local x = self.lerp.x
			local y = self.lerp.y
			local nx = attack.x
			local ny = attack.y
			local len = math.sqrt(nx * nx + ny * ny)
			nx = nx / len
			ny = ny / len

			for i = 1, 3 do
				local close = {}
				world:rayCast(x, y, x + nx * 16, y + ny * 16, function(fixture, ix, iy, nx, ny)
					local dx = x - ix
					local dy = y - iy
					local dist = math.sqrt(dx * dx + dy * dy)
					if not close.dist or dist < close.dist then
						close.dist = dist
						close.ix = ix
						close.iy = iy
						close.nx = nx
						close.ny = ny
					end
					return -1
				end)

				self.lerp["a" .. i .. "x"] = close.ix
				self.lerp["a" .. i .. "y"] = close.iy
				x = close.ix
				y = close.iy
				nx = nx + close.nx * 2
				ny = ny + close.ny * 2
			end
		else
			self.attack = false
			self.lerp.a1x = nil
			self.lerp.a1y = nil
			self.lerp.a2x = nil
			self.lerp.a2y = nil
		end
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
		love.graphics.setLineWidth(0.05)
		love.graphics.line(self.lerp.x, self.lerp.y, self.lerp.a1x, self.lerp.a1y)
		love.graphics.line(self.lerp.a1x, self.lerp.a1y, self.lerp.a2x, self.lerp.a2y)
		love.graphics.line(self.lerp.a2x, self.lerp.a2y, self.lerp.a3x, self.lerp.a3y)
	end
	love.graphics.setColor(1, 1, 1)
end

return Player