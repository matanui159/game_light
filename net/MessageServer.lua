local MessageServer = Object:extend()
local Player = require("game.Player")

function MessageServer:new(callback)
	self.callback = callback
	self.priority = 0
	self.timer = 0.9
	self.q = {}
	self.rank = -1
	
	self:queue("WELCOME TO LAZER BULB")
	self:queueColor("MADE BY JOSHUA MINTER", 1)
	self:queueColor("MUSIC BY BENJAMIN TISSOT", 4)
end

function MessageServer:playerMessage(player, msg)
	return {
		text = Player.NAMES[player] .. msg,
		color = Player.COLORS[player]
	}
end

function MessageServer:queue(msg, color, priority)
	color = color or {1, 1, 1}
	priority = priority or 1
	local m = {
		text = msg,
		color = color,
		priority = priority
	}

	for i, v in ipairs(self.q) do
		if v.text == msg then
			return
		end
		if priority > v.priority then
			table.insert(self.q, i, m)
			return
		end
	end
	table.insert(self.q, m)
end

function MessageServer:queueColor(msg, player, priority)
	self:queue(msg, Player.COLORS[player], priority)
end

function MessageServer:queuePlayer(msg, player, priority)
	self:queueColor(Player.NAMES[player] .. msg, player, priority)
end

function MessageServer:update(dt)
	self.timer = self.timer + dt / 3
	if self.timer >= 1 then
		if #self.q > 0 then
			self.callback(table.remove(self.q, 1))
			self.timer = 0
		else
			self.rank = self.rank + 1
			if self.rank > 4 then
				self.rank = 0
			end
			if self.rank == 0 then
				self:queue("PRESS ENTER TO JOIN")
				self:queue("PRESS A TO JOIN")
			else
				return self.rank
			end
		end
	end
	return 0
end

return MessageServer