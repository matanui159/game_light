local MessageClient = Object:extend()

function MessageClient:new(font)
	self.font = font
	self.prev = {
		text = "",
		color = {0, 0, 0}
	}
	self.next = self.prev
	self.lerp = Lerp()
	self.lerp.timer = 1
end

function MessageClient:recvMessage(msg)
	self.prev = self.next
	self.next = msg
	self.lerp.timer = nil
	self.lerp.timer = 0
end

function MessageClient:update(dt)
	self.lerp:update()
	self.lerp.timer = self.lerp.timer + dt / 3
	if self.lerp.timer > 1 then
		self.lerp.timer = 1
	end
end

function MessageClient:draw(lerp)
	self.lerp:setLerp(lerp)
	local x = self.lerp.timer
	local offset = -16 * x * x * (3 - 2 * x)

	love.graphics.setColor(unpack(self.prev.color))
	self.font:print(self.prev.text, offset, 0, 16)

	love.graphics.setColor(unpack(self.next.color))
	self.font:print(self.next.text, 16 + offset, 0, 16)

	love.graphics.setColor(1, 1, 1)
end

return MessageClient