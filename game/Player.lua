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
	if not Player.load then
		local vertices = {{0, 0, 0, 0}}
		for i = 0, 360 do
			local angle = i / 180 * math.pi
			table.insert(vertices, {
				math.sin(angle),
				math.cos(angle),
				math.sin(angle),
				math.cos(angle)
			})
		end
		Player.mesh = love.graphics.newMesh(vertices)

		Player.shader = love.graphics.newShader([[
			extern float time;
			vec4 effect(vec4 color, Image image, vec2 coord, vec2 pos) {
				color.a = atan(coord.y, coord.x) + time;
				return color;
			}
		]])
		Player.load = true
	end

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

function Player:update(dt, scene)
	self.lerp:update()
	self.controller:update()
	self.lerp.x = self.body:getX()
	self.lerp.y = self.body:getY()

	local move = self.controller.move
	local len = math.sqrt(move.x * move.x + move.y * move.y)
	if len > 1 then
		move.x = move.x / len
		move.y = move.y / len
	end
	self.body:applyForce(move.x * 100, move.y * 100)
end

function Player:draw(lerp)
	self.lerp:setLerp(lerp)

	love.graphics.setShader(Player.shader)
	Player.shader:send("time", love.timer.getTime())
	love.graphics.setColor(unpack(Player.COLORS[self.index]))
	love.graphics.draw(Player.mesh, self.lerp.x, self.lerp.y, 0, Player.RADIUS)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setShader()
end

return Player