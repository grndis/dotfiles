-- Configuration
local targetApps = {
	"com.raycast.macos",
	"dev.warp.Warp-Stable",
}

local keyMappings = {
	{ hotkey = { "ctrl" }, key = "m", replacement = "return", repeatable = false },
	{ hotkey = { "ctrl" }, key = "i", replacement = "tab", repeatable = false },
	{ hotkey = { "ctrl" }, key = "h", replacement = "delete", repeatable = true },
}

-- Implementation
local activeHotkeys = {}

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

-- Window focus watcher
hs.window.filter.new():subscribe(hs.window.filter.windowFocused, function(window)
	local app = window and window:application()
	if app and isTargetApp(app:bundleID()) then
		createHotkeys()
	else
		clearHotkeys()
	end
end)

-- Handle initial state
local currentWindow = hs.window.focusedWindow()
if currentWindow then
	local app = currentWindow:application()
	if app and isTargetApp(app:bundleID()) then
		createHotkeys()
	end
end
