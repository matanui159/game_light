if love.system.getOS() == "Android" then
	local setColor = love.graphics.setColor
	function love.graphics.setColor(r, g, b, a)
		a = a or 1
		setColor(r * 255, g * 255, b * 255, a * 255)
	end
end