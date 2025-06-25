-- Configuration
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

local function updateHotkeyState()
	if isInTextField then
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
				or role == "AXStaticText"
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
