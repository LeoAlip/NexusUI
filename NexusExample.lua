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
local NexusUI = require(game.ReplicatedStorage.NexusUI)

-- ───────────────────────────────────────────────────────────────────
--  STEP 2: Create a Window (TopFrame)
--  Name      = Title shown in the top bar
--  Version   = Version tag shown next to the title
--  Author    = "By who" shown next to the version
--  Size      = UDim2 size of the window (optional, has a default)
--  KeySystem = Choose key to minimize UI
-- ───────────────────────────────────────────────────────────────────
local Window = NexusUI:CreateWindow({
	Name = "Your Title",
	Version = "1.0",
	Author = "Player",
	Size = UDim2.new(0, 550, 0, 425),
	KeySystem = false,
	MinimizeKey = Enum.KeyCode.LeftControl
})

-- ─────────────────────────────────────────────────────────
--  STEP 3: Create a Key System (OPTIONAL)
--  Key  = Choose a valid key
--  Link = Copy link to clipboard
-- ─────────────────────────────────────────────────────────

--local KeySystem = Window:CreateKeySystem({ Key = "ABC123", Link = "https://roblox.com" })

-- ─────────────────────────────────────────────────────────
--  STEP 4: Create Tabs (sidebar navigation)
--  Icon = optional emoji / symbol for the tab button
-- ─────────────────────────────────────────────────────────
local MainTab = Window:CreateTab({ Name = "Main",    Icon = "🛡️" })
local SettingsTab = Window:CreateTab({ Name = "Misc",    Icon = "⚙" })

-- ─────────────────────────────────────────────────────────
--  STEP 5: Add Sections inside each Tab
-- ─────────────────────────────────────────────────────────

-- ── MAIN TAB ────────────────────────────────────────────
local ProfileSection = MainTab:CreateSection({ Name = "Profile" })
local MainSection = MainTab:CreateSection({ Name = "Main" })
local OtherSection = MainTab:CreateSection({ Name = "Other" })
local InfoSection = MainTab:CreateSection({ Name = "INFO" })
local InteresSection = SettingsTab:CreateSection({ Name = "Interesting" })
local AboutSection = SettingsTab:CreateSection({ Name = "ABOUT" })

-- ─────────────────────────────────────────────────────────
--  STEP 6: Add Profile (OPTIONAL)
--  Section  = Choose what section to put it
--  Username = Choose username to show an information
--  Image	 = true/false if you want the avatar to show
-- ─────────────────────────────────────────────────────────

Window:AddProfile({
	Section = ProfileSection,
	Username = "WirtulP",
	Image = true,
})

-- ────────────────────────────────────────────────────────────────────────────────────────
--  STEP 7: Create Elements (Important)
--  Section  = Choose what section to put it
--  Create   = Toggle/Dropdown/MultiDropdown/Button/Slider/Label/Textbox/ColorPicker
--  Name	 = Name the elements
--  Desc	 = Description of elements(Available some of it)
--  Callback = A function for the elements
-- ────────────────────────────────────────────────────────────────────────────────────────

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
		Window:SetTheme("Accent", color)
	end,
})

local MinimizeKeybind = InteresSection:CreateKeybind({
	Name = "Minimize Key",
	Description = "Toggle UI visibility",
	Default = Enum.KeyCode.LeftControl,
	Callback = function(key)
		Window:SetMinimizeKey(key)
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
print(Toggle:Get()) -- Print if it is true or false
print(Slider:Get()) -- Print the number selected
print(Textbox:Get()) -- Print what text say
print(Dropdown:Get()) -- Print what value is selected
print(MultiDropdown:Get()) -- Print what value is selected
print(ColorPicker:Get()) -- Print what color is chose

Toggle:Set(false) -- Set the value
Slider:Set(0) -- Set the number
Textbox:Set("Hello") -- Set the text
Dropdown:Set("One") -- Set the value
ColorPicker:Set(Color3.fromRGB(255, 255, 255)) -- Set the color
