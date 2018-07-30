local binser = require("net.binser")

local Config = Object:extend()

function Config:new()
	local config = {
		fullscreen = 1,
		msaa = 3,
		bloom = 3,
		spark = 3
	}

	local limits = {
		fullscreen = 2,
		msaa = 5,
		bloom = 5,
		spark = 5,
	}

	local data = love.filesystem.read("config")
	if data then
		c = binser.dn(data)
		if type(c) == "table" then
			for k, v in pairs(config) do
				if c[k] ~= nil then
					if c[k] > limits[k] then
						config[k] = limits[k]
					else
						config[k] = c[k]
					end
				end
			end
		end
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