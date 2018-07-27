local Lerp = Object:extend()

function Lerp:new()
	rawset(self, "__values", {})
	rawset(self, "__lerp", 1)
end

function Lerp:__index(key)
	if key == "new" then
		return Lerp[key]
	else
		local value = self.__values[key]
		if value ~= nil then
			local lerp = self.__lerp
			return value.value * lerp + value.old * (1 - lerp)
		else
			return Lerp[key]
		end
	end
end

function Lerp:__newindex(key, value)
	local values = self.__values
	if values[key] ~= nil then
		if value == nil then
			values[key] = nil
		else
			values[key].value = value
		end
	elseif value ~= nil then
		values[key] = {
			value = value,
			old = value
		}
	end
end

function Lerp:update()
	self.__lerp = 1
	for _, value in pairs(self.__values) do
		value.old = value.value
	end
end

function Lerp:setLerp(lerp)
	self.__lerp = lerp
end

return Lerp