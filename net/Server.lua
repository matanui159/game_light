local Server = Object:extend()
local enet = require("enet")

function Server:new()
	self.host = enet.host_create("*:2852")
end

function Server:update(game)
	local event = self.host:service()
	if event then
		
	end
end

return Server