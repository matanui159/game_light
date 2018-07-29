local Controller = require("game.controller.Controller")
local RemoteController = require("game.controller.RemoteController")

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
	self.lerp.health = 1

	local shape = love.physics.newCircleShape(Player.RADIUS)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	self.body:setMass(1)
	self.body:setLinearDamping(20, 20)

	self.world = world
	self.controller = Controller()
	self.index = index
end

function Player:calcLaser(callback)
	local x = self.lerp.x
	local y = self.lerp.y
	local nx = math.cos(self.lerp.attack)
	local ny = math.sin(self.lerp.attack)

	for i = 1, 3 do
		local close = {}
		self.world:rayCast(x, y, x + nx * 16, y + ny * 16, function(fixture, ix, iy, nx, ny)
			local dx = x - ix
			local dy = y - iy
			local dist = math.sqrt(dx * dx + dy * dy)
			if not close.dist or dist < close.dist then
				close.dist = dist
				close.fixture = fixture
				close.ix = ix
				close.iy = iy
				close.nx = nx
				close.ny = ny
			end
			return -1
		end)

		if close.dist then
			callback(x, y, close.ix, close.iy, close.fixture)
			x = close.ix
			y = close.iy

			local dot = nx * close.nx + ny * close.ny
			nx = nx - 2 * dot * close.nx
			ny = ny - 2 * dot * close.ny
		else
			break
		end
	end
end

function Player:update(dt, menu)
	if self.lerp.health > 0 then
		self.lerp.x = self.body:getX()
		self.lerp.y = self.body:getY()
		self.controller:update(menu, self)

		local move = self.controller.move
		local len = math.sqrt(move.x * move.x + move.y * move.y)
		if len > 1 then
			move.x = move.x / len
			move.y = move.y / len
		end
		self.body:applyForce(move.x * 100, move.y * 100)

		local attack = self.controller.attack
		if attack.x ~= 0 or attack.y ~= 0 then
			local old = self.lerp.attack
			self.lerp.attack = math.atan2(attack.y, attack.x)
			if old then
				while self.lerp.attack - old < -math.pi do
					self.lerp.attack = self.lerp.attack + 2 * math.pi
				end
				while self.lerp.attack - old > math.pi do
					self.lerp.attack = self.lerp.attack - 2 * math.pi
				end
			end

			self:calcLaser(function(x1, y1, x2, y2, fixture)
				local player = fixture:getUserData()
				if player and player ~= self and not player.controller:is(RemoteController) then
					player.lerp.health = player.lerp.health - 2 * dt
					if player.lerp.health <= 0 then
						player.body:setPosition(-1, -1)
						player.lerp.x = -1
						player.lerp.y = -1
					end
				end
			end)
		else
			self.lerp.attack = nil
		end
	end
end

function Player:draw(lerp)
	if self.lerp.health > 0 then
		self.lerp:setLerp(lerp)
		love.graphics.setColor(unpack(Player.COLORS[self.index]))

		if self.lerp.attack then
			love.graphics.setLineWidth(0.03)
			self:calcLaser(function(x1, y1, x2, y2)
				love.graphics.line(x1, y1, x2, y2)
			end)
		end

		love.graphics.ellipse("fill", self.lerp.x, self.lerp.y, Player.RADIUS)
		love.graphics.setColor(0, 0, 0)
		love.graphics.ellipse("fill", self.lerp.x, self.lerp.y, (1 - self.lerp.health * self.lerp.health) * Player.RADIUS)
		love.graphics.setColor(1, 1, 1)
	end
end

return Player