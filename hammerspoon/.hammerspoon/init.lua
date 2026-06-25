-- Create a self-contained object for our remapper
local remapper = {}

-- Key Mappings: A direct lookup table for maximum speed
remapper.keyMappings = {
	[46] = { key = "m", replacement = "return", repeatable = false },
	[34] = { key = "i", replacement = "tab", repeatable = false },
	[4]  = { key = "h", replacement = "delete", repeatable = true },
}

-- Bundle ID whitelist for pure terminal emulators.
-- These apps handle Ctrl+H/I/M as terminal control characters natively,
-- so we must NOT remap when they're focused.
remapper.terminalBundleIDs = {
	["com.apple.Terminal"]     = true,
	["com.googlecode.iterm2"] = true,
	["net.kovidgoy.kitty"]    = true,
	["org.alacritty"]         = true,
	["com.mitchellh.ghostty"] = true,
	["com.warp.Warp"]         = true,
	["io.warp.Warp"]          = true,
	["co.zeit.hyper"]         = true,
	["org.gnu.emacs"]         = true,
}

-- Check if we're in a text field via the macOS Accessibility API.
-- Returns true/false when reliable, or nil when the API isn't ready
-- (e.g. a newly launched app whose accessibility tree isn't populated yet).
function remapper:isInTextField()
	local element = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
	if not element then
		return nil -- unsure — accessibility not ready
	end
	local role = element:attributeValue("AXRole")
	local subrole = element:attributeValue("AXSubrole")
	return (role == "AXTextField" or role == "AXTextArea" or role == "AXComboBox" or subrole == "AXSearchField")
end

-- The main event callback — modified to be robust for all apps
function remapper:keyDownCallback(event)
	local flags = event:getFlags()
	if not (flags.ctrl and not flags.cmd and not flags.alt and not flags.shift) then
		return false
	end

	local keyCode = event:getKeyCode()
	local mapping = self.keyMappings[keyCode]
	if not mapping then
		return false
	end

	local app = hs.application.frontmostApplication()
	if not app then
		return false
	end

	local bundleID = app:bundleID()
	if not bundleID then
		return false
	end

	-- Terminal emulators: let Ctrl+H/I/M pass through as native control chars
	if self.terminalBundleIDs[bundleID] then
		return false
	end

	-- GUI apps: remap when in a text field (or when we can't tell — safe default)
	-- inTextField == false  → definitely not a text field, let pass through
	-- inTextField == true   → remap
	-- inTextField == nil    → AX not ready yet for this app, remap anyway (safe)
	if self:isInTextField() == false then
		return false
	end

	-- Perform the remapping
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

function remapper:start()
	self.eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
		return self:keyDownCallback(e)
	end)
	self.eventTap:start()
end

remapper:start()

hs.alert.show("Ctrl Remapper: Always Active")
