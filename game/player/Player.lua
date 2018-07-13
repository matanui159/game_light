local Player = Object:extend()

function Player:new()
	self.lerp = Lerp()
	self.lerp.x = 500
	self.lerp.y = 500
end

function Player:update(dt, scene)
	self.lerp:update()
	self:updateInput()
end

function Player:draw(lerp)
	self.lerp:setLerp(lerp)
end