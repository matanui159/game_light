local Resizable = Object:extend()

Resizable.resizable = setmetatable({}, {__mode = "v"})

function Resizable:new()
	table.insert(Resizable.resizable, self)
end

function Resizable:resize()
end

function Resizable.resizeAll()
	for _, resizable in ipairs(Resizable.resizable) do
		resizable:resize()
	end
end

return Resizable