-- Configuration
local targetApps = {
	"com.raycast.macos",
	"dev.warp.Warp-Stable",
}

local keyMappings = {
	{ hotkey = { "ctrl" }, key = "m", replacement = "return", repeatable = false },
	{ hotkey = { "ctrl" }, key = "i", replacement = "tab",    repeatable = false },
	{ hotkey = { "ctrl" }, key = "h", replacement = "delete", repeatable = true },
}

-- Implementation
local activeHotkeys = {}
local isInTextField = false
local textFieldWatcher = nil

local function clearHotkeys()
	for _, hotkey in ipairs(activeHotkeys) do
		hotkey:delete()
	end
	activeHotkeys = {}
end

local function createHotkeys()
	clearHotkeys()
	for _, mapping in ipairs(keyMappings) do
		local hotkey = mapping.repeatable
				and hs.hotkey.bind(mapping.hotkey, mapping.key, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, true):post()
				end, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, false):post()
				end, function()
					hs.eventtap.event.newKeyEvent({}, mapping.replacement, true):post()
				end)
				or hs.hotkey.bind(mapping.hotkey, mapping.key, function()
					hs.eventtap.keyStroke({}, mapping.replacement)
				end)
		table.insert(activeHotkeys, hotkey)
	end
end

local function isTargetApp(bundleID)
	for _, target in ipairs(targetApps) do
		if bundleID == target then
			return true
		end
	end
	return false
end

local function isRaycastRunning()
	local raycast = hs.application.find("com.raycast.macos")
	return raycast ~= nil
end

local function shouldActivateHotkeys()
	-- Check if we're in a target app window
	local currentWindow = hs.window.focusedWindow()
	if currentWindow then
		local app = currentWindow:application()
		if app and isTargetApp(app:bundleID()) then
			return true
		end
	end

	-- Check if Raycast is running and we're in a text field
	if isRaycastRunning() and isInTextField then
		return true
	end

	return false
end

local function updateHotkeyState()
	if shouldActivateHotkeys() then
		if #activeHotkeys == 0 then
			createHotkeys()
		end
	else
		if #activeHotkeys > 0 then
			clearHotkeys()
		end
	end
end

-- Text field detection using accessibility events
local function setupTextFieldWatcher()
	if textFieldWatcher then
		textFieldWatcher:stop()
	end

	textFieldWatcher = hs.eventtap.new({
		hs.eventtap.event.types.keyDown,
		hs.eventtap.event.types.leftMouseDown,
		hs.eventtap.event.types.rightMouseDown,
	}, function(event)
		-- Small delay to let focus settle
		hs.timer.doAfter(0.05, function()
			local element = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
			local wasInTextField = isInTextField

			if element then
				local role = element:attributeValue("AXRole")
				local subrole = element:attributeValue("AXSubrole")

				-- Check if focused element is a text field
				isInTextField = (
					role == "AXTextField"
					or role == "AXTextArea"
					or role == "AXComboBox"
					or subrole == "AXSearchField"
				)
			else
				isInTextField = false
			end

			-- Only update if text field state changed
			if isInTextField ~= wasInTextField then
				updateHotkeyState()
			end
		end)

		return false -- Don't block the original event
	end)

	textFieldWatcher:start()
end

-- Window focus watcher (for regular apps)
hs.window.filter.new():subscribe(hs.window.filter.windowFocused, function(window)
	updateHotkeyState()
end)

-- Setup text field detection
setupTextFieldWatcher()

-- Handle initial state
hs.timer.doAfter(0.5, function()
	updateHotkeyState()
end)
