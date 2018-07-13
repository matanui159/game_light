local Lerp = Object:extend()

function Lerp:new()
	self.__values = {}
	self:update()
end

function Lerp:__index(key)
	local value = self.__values[key]
	if value then
		local lerp = self.__lerp
		return value.value * lerp + value.old * (1 - lerp)
	else
		return Lerp[key]
	end
end

function Lerp:__newindex(key, value)
	local values = self.__values
	if values[key] then
		values[key].value = value
	else
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