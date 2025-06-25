-- Configuration
local keyMappings = {
	{ key = "m", keyCode = 46, replacement = "return", repeatable = false },
	{ key = "i", keyCode = 34, replacement = "tab",    repeatable = false },
	{ key = "h", keyCode = 4,  replacement = "delete", repeatable = true },
}

-- Implementation
local eventTap = nil

local function isInTextField()
	local element = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
	if not element then
		return false
	end

	local role = element:attributeValue("AXRole")
	local subrole = element:attributeValue("AXSubrole")

	return (role == "AXTextField" or role == "AXTextArea" or role == "AXComboBox" or subrole == "AXSearchField")
end

local function focusedAppHasTTY()
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

	-- Check if the focused app or its children have TTY
	local ttyCheck = hs.execute("ps -o tty= -p " .. pid .. " 2>/dev/null | grep -v '?'")
	if ttyCheck and ttyCheck:match("%S") then
		return true
	end

	-- Also check child processes
	local children = hs.execute("pgrep -P " .. pid .. " 2>/dev/null")
	if children then
		for childPid in children:gmatch("%d+") do
			local childTtyCheck = hs.execute("ps -o tty= -p " .. childPid .. " 2>/dev/null | grep -v '?'")
			if childTtyCheck and childTtyCheck:match("%S") then
				return true
			end
		end
	end

	return false
end

local function shouldInterceptKey()
	return isInTextField() and not focusedAppHasTTY()
end

-- Create event tap that only intercepts when conditions are met
eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	-- Only handle Ctrl key combinations
	if not (flags.ctrl and not flags.cmd and not flags.alt and not flags.shift) then
		return false -- Let other keys pass through
	end

	-- Check if we should intercept
	if not shouldInterceptKey() then
		return false -- Let the key pass through to the original app
	end

	-- Find matching key mapping
	for _, mapping in ipairs(keyMappings) do
		if keyCode == mapping.keyCode then
			-- Send replacement key
			if mapping.repeatable then
				hs.eventtap.event.newKeyEvent({}, mapping.replacement, true):post()
				hs.timer.doAfter(0.01, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, false):post()
				end)
			else
				hs.eventtap.keyStroke({}, mapping.replacement)
			end
			return true -- Block the original key
		end
	end

	return false -- Let unmatched keys pass through
end)

eventTap:start()
