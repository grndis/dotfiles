--[[
  Ctrl Key Remapper

  Remaps Ctrl+H/M/I to Delete/Return/Tab in standard text fields,
  while intelligently ignoring terminal applications where those
  shortcuts have other meanings.

  This script is optimized to run expensive checks only when necessary,
  and caches the results for near-native performance on subsequent key presses.
]]

-- Configuration: A keycode-to-mapping table for O(1) lookup speed.
local keyMappings = {
	[46] = { key = "m", replacement = "return", repeatable = false }, -- Ctrl+M -> Return
	[34] = { key = "i", replacement = "tab", repeatable = false },   -- Ctrl+I -> Tab
	[4] = { key = "h", replacement = "delete", repeatable = true },  -- Ctrl+H -> Delete
}

-- A cache to store the TTY status of applications for performance.
local ttyCache = {}

--- Checks if the currently focused UI element is an editable text field.
-- @return {boolean} True if the element is a text field, false otherwise.
local function isInTextField()
	local element = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
	if not element then
		return false
	end

	-- A robust check for custom UI (like Raycast) that have a settable value.
	if element:attributeValue("AXValue") ~= nil then
		return true
	end

	-- The standard check for native macOS applications.
	local role = element:attributeValue("AXRole")
	local subrole = element:attributeValue("AXSubrole")
	return (role == "AXTextField" or role == "AXTextArea" or role == "AXComboBox" or subrole == "AXSearchField")
end

--- Checks if the focused application has an active terminal (TTY).
-- This function is computationally expensive and uses a cache to avoid repeated calls.
-- @return {boolean} True if the app is a terminal, false otherwise.
local function focusedAppHasTTY()
	local app = hs.window.focusedWindow():application()
	if not app then
		return false
	end

	local bundleID = app:bundleID()
	-- Return cached result instantly if this app has been checked before.
	if bundleID and ttyCache[bundleID] ~= nil then
		return ttyCache[bundleID]
	end

	-- On cache miss, run the expensive shell commands once.
	local pid = app:pid()
	if not pid then
		return false
	end

	local hasTTY = false
	-- Check the parent process.
	local ttyCheck = hs.execute("ps -o tty= -p " .. pid .. " 2>/dev/null | grep -v '?'")
	if ttyCheck and ttyCheck:match("%S") then
		hasTTY = true
	else
		-- Check child processes (for apps like VS Code's integrated terminal).
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

	-- Store the result in the cache for next time.
	if bundleID then
		ttyCache[bundleID] = hasTTY
	end
	return hasTTY
end

--- The main callback for all key down events.
-- @param event {hs.eventtap.event} The event object.
-- @return {boolean} True to block the event, false to let it pass through.
local function keyDownCallback(event)
	local flags = event:getFlags()
	-- Fast exit for any key combination that isn't Ctrl-only.
	if not (flags.ctrl and not flags.cmd and not flags.alt and not flags.shift) then
		return false
	end

	local keyCode = event:getKeyCode()
	local mapping = keyMappings[keyCode]

	-- Perform deeper checks only if the pressed key is one we want to remap.
	if mapping then
		if isInTextField() and not focusedAppHasTTY() then
			-- Execute the remapping.
			if mapping.repeatable then
				hs.eventtap.event.newKeyEvent({}, mapping.replacement, true):post()
				hs.timer.doAfter(0.01, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, false):post()
				end)
			else
				hs.eventtap.keyStroke({}, mapping.replacement)
			end
			return true -- Block the original system event.
		end
	end

	return false -- Allow all other keys to pass through.
end

-- Initialize and start the event tap.
local eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, keyDownCallback)
eventTap:start()

hs.alert.show("Ctrl Remapper Active")
