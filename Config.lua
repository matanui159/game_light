local binser = require("net.binser")

local Config = Object:extend()

function Config:new()
	local config = {
		fullscreen = 1,
		msaa = 3,
		bloom = 3
	}

	local data = love.filesystem.read("config")
	if data then
		config = binser.dn(data)
	end

	rawset(self, "__config", config)
end

function Config:__index(key)
	if key == "new" then
		return Config[key]
	else
		local value = self.__config[key]
		if value ~= nil then
			return value
		else
			return Config[key]
		end
	end
end

function Config:__newindex(key, value)
	if self.__config[key] ~= nil then
		self.__config[key] = value
		love.filesystem.write("config", binser.s(self.__config))
	end
end

return Config