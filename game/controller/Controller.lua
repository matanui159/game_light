local Controller = Object:extend()

function Controller:new()
	self.move = {x = 0, y = 0}
	self.attack = {x = 0, y = 0}
end

function Controller:join()
end

function Controller:leave()
end

function Controller:update(menu)
	if menu then
		self.move.x = 0
		self.move.y = 0
		self.attack.x = 0
		self.attack.y = 0
	end
end

return Controller