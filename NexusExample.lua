--[[
    ╔══════════════════════════════════════════════════════╗
    ║          NexusUI - Full Usage Example                ║
    ║  Copy NexusUI.lua to your game first, then use this  ║
    ╚══════════════════════════════════════════════════════╝
--]]

-- ─────────────────────────────────────────────────────────
--  STEP 1: Load the library
--  If you're using it as a ModuleScript in your game:
-- ─────────────────────────────────────────────────────────
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeoAlip/NexusUI/refs/heads/main/NexusUI.lua"))()

-- ─────────────────────────────────────────────────────────
--  STEP 2: Create a Window (TopFrame)
--  Name     = Title shown in the top bar
--  Version  = Version tag shown next to the title
--  Author   = "By who" shown next to the version
--  Size     = UDim2 size of the window (optional, has a default)
-- ─────────────────────────────────────────────────────────
local Window = NexusUI:CreateWindow({
	Name = "Your Title",
	Version = "1.0",
	Author = "Player",
	Size = UDim2.new(0, 550, 0, 425),
	KeySystem = true,
})

local KeySystem = Window:CreateKeySystem({
	Key = "ABC123",
	Link = "https://roblox.com",
})

-- ─────────────────────────────────────────────────────────
--  STEP 3: Create Tabs (sidebar navigation)
--  Icon = optional emoji / symbol for the tab button
-- ─────────────────────────────────────────────────────────
local MainTab = Window:CreateTab({ Name = "Main",    Icon = "🛡️" })
local SettingsTab = Window:CreateTab({ Name = "Misc",    Icon = "⚙" })

-- ─────────────────────────────────────────────────────────
--  STEP 4: Add Sections inside each Tab
-- ─────────────────────────────────────────────────────────

-- ── MAIN TAB ────────────────────────────────────────────
local ProfileSection = MainTab:CreateSection({ Name = "Profile" })
local MainSection = MainTab:CreateSection({ Name = "Main" })
local OtherSection = MainTab:CreateSection({ Name = "Other" })
local InfoSection = MainTab:CreateSection({ Name = "INFO" })

Window:AddProfile({
    Section = ProfileSection,
    Username = "WirtulP",
    Image = true,
})

-- Button (Name + Description supported)
MainSection:CreateButton({
	Name = "Button",
	Description = "Click button",
	Callback = function()
		print("Button clicked!")
	end,
})

-- Toggle (Name + Description supported)
local Toggle = MainSection:CreateToggle({
	Name = "Toggle",
	Description = "Toggle",
	Default = false,
	Callback = function(value)
		print("Toggle:", value)
	end,
})

-- You can also control it programmatically:
-- Toggle:Set(true)   → turn on
-- Toggle:Get()       → returns true/false

-- Slider
local Slider = MainSection:CreateSlider({
	Name = "Slider",
	Min = 1,
	Max = 10,
	Default = 1,
	Decimals = 1,
	Suffix = "",
	Callback = function(value)
		print("Slider:", value)
	end,
})

-- TextBox
local Textbox = OtherSection:CreateTextBox({
	Name = "Textbox",
	Placeholder = "Send message",
	Default = "",
	Callback = function(text)
		print("Text:", text)
	end,
})

-- Dropdown (single selection, Name + Description supported)
local Dropdown = OtherSection:CreateDropdown({
	Name = "Dropdown",
	Description = "Select a value",
	Options = { "One", "Two", "Three", "Four" },
	Default = "One",
	Callback = function(selected)
		print("Value selected:", selected)
	end,
})

-- MultiDropdown (multiple selections, Name + Description supported)
local MultiDropdown = OtherSection:CreateMultiDropdown({
	Name = "MultiDropdown",
	Description = "Can multi select",
	Options = { "One", "Two", "Three", "Four"},
	Defaults = {},
	Callback = function(selectedList)
		print("Multi Value selected:", table.concat(selectedList, ", "))
	end,
})

-- TextLabel (Name + Description supported)
InfoSection:CreateLabel({
	Name = "NexusUI Library",
	Description = "This is a label. Use it for info, tips, or notes.",
})

InfoSection:CreateLabel({
	Name = "Status: Good",
	Description = "UI is running in great condition",
})

-- ── MISC TAB ─────────────────────────────────────────────
local InteresSection = SettingsTab:CreateSection({ Name = "Interesting" })
local AboutSection = SettingsTab:CreateSection({ Name = "ABOUT" })

local execBox = InteresSection:CreateTextBox({
	Name = "Print Message",
	Placeholder = "Hellow World",
	Default = "",
	Callback = function(text, enter)
		if enter then
			print("Printed:", text)
		end
	end,
})

local ColorPicker = InteresSection:CreateColorPicker({
	Name = "Color",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(color)
		print(color)
	end,
})

AboutSection:CreateLabel({
	Name = "NexusUI v1.0",
	Description = "Made with ❤ — Fast, clean, and easy to use.",
})

AboutSection:CreateLabel({
	Name = "GitHub",
	Description = "https://github.com/LeoAlip/NexusUI",
})

-- ─────────────────────────────────────────────────────────
--  PROGRAMMATIC CONTROL (after window creation)
--  All elements return a controller object with :Get()/:Set()
-- ─────────────────────────────────────────────────────────

-- Read values at any time:
print(Toggle:Get()) -- true / false
print(Slider:Get()) -- number
print(Textbox:Get()) -- string
print(Dropdown:Get()) -- string
print(MultiDropdown:Get()) -- table of strings
print(ColorPicker:Get())
