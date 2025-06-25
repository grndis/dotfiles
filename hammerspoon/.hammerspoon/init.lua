-- Create a self-contained object for our remapper
local remapper = {}

-- Key Mappings: A direct lookup table for maximum speed
remapper.keyMappings = {
	[46] = { key = "m", replacement = "return", repeatable = false },
	[34] = { key = "i", replacement = "tab", repeatable = false },
	[4] = { key = "h", replacement = "delete", repeatable = true },
}

-- The Smart Cache: Stores the TTY status for each application bundle ID
remapper.ttyCache = {}

-- The original, working function to check for text fields
function remapper:isInTextField()
	local element = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
	if not element then
		return false
	end
	local role = element:attributeValue("AXRole")
	local subrole = element:attributeValue("AXSubrole")
	return (role == "AXTextField" or role == "AXTextArea" or role == "AXComboBox" or subrole == "AXSearchField")
end

-- The TTY check, now with a powerful caching layer
function remapper:focusedAppHasTTY()
	local currentWindow = hs.window.focusedWindow()
	if not currentWindow then
		return false
	end
	local app = currentWindow:application()
	if not app then
		return false
	end
	local pid = app:pid()
	if not pid then
		return false
	end

	-- *** THE CACHING LOGIC ***
	local bundleID = app:bundleID()
	if bundleID and self.ttyCache[bundleID] ~= nil then
		-- Cache hit! Return the stored value instantly.
		return self.ttyCache[bundleID]
	end

	-- Cache miss: Run the slow check ONLY this one time for this app.
	local hasTTY = false
	local ttyCheck = hs.execute("ps -o tty= -p " .. pid .. " 2>/dev/null | grep -v '?'")
	if ttyCheck and ttyCheck:match("%S") then
		hasTTY = true
	else
		local children = hs.execute("pgrep -P " .. pid .. " 2>/dev/null")
		if children then
			for childPid in children:gmatch("%d+") do
				local childTtyCheck = hs.execute("ps -o tty= -p " .. childPid .. " 2>/dev/null | grep -v '?'")
				if childTtyCheck and childTtyCheck:match("%S") then
					hasTTY = true
					break
				end
			end
		end
	end

	-- Store the result in our cache for next time
	if bundleID then
		self.ttyCache[bundleID] = hasTTY
	end

	return hasTTY
end

-- The main event callback, unchanged
function remapper:keyDownCallback(event)
	local flags = event:getFlags()
	if not (flags.ctrl and not flags.cmd and not flags.alt and not flags.shift) then
		return false
	end

	local keyCode = event:getKeyCode()
	local mapping = self.keyMappings[keyCode]

	if mapping then
		if self:isInTextField() and not self:focusedAppHasTTY() then
			if mapping.repeatable then
				hs.eventtap.event.newKeyEvent({}, mapping.replacement, true):post()
				hs.timer.doAfter(0.01, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, false):post()
				end)
			else
				hs.eventtap.keyStroke({}, mapping.replacement)
			end
			return true
		end
	end
	return false
end

function remapper:start()
	self.eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
		return self:keyDownCallback(e)
	end)
	self.eventTap:start()
end

remapper:start()

hs.alert.show("Ctrl Remapper: Caching Active")
