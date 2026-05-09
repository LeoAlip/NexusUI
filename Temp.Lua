NexusUI source code can be show here. Get the source here in anytime. I will put at very random time. 

--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝
--]]

local NexusUI = {}
NexusUI.__index = NexusUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local guiHidden   = false
local minimizeConn = nil
local themeRegistry = {}

NexusUI.Theme = {
	Background        = Color3.fromRGB(15, 15, 20),
	SecondaryBG       = Color3.fromRGB(20, 20, 28),
	TertiaryBG        = Color3.fromRGB(25, 25, 35),
	ElementBG         = Color3.fromRGB(30, 30, 42),
	ElementHover      = Color3.fromRGB(38, 38, 52),
	Accent            = Color3.fromRGB(99, 102, 241),
	AccentHover       = Color3.fromRGB(118, 121, 255),
	AccentDark        = Color3.fromRGB(67, 70, 190),
	TextPrimary       = Color3.fromRGB(240, 240, 255),
	TextSecondary     = Color3.fromRGB(160, 160, 190),
	TextMuted         = Color3.fromRGB(100, 100, 130),
	TextDisabled      = Color3.fromRGB(70, 70, 90),
	Border            = Color3.fromRGB(45, 45, 62),
	BorderLight       = Color3.fromRGB(60, 60, 80),
	Success           = Color3.fromRGB(52, 211, 153),
	Warning           = Color3.fromRGB(251, 191, 36),
	Error             = Color3.fromRGB(248, 113, 113),
	ToggleOn          = Color3.fromRGB(99, 102, 241),
	ToggleOff         = Color3.fromRGB(55, 55, 75),
	TopBar            = Color3.fromRGB(12, 12, 18),
	TabBar            = Color3.fromRGB(17, 17, 24),
	TabActive         = Color3.fromRGB(99, 102, 241),
	TabInactive       = Color3.fromRGB(17, 17, 24),
}

local function RegisterThemed(instance, instanceProp, themeKey)
	if not themeRegistry[instance] then
		themeRegistry[instance] = {}
	end
	table.insert(themeRegistry[instance], { prop = instanceProp, key = themeKey })
end

local function Tween(obj, props, duration, style, direction)
	duration  = duration  or 0.2
	style     = style     or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(duration, style, direction), props):Play()
end

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = input.Position
			startPos  = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	for _, child in pairs(children or {}) do
		child.Parent = obj
	end
	if props and props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function AddCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function AddStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color     = color or NexusUI.Theme.Border
	stroke.Thickness = thickness or 1
	stroke.Parent    = parent
	return stroke
end

local function AddPadding(parent, top, right, bottom, left)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, top    or 8)
	pad.PaddingRight  = UDim.new(0, right  or 8)
	pad.PaddingBottom = UDim.new(0, bottom or 8)
	pad.PaddingLeft   = UDim.new(0, left   or 8)
	pad.Parent        = parent
	return pad
end

local function AddListLayout(parent, padding, fillDir, sortOrder)
	local layout = Instance.new("UIListLayout")
	layout.Padding       = UDim.new(0, padding  or 6)
	layout.FillDirection = fillDir   or Enum.FillDirection.Vertical
	layout.SortOrder     = sortOrder or Enum.SortOrder.LayoutOrder
	layout.Parent        = parent
	return layout
end

local function AutoResize(frame, layout, extraPad)
	extraPad = extraPad or 0
	layout.Changed:Connect(function()
		frame.Size = UDim2.new(
			frame.Size.X.Scale,
			frame.Size.X.Offset,
			0,
			layout.AbsoluteContentSize.Y + extraPad
		)
	end)
end

local function KeyName(keyCode)
	return tostring(keyCode):gsub("Enum.KeyCode.", "")
end

function NexusUI:CreateWindow(config)
	config = config or {}
	local Name        = config.Name        or "NexusUI"
	local Version     = config.Version     or "1.0"
	local Author      = config.Author      or "User"
	local Size        = config.Size        or UDim2.new(0, 540, 0, 420)
	local MinimizeKey = config.MinimizeKey or nil

	local T = NexusUI.Theme
	local Window = {}

	Window.RegisterThemed = RegisterThemed

	local ScreenGui = Create("ScreenGui", {
		Name           = "NexusUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent         = CoreGui,
	})

	-- ZIndex base: 1000
	local MainFrame = Create("Frame", {
		Name             = "MainFrame",
		Size             = Size,
		Position         = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2),
		BackgroundColor3 = T.Background,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 1000,
		Parent           = ScreenGui,
	})
	AddCorner(MainFrame, 12)
	AddStroke(MainFrame, T.Border, 1)

	Create("ImageLabel", {
		Name                   = "Shadow",
		Size                   = UDim2.new(1, 30, 1, 30),
		Position               = UDim2.new(0, -15, 0, -15),
		BackgroundTransparency = 1,
		Image                  = "rbxassetid://5554236805",
		ImageColor3            = Color3.fromRGB(0, 0, 0),
		ImageTransparency      = 0.5,
		ScaleType              = Enum.ScaleType.Slice,
		SliceCenter            = Rect.new(23, 23, 277, 277),
		ZIndex                 = 999,
		Parent                 = MainFrame,
	})

	-- ZIndex: 1001
	local TopBar = Create("Frame", {
		Name             = "TopBar",
		Size             = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = T.TopBar,
		BorderSizePixel  = 0,
		ZIndex           = 1001,
		Parent           = MainFrame,
	})
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 12)
	topCorner.Parent = TopBar

	Create("Frame", {
		Name             = "TopBarSquareFill",
		Size             = UDim2.new(1, 0, 0, 12),
		Position         = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = T.TopBar,
		BorderSizePixel  = 0,
		ZIndex           = 1002,
		Parent           = TopBar,
	})

	Create("Frame", {
		Name             = "AccentLine",
		Size             = UDim2.new(1, 0, 0, 2),
		Position         = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 1003,
		Parent           = TopBar,
	})

	local TitleArea = Create("Frame", {
		Name                   = "TitleArea",
		Size                   = UDim2.new(0, 300, 1, 0),
		Position               = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		ZIndex                 = 1003,
		Parent                 = TopBar,
	})

	local AccentDot = Create("Frame", {
		Name             = "AccentDot",
		Size             = UDim2.new(0, 8, 0, 8),
		Position         = UDim2.new(0, 0, 0.5, -4),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 1004,
		Parent           = TitleArea,
	})
	AddCorner(AccentDot, 4)

	Create("TextLabel", {
		Name                   = "TitleLabel",
		Size                   = UDim2.new(0, 350, 1, 0),
		Position               = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text                   = Name .. " v" .. Version .. " by " .. Author,
		TextColor3             = T.TextPrimary,
		TextSize               = 15,
		Font                   = Enum.Font.GothamBold,
		TextXAlignment         = Enum.TextXAlignment.Left,
		ZIndex                 = 1004,
		Parent                 = TitleArea,
	})

	local BtnContainer = Create("Frame", {
		Name                   = "BtnContainer",
		Size                   = UDim2.new(0, 68, 0, 26),
		Position               = UDim2.new(1, -78, 0.5, -13),
		BackgroundTransparency = 1,
		ZIndex                 = 1004,
		Parent                 = TopBar,
	})
	AddListLayout(BtnContainer, 6, Enum.FillDirection.Horizontal)

	local function MakeWindowBtn(icon, color, callback)
		local Btn = Create("TextButton", {
			Size             = UDim2.new(0, 28, 0, 26),
			BackgroundColor3 = T.ElementBG,
			Text             = icon,
			TextColor3       = color,
			TextSize         = 13,
			Font             = Enum.Font.GothamBold,
			AutoButtonColor  = false,
			ZIndex           = 1005,
			Parent           = BtnContainer,
		})
		AddCorner(Btn, 6)
		Btn.MouseEnter:Connect(function()
			Tween(Btn, {BackgroundColor3 = color, TextColor3 = T.TextPrimary}, 0.15)
		end)
		Btn.MouseLeave:Connect(function()
			Tween(Btn, {BackgroundColor3 = T.ElementBG, TextColor3 = color}, 0.15)
		end)
		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	local isMinimized = false
	local fullHeight  = Size.Y.Offset

	MakeWindowBtn("—", T.TextMuted, function()
		isMinimized = not isMinimized
		Tween(MainFrame, {
			Size = isMinimized
				and UDim2.new(0, Size.X.Offset, 0, 48)
				or  UDim2.new(0, Size.X.Offset, 0, fullHeight)
		}, 0.3, Enum.EasingStyle.Quart)
	end)

	MakeWindowBtn("✕", T.Error, function()
		Tween(MainFrame, {BackgroundTransparency = 1}, 0.2)
		task.wait(0.2)
		ScreenGui:Destroy()
	end)

	MakeDraggable(MainFrame, TopBar)

	local function SetMinimizeKey(keyCode)
		if minimizeConn then
			minimizeConn:Disconnect()
			minimizeConn = nil
		end
		if keyCode then
			minimizeConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.KeyCode == keyCode then
					guiHidden = not guiHidden
					MainFrame.Visible = not guiHidden
				end
			end)
		end
	end

	if MinimizeKey then
		SetMinimizeKey(MinimizeKey)
	end

	function Window:SetMinimizeKey(keyCode)
		SetMinimizeKey(keyCode)
	end

	-- ZIndex: 1001
	local TabBar = Create("Frame", {
		Name             = "TabBar",
		Size             = UDim2.new(0, 130, 1, -48),
		Position         = UDim2.new(0, 0, 0, 48),
		BackgroundColor3 = T.TabBar,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 1001,
		Parent           = MainFrame,
	})

	Create("Frame", {
		Name             = "TabBarBorder",
		Size             = UDim2.new(0, 1, 1, 0),
		Position         = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = T.Border,
		BorderSizePixel  = 0,
		ZIndex           = 1002,
		Parent           = TabBar,
	})

	local TabList = Create("ScrollingFrame", {
		Name                   = "TabList",
		Size                   = UDim2.new(1, 0, 1, -12),
		Position               = UDim2.new(0, 0, 0, 12),
		BackgroundTransparency = 1,
		ScrollBarThickness     = 0,
		CanvasSize             = UDim2.new(0, 0, 0, 0),
		ZIndex                 = 1002,
		Parent                 = TabBar,
	})
	AddPadding(TabList, 0, 8, 8, 8)
	local tabListLayout = AddListLayout(TabList, 4)
	AutoResize(TabList, tabListLayout, 8)
	tabListLayout.Changed:Connect(function()
		TabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 16)
	end)

	-- ZIndex: 1001
	local ContentArea = Create("Frame", {
		Name             = "ContentArea",
		Size             = UDim2.new(1, -130, 1, -48),
		Position         = UDim2.new(0, 130, 0, 48),
		BackgroundColor3 = T.SecondaryBG,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 1001,
		Parent           = MainFrame,
	})

	local LOADING_STEPS = {
		"Initialising NexusUI...",
		"Loading core modules...",
		"Connecting to services...",
		"Fetching player data...",
		"Verifying license...",
		"Loading UI components...",
		"Applying theme...",
		"Preparing workspace...",
		"Finalising setup...",
		"Done!",
	}

	local function RandWait()
		return math.random(5, 50) / 10
	end

	function Window:CreateKeySystem(config)
		config = config or {}
		local requiredKey = config.Key
		local keyLink     = config.Link

		-- ZIndex base for key system: 2000
		local KSFrame = Create("Frame", {
			Name             = "KeySystemFrame",
			Size             = UDim2.new(0, 450, 0, 200),
			Position         = UDim2.new(0.5, -225, 0.5, -100),
			BackgroundColor3 = T.Background,
			BorderSizePixel  = 0,
			ClipsDescendants = true,
			ZIndex           = 2000,
			Parent           = ScreenGui,
		})
		AddCorner(KSFrame, 12)
		AddStroke(KSFrame, T.Border, 1)

		Create("ImageLabel", {
			Name                   = "Shadow",
			Size                   = UDim2.new(1, 30, 1, 30),
			Position               = UDim2.new(0, -15, 0, -15),
			BackgroundTransparency = 1,
			Image                  = "rbxassetid://5554236805",
			ImageColor3            = Color3.fromRGB(0, 0, 0),
			ImageTransparency      = 0.5,
			ScaleType              = Enum.ScaleType.Slice,
			SliceCenter            = Rect.new(23, 23, 277, 277),
			ZIndex                 = 1999,
			Parent                 = KSFrame,
		})

		local KSTopBar = Create("Frame", {
			Name             = "KSTopBar",
			Size             = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = T.TopBar,
			BorderSizePixel  = 0,
			ZIndex           = 2001,
			Parent           = KSFrame,
		})
		do
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 12)
			c.Parent = KSTopBar

			Create("Frame", {
				Name             = "KSTopBarSquareFill",
				Size             = UDim2.new(1, 0, 0, 12),
				Position         = UDim2.new(0, 0, 1, -12),
				BackgroundColor3 = T.TopBar,
				BorderSizePixel  = 0,
				ZIndex           = 2001,
				Parent           = KSTopBar,
			})

			Create("Frame", {
				Name             = "AccentLine",
				Size             = UDim2.new(1, 0, 0, 2),
				Position         = UDim2.new(0, 0, 1, -2),
				BackgroundColor3 = T.Accent,
				BorderSizePixel  = 0,
				ZIndex           = 2002,
				Parent           = KSTopBar,
			})
		end

		local KSTitleArea = Create("Frame", {
			Name                   = "KSTitleArea",
			Size                   = UDim2.new(0, 300, 1, 0),
			Position               = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			ZIndex                 = 2002,
			Parent                 = KSTopBar,
		})

		local KSAccentDot = Create("Frame", {
			Name             = "KSAccentDot",
			Size             = UDim2.new(0, 8, 0, 8),
			Position         = UDim2.new(0, 0, 0.5, -4),
			BackgroundColor3 = T.Accent,
			BorderSizePixel  = 0,
			ZIndex           = 2003,
			Parent           = KSTitleArea,
		})
		AddCorner(KSAccentDot, 4)

		Create("TextLabel", {
			Name                   = "KSTitleLabel",
			Size                   = UDim2.new(0, 300, 1, 0),
			Position               = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			Text                   = Name .. " Key System",
			TextColor3             = T.TextPrimary,
			TextSize               = 15,
			Font                   = Enum.Font.GothamBold,
			TextXAlignment         = Enum.TextXAlignment.Left,
			ZIndex                 = 2003,
			Parent                 = KSTitleArea,
		})

		local KSBtnContainer = Create("Frame", {
			Name                   = "KSBtnContainer",
			Size                   = UDim2.new(0, 68, 0, 26),
			Position               = UDim2.new(1, -78, 0.5, -13),
			BackgroundTransparency = 1,
			ZIndex                 = 2002,
			Parent                 = KSTopBar,
		})
		AddListLayout(KSBtnContainer, 6, Enum.FillDirection.Horizontal)

		local function MakeKSBtn(icon, color, callback)
			local Btn = Create("TextButton", {
				Size             = UDim2.new(0, 28, 0, 26),
				BackgroundColor3 = T.ElementBG,
				Text             = icon,
				TextColor3       = color,
				TextSize         = 13,
				Font             = Enum.Font.GothamBold,
				AutoButtonColor  = false,
				ZIndex           = 2003,
				Parent           = KSBtnContainer,
			})
			AddCorner(Btn, 6)
			Btn.MouseEnter:Connect(function()
				Tween(Btn, {BackgroundColor3 = color, TextColor3 = T.TextPrimary}, 0.15)
			end)
			Btn.MouseLeave:Connect(function()
				Tween(Btn, {BackgroundColor3 = T.ElementBG, TextColor3 = color}, 0.15)
			end)
			Btn.MouseButton1Click:Connect(callback)
			return Btn
		end

		local ksMinimized  = false
		local ksFullHeight = 200

		MakeKSBtn("—", T.TextMuted, function()
			ksMinimized = not ksMinimized
			Tween(KSFrame, {
				Size = ksMinimized
					and UDim2.new(0, 450, 0, 48)
					or  UDim2.new(0, 450, 0, ksFullHeight)
			}, 0.3, Enum.EasingStyle.Quart)
		end)

		MakeKSBtn("✕", T.Error, function()
			Tween(KSFrame, {BackgroundTransparency = 1}, 0.2)
			task.wait(0.2)
			KSFrame:Destroy()
		end)

		MakeDraggable(KSFrame, KSTopBar)

		local KSBody = Create("Frame", {
			Name                   = "KSBody",
			Size                   = UDim2.new(1, 0, 1, -48),
			Position               = UDim2.new(0, 0, 0, 48),
			BackgroundTransparency = 1,
			ZIndex                 = 2001,
			Parent                 = KSFrame,
		})

		local StatusLabel = Create("TextLabel", {
			Name                   = "StatusLabel",
			Size                   = UDim2.new(1, -40, 0, 16),
			Position               = UDim2.new(0, 20, 0, 12),
			BackgroundTransparency = 1,
			Text                   = "Enter your key to continue.",
			TextColor3             = T.TextMuted,
			TextSize               = 11,
			Font                   = Enum.Font.Gotham,
			TextXAlignment         = Enum.TextXAlignment.Center,
			ZIndex                 = 2002,
			Parent                 = KSBody,
		})

		local InputBG = Create("Frame", {
			Name             = "InputBG",
			Size             = UDim2.new(1, -40, 0, 34),
			Position         = UDim2.new(0, 20, 0, 34),
			BackgroundColor3 = T.ElementBG,
			BorderSizePixel  = 0,
			ZIndex           = 2002,
			Parent           = KSBody,
		})
		AddCorner(InputBG, 8)
		AddStroke(InputBG, T.Border, 1)

		local KeyInput = Create("TextBox", {
			Name                   = "KeyInput",
			Size                   = UDim2.new(1, -24, 1, 0),
			Position               = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text                   = "",
			PlaceholderText        = "Enter a key",
			TextColor3             = T.TextPrimary,
			PlaceholderColor3      = T.TextMuted,
			TextSize               = 13,
			Font                   = Enum.Font.Gotham,
			TextXAlignment         = Enum.TextXAlignment.Left,
			ClearTextOnFocus       = false,
			ZIndex                 = 2003,
			Parent                 = InputBG,
		})

		KeyInput.Focused:Connect(function()
			Tween(InputBG, {BackgroundColor3 = T.SecondaryBG}, 0.15)
			AddStroke(InputBG, T.Accent, 1)
		end)
		KeyInput.FocusLost:Connect(function()
			Tween(InputBG, {BackgroundColor3 = T.ElementBG}, 0.15)
			AddStroke(InputBG, T.Border, 1)
		end)

		local GetKeyBtn = Create("TextButton", {
			Name             = "GetKeyBtn",
			Size             = UDim2.new(0, 120, 0, 30),
			Position         = UDim2.new(0.5, -136, 0, 86),
			BackgroundColor3 = T.TertiaryBG,
			Text             = "Get Key",
			TextColor3       = T.TextSecondary,
			TextSize         = 12,
			Font             = Enum.Font.GothamBold,
			AutoButtonColor  = false,
			ZIndex           = 2002,
			Parent           = KSBody,
		})
		AddCorner(GetKeyBtn, 7)
		AddStroke(GetKeyBtn, T.Border, 1)

		GetKeyBtn.MouseEnter:Connect(function()
			Tween(GetKeyBtn, {BackgroundColor3 = T.ElementHover, TextColor3 = T.TextPrimary}, 0.12)
		end)
		GetKeyBtn.MouseLeave:Connect(function()
			Tween(GetKeyBtn, {BackgroundColor3 = T.TertiaryBG, TextColor3 = T.TextSecondary}, 0.12)
		end)
		GetKeyBtn.MouseButton1Click:Connect(function()
			pcall(function() setclipboard(keyLink) end)
			StatusLabel.Text       = "Key link copied to clipboard!"
			StatusLabel.TextColor3 = T.Warning
			task.delay(3, function()
				StatusLabel.Text       = "Enter your key to continue."
				StatusLabel.TextColor3 = T.TextMuted
			end)
		end)

		local ConfirmKeyBtn = Create("TextButton", {
			Name             = "ConfirmKeyBtn",
			Size             = UDim2.new(0, 120, 0, 30),
			Position         = UDim2.new(0.5, 16, 0, 86),
			BackgroundColor3 = T.Accent,
			Text             = "Confirm Key",
			TextColor3       = T.TextPrimary,
			TextSize         = 12,
			Font             = Enum.Font.GothamBold,
			AutoButtonColor  = false,
			ZIndex           = 2002,
			Parent           = KSBody,
		})
		AddCorner(ConfirmKeyBtn, 7)

		ConfirmKeyBtn.MouseEnter:Connect(function()
			Tween(ConfirmKeyBtn, {BackgroundColor3 = T.AccentHover}, 0.12)
		end)
		ConfirmKeyBtn.MouseLeave:Connect(function()
			Tween(ConfirmKeyBtn, {BackgroundColor3 = T.Accent}, 0.12)
		end)
		ConfirmKeyBtn.MouseButton1Down:Connect(function()
			Tween(ConfirmKeyBtn, {BackgroundColor3 = T.AccentDark}, 0.08)
		end)
		ConfirmKeyBtn.MouseButton1Up:Connect(function()
			Tween(ConfirmKeyBtn, {BackgroundColor3 = T.AccentHover}, 0.1)
		end)

		local function ShowLoadingScreen(onComplete)
			-- ZIndex base: 3000
			local LSFrame = Create("Frame", {
				Name             = "LoadingScreen",
				Size             = UDim2.new(0, 450, 0, 400),
				Position         = UDim2.new(0.5, -225, 0.5, -200),
				BackgroundColor3 = T.Background,
				BorderSizePixel  = 0,
				ClipsDescendants = true,
				ZIndex           = 3000,
				Parent           = ScreenGui,
			})
			AddCorner(LSFrame, 12)
			AddStroke(LSFrame, T.Border, 1)

			Create("ImageLabel", {
				Name                   = "Shadow",
				Size                   = UDim2.new(1, 30, 1, 30),
				Position               = UDim2.new(0, -15, 0, -15),
				BackgroundTransparency = 1,
				Image                  = "rbxassetid://5554236805",
				ImageColor3            = Color3.fromRGB(0, 0, 0),
				ImageTransparency      = 0.5,
				ScaleType              = Enum.ScaleType.Slice,
				SliceCenter            = Rect.new(23, 23, 277, 277),
				ZIndex                 = 2999,
				Parent                 = LSFrame,
			})

			Create("Frame", {
				Name             = "AccentLine",
				Size             = UDim2.new(1, 0, 0, 2),
				Position         = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = T.Accent,
				BorderSizePixel  = 0,
				ZIndex           = 3001,
				Parent           = LSFrame,
			})

			local SpinImg = Create("ImageLabel", {
				Name                   = "SpinImg",
				Size                   = UDim2.new(0, 80, 0, 80),
				Position               = UDim2.new(0.5, -40, 0.5, -80),
				BackgroundTransparency = 1,
				Image                  = "rbxassetid://6031280882",
				ImageColor3            = T.Accent,
				ZIndex                 = 3001,
				Parent                 = LSFrame,
			})

			local spinAngle   = 0
			local spinRunning = true
			task.spawn(function()
				while spinRunning do
					spinAngle = (spinAngle + 3) % 360
					SpinImg.Rotation = spinAngle
					RunService.RenderStepped:Wait()
				end
			end)

			local StepLabel = Create("TextLabel", {
				Name                   = "StepLabel",
				Size                   = UDim2.new(1, -40, 0, 20),
				Position               = UDim2.new(0, 20, 0.5, 30),
				BackgroundTransparency = 1,
				Text                   = "Initialising...",
				TextColor3             = T.TextSecondary,
				TextSize               = 13,
				Font                   = Enum.Font.Gotham,
				TextXAlignment         = Enum.TextXAlignment.Center,
				ZIndex                 = 3001,
				Parent                 = LSFrame,
			})

			local PctLabel = Create("TextLabel", {
				Name                   = "PctLabel",
				Size                   = UDim2.new(1, -40, 0, 18),
				Position               = UDim2.new(0, 20, 0.5, 54),
				BackgroundTransparency = 1,
				Text                   = "0%",
				TextColor3             = T.Accent,
				TextSize               = 12,
				Font                   = Enum.Font.GothamBold,
				TextXAlignment         = Enum.TextXAlignment.Center,
				ZIndex                 = 3001,
				Parent                 = LSFrame,
			})

			local BarTrack = Create("Frame", {
				Name             = "BarTrack",
				Size             = UDim2.new(1, -60, 0, 6),
				Position         = UDim2.new(0, 30, 0.5, 80),
				BackgroundColor3 = T.Border,
				BorderSizePixel  = 0,
				ZIndex           = 3001,
				Parent           = LSFrame,
			})
			AddCorner(BarTrack, 3)

			local BarFill = Create("Frame", {
				Name             = "BarFill",
				Size             = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = T.Accent,
				BorderSizePixel  = 0,
				ZIndex           = 3002,
				Parent           = BarTrack,
			})
			AddCorner(BarFill, 3)

			local BarGlow = Create("Frame", {
				Name                   = "BarGlow",
				Size                   = UDim2.new(0, 20, 1, 4),
				Position               = UDim2.new(1, -10, 0, -2),
				BackgroundColor3       = T.AccentHover,
				BackgroundTransparency = 0.4,
				BorderSizePixel        = 0,
				ZIndex                 = 3003,
				Parent                 = BarFill,
			})
			AddCorner(BarGlow, 4)

			task.spawn(function()
				local totalSteps = #LOADING_STEPS
				for i, stepText in ipairs(LOADING_STEPS) do
					StepLabel.Text = stepText
					local pct = math.floor((i / totalSteps) * 100)
					PctLabel.Text = tostring(pct) .. "%"
					Tween(BarFill, {Size = UDim2.new(i / totalSteps, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quart)
					task.wait(RandWait())
				end

				spinRunning    = false
				StepLabel.Text = "Ready!"
				PctLabel.Text  = "100%"
				Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.3)
				task.wait(0.6)

				Tween(LSFrame,   {BackgroundTransparency = 1}, 0.35)
				Tween(SpinImg,   {ImageTransparency      = 1}, 0.35)
				Tween(StepLabel, {TextTransparency       = 1}, 0.35)
				Tween(PctLabel,  {TextTransparency       = 1}, 0.35)
				Tween(BarTrack,  {BackgroundTransparency = 1}, 0.35)
				Tween(BarFill,   {BackgroundTransparency = 1}, 0.35)
				task.wait(0.4)
				LSFrame:Destroy()

				if onComplete then onComplete() end
			end)

			return LSFrame
		end

		local function ValidateKey()
			local entered = KeyInput.Text
			local valid   = false
			if requiredKey == nil or requiredKey == "" then
				valid = (entered ~= "")
			else
				valid = (entered == requiredKey)
			end

			if valid then
				StatusLabel.Text       = "✓ Key accepted! Loading..."
				StatusLabel.TextColor3 = T.Success
				Tween(ConfirmKeyBtn, {BackgroundColor3 = T.Success}, 0.2)
				task.wait(0.8)

				Tween(KSFrame, {BackgroundTransparency = 1}, 0.25)
				task.wait(0.25)
				KSFrame:Destroy()

				ShowLoadingScreen(function()
					MainFrame.Visible = true
					Tween(MainFrame, {BackgroundTransparency = 0}, 0.3)
				end)
			else
				StatusLabel.Text       = "✗ Incorrect key. Please try again."
				StatusLabel.TextColor3 = T.Error
				Tween(InputBG, {BackgroundColor3 = Color3.fromRGB(60, 25, 25)}, 0.15)
				task.wait(0.4)
				Tween(InputBG, {BackgroundColor3 = T.ElementBG}, 0.3)
				task.delay(3, function()
					StatusLabel.Text       = "Enter your key to continue."
					StatusLabel.TextColor3 = T.TextMuted
				end)
			end
		end

		ConfirmKeyBtn.MouseButton1Click:Connect(ValidateKey)
		KeyInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then ValidateKey() end
		end)

		MainFrame.Visible = false
		return KSFrame
	end

	function Window:AddProfile(config)
		config = config or {}
		local Section  = config.Section
		local Username = config.Username or "Player"
		local ShowImg  = config.Image ~= false

		if not Section then return end

		local ProfileRow = Create("Frame", {
			Name             = "ProfileRow",
			Size             = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = T.ElementBG,
			BorderSizePixel  = 0,
			AutomaticSize    = Enum.AutomaticSize.Y,
			ZIndex           = 1010,
			Parent           = Section.SectionContent,
		})
		AddCorner(ProfileRow, 8)
		AddPadding(ProfileRow, 10, 10, 10, 10)
		ProfileRow.LayoutOrder = -999

		local AvatarImg = Create("ImageLabel", {
			Name                   = "Avatar",
			Size                   = UDim2.new(0, 52, 0, 52),
			Position               = UDim2.new(0, 0, 0, 0),
			BackgroundColor3       = T.TertiaryBG,
			BorderSizePixel        = 0,
			Image                  = "",
			Visible                = ShowImg,
			ZIndex                 = 1011,
			Parent                 = ProfileRow,
		})
		AddCorner(AvatarImg, 26)
		AddStroke(AvatarImg, T.Accent, 2)

		local InfoCol = Create("Frame", {
			Name                   = "InfoCol",
			Size                   = UDim2.new(1, ShowImg and -62 or 0, 0, 0),
			Position               = UDim2.new(0, ShowImg and 62 or 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize          = Enum.AutomaticSize.Y,
			ZIndex                 = 1011,
			Parent                 = ProfileRow,
		})
		AddListLayout(InfoCol, 3)

		local function MakeInfoLabel(text, color, size, bold)
			return Create("TextLabel", {
				Size                   = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text                   = text,
				TextColor3             = color,
				TextSize               = size or 12,
				Font                   = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
				TextXAlignment         = Enum.TextXAlignment.Left,
				TextTruncate           = Enum.TextTruncate.AtEnd,
				ZIndex                 = 1012,
				Parent                 = InfoCol,
			})
		end

		local usernameLabel    = MakeInfoLabel("@" .. Username,     T.TextPrimary,   17, true)
		local displayNameLabel = MakeInfoLabel("Display Name: ...", T.TextSecondary, 13, false)
		local userIdLabel      = MakeInfoLabel("User ID: ...",      T.TextMuted,     13, false)
		local accountAgeLabel  = MakeInfoLabel("Account Age: ...",  T.TextMuted,     13, false)

		task.spawn(function()
			local ok, userId = pcall(function()
				return Players:GetUserIdFromNameAsync(Username)
			end)
			if not ok then return end

			if ShowImg then
				local imgOk, imgUrl = pcall(function()
					return Players:GetUserThumbnailAsync(
						userId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size100x100
					)
				end)
				if imgOk then AvatarImg.Image = imgUrl end
			end

			local function GetDisplayName()
				local p = Players:GetPlayerByUserId(userId)
				return p and p.DisplayName or Username
			end
			local function GetAccountAge()
				local p = Players:GetPlayerByUserId(userId)
				return p and (p.AccountAge .. " days") or "N/A"
			end

			displayNameLabel.Text = "Display Name: " .. GetDisplayName()
			userIdLabel.Text      = "User ID: "      .. tostring(userId)
			accountAgeLabel.Text  = "Account Age: "  .. GetAccountAge()
		end)

		return ProfileRow
	end

	function Window:SetTheme(themeKey, color)
		if NexusUI.Theme[themeKey] == nil then
			warn("NexusUI:SetTheme — unknown theme key: " .. tostring(themeKey))
			return
		end
		NexusUI.Theme[themeKey] = color

		for instance, entries in pairs(themeRegistry) do
			if instance and instance.Parent then
				for _, entry in ipairs(entries) do
					if entry.key == themeKey then
						pcall(function()
							Tween(instance, { [entry.prop] = color }, 0.25)
						end)
					end
				end
			else
				themeRegistry[instance] = nil
			end
		end

		if themeKey == "Accent" then
			NexusUI.Theme.ToggleOn  = color
			NexusUI.Theme.TabActive = color
		end
	end

	local tabs      = {}
	local activeTab = nil

	function Window:CreateTab(config)
		config = config or {}
		local tabName = config.Name or "Tab"
		local tabIcon = config.Icon or ""

		local Tab = {}

		-- ZIndex: 1003 for tab buttons
		local TabFrame = Create("Frame", {
			Name                   = "TabFrame_" .. tabName,
			Size                   = UDim2.new(1, -20, 0, 34),
			BackgroundTransparency = 1,
			ZIndex                 = 1003,
			Parent                 = TabList,
		})

		local TabImage = Create("ImageLabel", {
			Name                   = "TabImage_" .. tabName,
			Size                   = UDim2.new(0.175, 0, 1, 0),
			Position               = UDim2.new(0, 7, 0, 0),
			BackgroundTransparency = 1,
			Image                  = tabIcon,
			ImageColor3            = T.TextSecondary,
			ScaleType              = Enum.ScaleType.Fit,
			ZIndex                 = 1005,
			Parent                 = TabFrame,
		})

		local TabBtn = Create("TextButton", {
			Name             = "TabBtn_" .. tabName,
			Size             = UDim2.new(1, 0, 0, 34),
			Position         = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = T.TabInactive,
			Text             = "",
			AutoButtonColor  = false,
			ZIndex           = 1004,
			Parent           = TabFrame,
		})
		AddCorner(TabBtn, 7)

		local TabBtnLayout = Create("Frame", {
			Name                   = "TabBtnLayout",
			Size                   = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex                 = 1005,
			Parent                 = TabBtn,
		})
		AddPadding(TabBtnLayout, 0, 8, 0, 8)

		local TabIndicator = Create("Frame", {
			Name                   = "TabIndicator",
			Size                   = UDim2.new(0, 3, 0, 18),
			Position               = UDim2.new(0, -8, 0.5, -9),
			BackgroundColor3       = T.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			ZIndex                 = 1006,
			Parent                 = TabBtnLayout,
		})
		AddCorner(TabIndicator, 2)

		local TabBtnText = Create("TextLabel", {
			Name                   = "TabBtnText",
			Size                   = UDim2.new(1, -20, 1, 0),
			Position               = UDim2.new(0, 20, 0, 0),
			BackgroundTransparency = 1,
			Text                   = tabName,
			TextColor3             = T.TextSecondary,
			TextSize               = 13,
			Font                   = Enum.Font.Gotham,
			TextXAlignment         = Enum.TextXAlignment.Left,
			ZIndex                 = 1006,
			Parent                 = TabBtnLayout,
		})

		-- ZIndex: 1002 for tab pages (inside ContentArea)
		local TabPage = Create("ScrollingFrame", {
			Name                   = "TabPage_" .. tabName,
			Size                   = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness     = 3,
			ScrollBarImageColor3   = T.Accent,
			CanvasSize             = UDim2.new(0, 0, 0, 0),
			Visible                = false,
			ZIndex                 = 1002,
			Parent                 = ContentArea,
		})
		AddPadding(TabPage, 10, 10, 10, 10)
		local pageLayout = AddListLayout(TabPage, 8)
		pageLayout.Changed:Connect(function()
			TabPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
		end)

		local function Activate()
			for _, t in pairs(tabs) do
				Tween(t.Btn,      {BackgroundColor3 = T.TabInactive},           0.15)
				Tween(t.BtnText,  {TextColor3 = T.TextSecondary, TextSize = 13}, 0.15)
				Tween(t.Indicator,{BackgroundTransparency = 1},                 0.15)
				if t.Img then
					Tween(t.Img, {ImageColor3 = T.TextSecondary}, 0.15)
				end
				t.Page.Visible = false
				t.BtnText.Font = Enum.Font.Gotham
			end
			Tween(TabBtn,      {BackgroundColor3 = T.ElementBG},             0.15)
			Tween(TabBtnText,  {TextColor3 = T.TextPrimary, TextSize = 13},  0.15)
			TabBtnText.Font = Enum.Font.GothamBold
			Tween(TabIndicator,{BackgroundTransparency = 0},                 0.15)
			Tween(TabImage,    {ImageColor3 = T.Accent},                     0.15)
			TabPage.Visible = true
			activeTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(Activate)
		TabBtn.MouseEnter:Connect(function()
			if activeTab ~= Tab then
				Tween(TabBtn, {BackgroundColor3 = T.ElementHover}, 0.15)
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if activeTab ~= Tab then
				Tween(TabBtn, {BackgroundColor3 = T.TabInactive}, 0.15)
			end
		end)

		Tab.Btn       = TabBtn
		Tab.BtnText   = TabBtnText
		Tab.Img       = TabImage
		Tab.Indicator = TabIndicator
		Tab.Page      = TabPage
		tabs[#tabs+1] = Tab

		if #tabs == 1 then Activate() end

		function Tab:CreateSection(config)
			config = config or {}
			local sectionName = config.Name or "Section"

			local Section = {}

			-- ZIndex base for sections: 1010
			local SectionFrame = Create("Frame", {
				Name             = "Section_" .. sectionName,
				Size             = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = T.TertiaryBG,
				BorderSizePixel  = 0,
				AutomaticSize    = Enum.AutomaticSize.Y,
				ZIndex           = 1010,
				Parent           = TabPage,
			})
			AddCorner(SectionFrame, 10)
			AddStroke(SectionFrame, T.Border, 1)

			local SectionHeader = Create("Frame", {
				Name             = "SectionHeader",
				Size             = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = T.ElementBG,
				BorderSizePixel  = 0,
				ZIndex           = 1011,
				Parent           = SectionFrame,
			})
			local sHdrCorner = Instance.new("UICorner")
			sHdrCorner.CornerRadius = UDim.new(0, 10)
			sHdrCorner.Parent = SectionHeader

			Create("Frame", {
				Name             = "SectionHdrSquareFill",
				Size             = UDim2.new(1, 0, 0, 10),
				Position         = UDim2.new(0, 0, 1, -10),
				BackgroundColor3 = T.ElementBG,
				BorderSizePixel  = 0,
				ZIndex           = 1011,
				Parent           = SectionHeader,
			})

			local SectionDot = Create("Frame", {
				Name             = "SectionDot",
				Size             = UDim2.new(0, 6, 0, 6),
				Position         = UDim2.new(0, 12, 0.5, -3),
				BackgroundColor3 = T.Accent,
				BorderSizePixel  = 0,
				ZIndex           = 1012,
				Parent           = SectionHeader,
			})
			AddCorner(SectionDot, 3)

			Create("TextLabel", {
				Name                   = "SectionTitle",
				Size                   = UDim2.new(1, -30, 1, 0),
				Position               = UDim2.new(0, 26, 0, 0),
				BackgroundTransparency = 1,
				Text                   = sectionName,
				TextColor3             = T.TextSecondary,
				TextSize               = 11,
				Font                   = Enum.Font.GothamBold,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 1012,
				Parent                 = SectionHeader,
			})

			local SectionContent = Create("Frame", {
				Name                   = "SectionContent",
				Size                   = UDim2.new(1, 0, 0, 0),
				Position               = UDim2.new(0, 0, 0, 38),
				BackgroundTransparency = 1,
				AutomaticSize          = Enum.AutomaticSize.Y,
				ZIndex                 = 1011,
				Parent                 = SectionFrame,
			})
			AddPadding(SectionContent, 6, 10, 10, 10)
			AddListLayout(SectionContent, 6)

			-- Helper: creates a labelled row (ZIndex 1012 base for row elements)
			local function MakeElement(name, desc, height)
				height = height or 40
				local Row = Create("Frame", {
					Size             = UDim2.new(1, 0, 0, height),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				if name and name ~= "" then
					local LabelFrame = Create("Frame", {
						Name                   = "LabelFrame",
						Size                   = UDim2.new(0.55, 0, 1, 0),
						BackgroundTransparency = 1,
						ZIndex                 = 1013,
						Parent                 = Row,
					})
					AddPadding(LabelFrame, 0, 6, 0, 10)

					Create("TextLabel", {
						Name                   = "Name",
						Size                   = UDim2.new(1, 0, 0, 18),
						Position               = (desc and desc ~= "") and UDim2.new(0, 0, 0.5, -17) or UDim2.new(0, 0, 0.5, -9),
						BackgroundTransparency = 1,
						Text                   = name,
						TextColor3             = T.TextPrimary,
						TextSize               = 13,
						Font                   = Enum.Font.GothamSemibold,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 1014,
						Parent                 = LabelFrame,
					})

					if desc and desc ~= "" then
						Create("TextLabel", {
							Name                   = "Desc",
							Size                   = UDim2.new(1, 0, 0, 13),
							Position               = UDim2.new(0, 0, 0.5, 2),
							BackgroundTransparency = 1,
							Text                   = desc,
							TextColor3             = T.TextMuted,
							TextSize               = 10,
							Font                   = Enum.Font.Gotham,
							TextXAlignment         = Enum.TextXAlignment.Left,
							TextWrapped            = true,
							ZIndex                 = 1014,
							Parent                 = LabelFrame,
						})
					end
				end

				return Row
			end

			function Section:CreateButton(config)
				config = config or {}
				local name     = config.Name        or "Button"
				local desc     = config.Description or ""
				local callback = config.Callback    or function() end

				local Row = MakeElement(name, desc, 40)
				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				local BtnFrame = Create("TextButton", {
					Name             = "ClickBtn",
					Size             = UDim2.new(0, 80, 0, 26),
					Position         = UDim2.new(1, -88, 0.5, -13),
					BackgroundColor3 = T.Accent,
					Text             = "Click",
					TextColor3       = T.TextPrimary,
					TextSize         = 12,
					Font             = Enum.Font.GothamBold,
					AutoButtonColor  = false,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(BtnFrame, 6)

				BtnFrame.MouseEnter:Connect(function()
					Tween(BtnFrame, {BackgroundColor3 = T.AccentHover, Size = UDim2.new(0, 84, 0, 28)}, 0.12)
					BtnFrame.Position = UDim2.new(1, -90, 0.5, -14)
				end)
				BtnFrame.MouseLeave:Connect(function()
					Tween(BtnFrame, {BackgroundColor3 = T.Accent, Size = UDim2.new(0, 80, 0, 26)}, 0.12)
					BtnFrame.Position = UDim2.new(1, -88, 0.5, -13)
				end)
				BtnFrame.MouseButton1Down:Connect(function()
					Tween(BtnFrame, {BackgroundColor3 = T.AccentDark, Size = UDim2.new(0, 78, 0, 24)}, 0.08)
					BtnFrame.Position = UDim2.new(1, -87, 0.5, -12)
				end)
				BtnFrame.MouseButton1Up:Connect(function()
					Tween(BtnFrame, {BackgroundColor3 = T.AccentHover, Size = UDim2.new(0, 80, 0, 26)}, 0.1)
					BtnFrame.Position = UDim2.new(1, -88, 0.5, -13)
					callback()
				end)

				return BtnFrame
			end

			function Section:CreateToggle(config)
				config = config or {}
				local name     = config.Name        or "Toggle"
				local desc     = config.Description or ""
				local default  = config.Default     or false
				local callback = config.Callback    or function() end

				local Row   = MakeElement(name, desc, 40)
				local value = default

				local TrackBG = Create("Frame", {
					Name             = "TrackBG",
					Size             = UDim2.new(0, 44, 0, 24),
					Position         = UDim2.new(1, -54, 0.5, -12),
					BackgroundColor3 = value and T.ToggleOn or T.ToggleOff,
					BorderSizePixel  = 0,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(TrackBG, 12)

				local Knob = Create("Frame", {
					Name             = "Knob",
					Size             = UDim2.new(0, 18, 0, 18),
					Position         = UDim2.new(0, value and 23 or 3, 0.5, -9),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 1016,
					Parent           = TrackBG,
				})
				AddCorner(Knob, 9)

				local Toggle = {}

				local function UpdateToggle()
					Tween(TrackBG, {BackgroundColor3 = value and T.ToggleOn or T.ToggleOff}, 0.2)
					Tween(Knob, {Position = value and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
					callback(value)
				end

				local ClickArea = Create("TextButton", {
					Name                   = "ToggleClickArea",
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 1017,
					Parent                 = Row,
				})
				ClickArea.MouseButton1Click:Connect(function()
					value = not value
					UpdateToggle()
				end)

				function Toggle:Set(v)
					value = v
					UpdateToggle()
				end
				function Toggle:Get()
					return value
				end

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				if default then UpdateToggle() end
				return Toggle
			end

			function Section:CreateSlider(config)
				config = config or {}
				local name     = config.Name     or "Slider"
				local min      = config.Min      or 0
				local max      = config.Max      or 100
				local default  = config.Default  or min
				local decimals = config.Decimals or 0
				local suffix   = config.Suffix   or ""
				local callback = config.Callback or function() end

				local Row = Create("Frame", {
					Name             = "SliderRow",
					Size             = UDim2.new(1, 0, 0, 52),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				Create("TextLabel", {
					Name                   = "SliderName",
					Size                   = UDim2.new(1, -20, 0, 18),
					Position               = UDim2.new(0, 10, 0, 8),
					BackgroundTransparency = 1,
					Text                   = name,
					TextColor3             = T.TextPrimary,
					TextSize               = 13,
					Font                   = Enum.Font.GothamSemibold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1013,
					Parent                 = Row,
				})

				local ValueLabel = Create("TextLabel", {
					Name                   = "ValueLabel",
					Size                   = UDim2.new(0, 80, 0, 18),
					Position               = UDim2.new(1, -88, 0, 8),
					BackgroundTransparency = 1,
					Text                   = tostring(default) .. suffix,
					TextColor3             = T.Accent,
					TextSize               = 12,
					Font                   = Enum.Font.GothamBold,
					TextXAlignment         = Enum.TextXAlignment.Right,
					ZIndex                 = 1013,
					Parent                 = Row,
				})

				local TrackBG = Create("Frame", {
					Name             = "SliderTrack",
					Size             = UDim2.new(1, -20, 0, 6),
					Position         = UDim2.new(0, 10, 0, 36),
					BackgroundColor3 = T.Border,
					BorderSizePixel  = 0,
					ZIndex           = 1013,
					Parent           = Row,
				})
				AddCorner(TrackBG, 3)

				local pct = (default - min) / (max - min)

				local Fill = Create("Frame", {
					Name             = "SliderFill",
					Size             = UDim2.new(pct, 0, 1, 0),
					BackgroundColor3 = T.Accent,
					BorderSizePixel  = 0,
					ZIndex           = 1014,
					Parent           = TrackBG,
				})
				AddCorner(Fill, 3)

				local Thumb = Create("Frame", {
					Name             = "SliderThumb",
					Size             = UDim2.new(0, 14, 0, 14),
					Position         = UDim2.new(pct, -7, 0.5, -7),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 1015,
					Parent           = TrackBG,
				})
				AddCorner(Thumb, 7)
				AddStroke(Thumb, T.Accent, 2)

				local Slider   = {}
				local value    = default
				local dragging = false

				local function SetValue(v)
					v = math.clamp(v, min, max)
					if decimals == 0 then
						v = math.round(v)
					else
						v = math.floor(v * 10^decimals + 0.5) / 10^decimals
					end
					value = v
					local p = (v - min) / (max - min)
					Tween(Fill,  {Size = UDim2.new(p, 0, 1, 0)},        0.05)
					Tween(Thumb, {Position = UDim2.new(p, -7, 0.5, -7)}, 0.05)
					ValueLabel.Text = tostring(v) .. suffix
					callback(v)
				end

				local DragArea = Create("TextButton", {
					Name                   = "SliderDragArea",
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 1016,
					Parent                 = TrackBG,
				})

				DragArea.MouseButton1Down:Connect(function()
					dragging = true
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local abs  = TrackBG.AbsolutePosition
						local size = TrackBG.AbsoluteSize
						local relX = (input.Position.X - abs.X) / size.X
						SetValue(min + math.clamp(relX, 0, 1) * (max - min))
					end
				end)

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				function Slider:Set(v) SetValue(v) end
				function Slider:Get()  return value end
				return Slider
			end

			function Section:CreateTextBox(config)
				config = config or {}
				local name        = config.Name        or "TextBox"
				local placeholder = config.Placeholder or "Enter text..."
				local default     = config.Default     or ""
				local callback    = config.Callback    or function() end

				local Row = Create("Frame", {
					Name             = "TextBoxRow",
					Size             = UDim2.new(1, 0, 0, 50),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				Create("TextLabel", {
					Name                   = "TextBoxName",
					Size                   = UDim2.new(1, -20, 0, 18),
					Position               = UDim2.new(0, 10, 0, 7),
					BackgroundTransparency = 1,
					Text                   = name,
					TextColor3             = T.TextPrimary,
					TextSize               = 13,
					Font                   = Enum.Font.GothamSemibold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1013,
					Parent                 = Row,
				})

				local InputBG = Create("Frame", {
					Name             = "TextBoxInputBG",
					Size             = UDim2.new(1, -20, 0, 22),
					Position         = UDim2.new(0, 10, 0, 22),
					BackgroundColor3 = T.Background,
					BorderSizePixel  = 0,
					ZIndex           = 1013,
					Parent           = Row,
				})
				AddCorner(InputBG, 5)
				AddStroke(InputBG, T.Border, 1)

				local Input = Create("TextBox", {
					Name                   = "TextBoxInput",
					Size                   = UDim2.new(1, -16, 1, 0),
					Position               = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text                   = default,
					PlaceholderText        = placeholder,
					TextColor3             = T.TextPrimary,
					PlaceholderColor3      = T.TextMuted,
					TextSize               = 12,
					Font                   = Enum.Font.Gotham,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ClearTextOnFocus       = false,
					ZIndex                 = 1014,
					Parent                 = InputBG,
				})

				Input.Focused:Connect(function()
					Tween(InputBG, {BackgroundColor3 = T.SecondaryBG}, 0.15)
					AddStroke(InputBG, T.Accent, 1)
				end)
				Input.FocusLost:Connect(function(enter)
					Tween(InputBG, {BackgroundColor3 = T.Background}, 0.15)
					AddStroke(InputBG, T.Border, 1)
					callback(Input.Text, enter)
				end)

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				local TextBox = {}
				function TextBox:Set(v) Input.Text = v end
				function TextBox:Get()  return Input.Text end
				return TextBox
			end

			function Section:CreateKeybind(config)
				config = config or {}
				local name     = config.Name        or "Keybind"
				local desc     = config.Description or ""
				local default  = config.Default     or MinimizeKey
				local callback = config.Callback    or function() end

				local currentKey = default
				local listening  = false
				local listenConn = nil

				local Row = MakeElement(name, desc, 40)
				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				local KeyBtn = Create("TextButton", {
					Name             = "KeybindBtn",
					Size             = UDim2.new(0, 60, 0, 26),
					Position         = UDim2.new(1, -68, 0.5, -13),
					BackgroundColor3 = T.Background,
					Text             = KeyName(currentKey),
					TextColor3       = T.Accent,
					TextSize         = 11,
					Font             = Enum.Font.GothamBold,
					AutoButtonColor  = false,
					ClipsDescendants = true,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(KeyBtn, 6)
				AddStroke(KeyBtn, T.Border, 1)

				local function StopListening()
					listening = false
					if listenConn then
						listenConn:Disconnect()
						listenConn = nil
					end
					Tween(KeyBtn, {BackgroundColor3 = T.Background}, 0.15)
					AddStroke(KeyBtn, T.Border, 1)
					KeyBtn.TextColor3 = T.Accent
					KeyBtn.Text = KeyName(currentKey)
				end

				local function StartListening()
					listening = true
					KeyBtn.Text = "..."
					KeyBtn.TextColor3 = T.Warning
					Tween(KeyBtn, {BackgroundColor3 = T.TertiaryBG}, 0.15)
					AddStroke(KeyBtn, T.Warning, 1)

					listenConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						if input.KeyCode == Enum.KeyCode.Escape then
							StopListening()
							return
						end
						currentKey = input.KeyCode
						callback(currentKey)
						StopListening()
					end)
				end

				KeyBtn.MouseEnter:Connect(function()
					if not listening then
						Tween(KeyBtn, {BackgroundColor3 = T.ElementBG}, 0.12)
					end
				end)
				KeyBtn.MouseLeave:Connect(function()
					if not listening then
						Tween(KeyBtn, {BackgroundColor3 = T.Background}, 0.12)
					end
				end)
				KeyBtn.MouseButton1Click:Connect(function()
					if listening then StopListening() else StartListening() end
				end)

				local Keybind = {}
				function Keybind:Set(keyCode)
					currentKey = keyCode
					if not listening then KeyBtn.Text = KeyName(currentKey) end
					callback(currentKey)
				end
				function Keybind:Get()
					return currentKey
				end
				return Keybind
			end

			function Section:CreateDropdown(config)
				config = config or {}
				local name     = config.Name        or "Dropdown"
				local desc     = config.Description or ""
				local options  = config.Options     or {}
				local default  = config.Default
				local callback = config.Callback    or function() end

				local Row = Create("Frame", {
					Name             = "DropdownRow",
					Size             = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ClipsDescendants = false,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				local LabelF = Create("Frame", {
					Name                   = "DropdownLabelFrame",
					Size                   = UDim2.new(0.55, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex                 = 1013,
					Parent                 = Row,
				})
				AddPadding(LabelF, 0, 0, 0, 10)

				Create("TextLabel", {
					Name                   = "DropdownName",
					Size                   = UDim2.new(1, 0, 0, 18),
					Position               = desc ~= "" and UDim2.new(0, 0, 0.5, -17) or UDim2.new(0, 0, 0.5, -9),
					BackgroundTransparency = 1,
					Text                   = name,
					TextColor3             = T.TextPrimary,
					TextSize               = 13,
					Font                   = Enum.Font.GothamSemibold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1014,
					Parent                 = LabelF,
				})
				if desc ~= "" then
					Create("TextLabel", {
						Name                   = "DropdownDesc",
						Size                   = UDim2.new(1, 0, 0, 13),
						Position               = UDim2.new(0, 0, 0.5, 2),
						BackgroundTransparency = 1,
						Text                   = desc,
						TextColor3             = T.TextMuted,
						TextSize               = 10,
						Font                   = Enum.Font.Gotham,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 1014,
						Parent                 = LabelF,
					})
				end

				local BtnF = Create("TextButton", {
					Name             = "DropdownBtn",
					Size             = UDim2.new(0, 120, 0, 26),
					Position         = UDim2.new(1, -128, 0.5, -13),
					BackgroundColor3 = T.Background,
					Text             = "",
					AutoButtonColor  = false,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(BtnF, 6)
				AddStroke(BtnF, T.Border, 1)

				local Selected = Create("TextLabel", {
					Name                   = "DropdownSelected",
					Size                   = UDim2.new(1, -26, 1, 0),
					Position               = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text                   = default or "Select...",
					TextColor3             = default and T.TextPrimary or T.TextMuted,
					TextSize               = 11,
					Font                   = Enum.Font.Gotham,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1016,
					Parent                 = BtnF,
				})

				local Arrow = Create("TextLabel", {
					Name                   = "DropdownArrow",
					Size                   = UDim2.new(0, 18, 1, 0),
					Position               = UDim2.new(1, -20, 0, 0),
					BackgroundTransparency = 1,
					Text                   = "▾",
					TextColor3             = T.TextMuted,
					TextSize               = 12,
					Font                   = Enum.Font.GothamBold,
					ZIndex                 = 1016,
					Parent                 = BtnF,
				})

				-- Panel lives in ScreenGui so it escapes clipping — ZIndex 5000
				local Panel = Create("Frame", {
					Name             = "DropdownPanel",
					Size             = UDim2.new(0, 120, 0, 0),
					BackgroundColor3 = T.SecondaryBG,
					BorderSizePixel  = 0,
					ClipsDescendants = true,
					Visible          = false,
					ZIndex           = 5000,
					Parent           = ScreenGui,
				})
				AddCorner(Panel, 7)
				AddStroke(Panel, T.Border, 1)

				local PanelList = Create("Frame", {
					Name                   = "DropdownPanelList",
					Size                   = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					AutomaticSize          = Enum.AutomaticSize.Y,
					ZIndex                 = 5001,
					Parent                 = Panel,
				})
				AddPadding(PanelList, 4, 4, 4, 4)
				AddListLayout(PanelList, 3)

				local open          = false
				local selectedValue = default
				local trackConn     = nil

				local function UpdatePanelPosition()
					local abs = BtnF.AbsolutePosition
					local sz  = BtnF.AbsoluteSize
					Panel.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
				end

				local function ClosePanel()
					open = false
					if trackConn then trackConn:Disconnect(); trackConn = nil end
					Tween(Panel, {Size = UDim2.new(0, 120, 0, 0)}, 0.15)
					Tween(Arrow, {Rotation = 0}, 0.15)
					task.wait(0.15)
					Panel.Visible = false
				end

				for _, opt in ipairs(options) do
					local Opt = Create("TextButton", {
						Name             = "DropdownOpt_" .. opt,
						Size             = UDim2.new(1, 0, 0, 26),
						BackgroundColor3 = T.TertiaryBG,
						Text             = opt,
						TextColor3       = T.TextSecondary,
						TextSize         = 11,
						Font             = Enum.Font.Gotham,
						AutoButtonColor  = false,
						ZIndex           = 5002,
						Parent           = PanelList,
					})
					AddCorner(Opt, 5)
					Opt.MouseEnter:Connect(function()
						Tween(Opt, {BackgroundColor3 = T.ElementHover, TextColor3 = T.TextPrimary}, 0.1)
					end)
					Opt.MouseLeave:Connect(function()
						Tween(Opt, {BackgroundColor3 = T.TertiaryBG, TextColor3 = T.TextSecondary}, 0.1)
					end)
					Opt.MouseButton1Click:Connect(function()
						selectedValue       = opt
						Selected.Text       = opt
						Selected.TextColor3 = T.TextPrimary
						ClosePanel()
						callback(opt)
					end)
				end

				BtnF.MouseButton1Click:Connect(function()
					open = not open
					local contentH = #options * 29 + 8
					if open then
						UpdatePanelPosition()
						Panel.Size    = UDim2.new(0, 120, 0, 0)
						Panel.Visible = true
						Tween(Panel, {Size = UDim2.new(0, 120, 0, math.min(contentH, 150))}, 0.2)
						Tween(Arrow, {Rotation = 180}, 0.2)
						trackConn = RunService.RenderStepped:Connect(UpdatePanelPosition)
					else
						ClosePanel()
					end
				end)

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				local Dropdown = {}
				function Dropdown:Set(v)
					selectedValue       = v
					Selected.Text       = v
					Selected.TextColor3 = T.TextPrimary
					callback(v)
				end
				function Dropdown:Get() return selectedValue end
				return Dropdown
			end

			function Section:CreateMultiDropdown(config)
				config = config or {}
				local name     = config.Name        or "MultiDropdown"
				local desc     = config.Description or ""
				local options  = config.Options     or {}
				local defaults = config.Defaults    or {}
				local callback = config.Callback    or function() end

				local selected = {}
				for _, v in ipairs(defaults) do selected[v] = true end

				local Row = Create("Frame", {
					Name             = "MultiDropRow",
					Size             = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ClipsDescendants = false,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				local LabelF = Create("Frame", {
					Name                   = "MultiDropLabelFrame",
					Size                   = UDim2.new(0.5, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex                 = 1013,
					Parent                 = Row,
				})
				AddPadding(LabelF, 0, 0, 0, 10)

				Create("TextLabel", {
					Name                   = "MultiDropName",
					Size                   = UDim2.new(1, 0, 0, 18),
					Position               = desc ~= "" and UDim2.new(0, 0, 0.5, -17) or UDim2.new(0, 0, 0.5, -9),
					BackgroundTransparency = 1,
					Text                   = name,
					TextColor3             = T.TextPrimary,
					TextSize               = 13,
					Font                   = Enum.Font.GothamSemibold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1014,
					Parent                 = LabelF,
				})
				if desc ~= "" then
					Create("TextLabel", {
						Name                   = "MultiDropDesc",
						Size                   = UDim2.new(1, 0, 0, 13),
						Position               = UDim2.new(0, 0, 0.5, 2),
						BackgroundTransparency = 1,
						Text                   = desc,
						TextColor3             = T.TextMuted,
						TextSize               = 10,
						Font                   = Enum.Font.Gotham,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 1014,
						Parent                 = LabelF,
					})
				end

				local BtnF = Create("TextButton", {
					Name             = "MultiDropBtn",
					Size             = UDim2.new(0, 130, 0, 26),
					Position         = UDim2.new(1, -138, 0.5, -13),
					BackgroundColor3 = T.Background,
					Text             = "",
					AutoButtonColor  = false,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(BtnF, 6)
				AddStroke(BtnF, T.Border, 1)

				local function GetSelText()
					local keys = {}
					for k in pairs(selected) do keys[#keys + 1] = k end
					if #keys == 0 then return "None" end
					if #keys <= 2  then return table.concat(keys, ", ") end
					return keys[1] .. " .." .. #keys .. " sel"
				end

				local SelLabel = Create("TextLabel", {
					Name                   = "MultiDropSelLabel",
					Size                   = UDim2.new(1, -22, 1, 0),
					Position               = UDim2.new(0, 6, 0, 0),
					BackgroundTransparency = 1,
					Text                   = GetSelText(),
					TextColor3             = T.TextPrimary,
					TextSize               = 10,
					Font                   = Enum.Font.Gotham,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1016,
					Parent                 = BtnF,
				})

				local Arrow = Create("TextLabel", {
					Name                   = "MultiDropArrow",
					Size                   = UDim2.new(0, 18, 1, 0),
					Position               = UDim2.new(1, -20, 0, 0),
					BackgroundTransparency = 1,
					Text                   = "▾",
					TextColor3             = T.TextMuted,
					TextSize               = 12,
					Font                   = Enum.Font.GothamBold,
					ZIndex                 = 1016,
					Parent                 = BtnF,
				})

				-- Panel in ScreenGui — ZIndex 5000
				local Panel = Create("Frame", {
					Name             = "MultiDropPanel",
					Size             = UDim2.new(0, 130, 0, 0),
					BackgroundColor3 = T.SecondaryBG,
					BorderSizePixel  = 0,
					ClipsDescendants = true,
					Visible          = false,
					ZIndex           = 5000,
					Parent           = ScreenGui,
				})
				AddCorner(Panel, 7)
				AddStroke(Panel, T.Border, 1)

				local PList = Create("Frame", {
					Name                   = "MultiDropPanelList",
					Size                   = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					AutomaticSize          = Enum.AutomaticSize.Y,
					ZIndex                 = 5001,
					Parent                 = Panel,
				})
				AddPadding(PList, 4, 4, 4, 4)
				AddListLayout(PList, 3)

				local open      = false
				local trackConn = nil

				local function UpdatePanelPosition()
					local abs = BtnF.AbsolutePosition
					local sz  = BtnF.AbsoluteSize
					Panel.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
				end

				local function ClosePanel()
					open = false
					if trackConn then trackConn:Disconnect(); trackConn = nil end
					Tween(Panel, {Size = UDim2.new(0, 130, 0, 0)}, 0.15)
					Tween(Arrow, {Rotation = 0}, 0.15)
					task.wait(0.15)
					Panel.Visible = false
				end

				for _, opt in ipairs(options) do
					local isOn = selected[opt] or false

					local OptRow = Create("Frame", {
						Name             = "MultiDropOpt_" .. opt,
						Size             = UDim2.new(1, 0, 0, 26),
						BackgroundColor3 = isOn and T.ElementBG or T.TertiaryBG,
						ZIndex           = 5002,
						Parent           = PList,
					})
					AddCorner(OptRow, 5)

					local ChkBox = Create("Frame", {
						Name             = "ChkBox",
						Size             = UDim2.new(0, 14, 0, 14),
						Position         = UDim2.new(0, 6, 0.5, -7),
						BackgroundColor3 = isOn and T.Accent or T.ElementBG,
						ZIndex           = 5003,
						Parent           = OptRow,
					})
					AddCorner(ChkBox, 3)
					local ChkStroke = AddStroke(ChkBox, isOn and T.Accent or T.Border, 1)

					local Tick = Create("TextLabel", {
						Name                   = "Tick",
						Size                   = UDim2.new(0, 8, 0, 8),
						Position               = UDim2.new(0.5, -4, 0.5, -4),
						BackgroundTransparency = 1,
						Text                   = "✓",
						TextColor3             = T.TextPrimary,
						TextSize               = 9,
						Font                   = Enum.Font.GothamBold,
						TextTransparency       = isOn and 0 or 1,
						ZIndex                 = 5004,
						Parent                 = ChkBox,
					})

					local OptLabel = Create("TextLabel", {
						Name                   = "OptLabel",
						Size                   = UDim2.new(1, -28, 1, 0),
						Position               = UDim2.new(0, 26, 0, 0),
						BackgroundTransparency = 1,
						Text                   = opt,
						TextColor3             = isOn and T.TextPrimary or T.TextSecondary,
						TextSize               = 11,
						Font                   = Enum.Font.Gotham,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 5003,
						Parent                 = OptRow,
					})

					local Clickable = Create("TextButton", {
						Name                   = "OptClickable",
						Size                   = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text                   = "",
						ZIndex                 = 5005,
						Parent                 = OptRow,
					})
					Clickable.MouseButton1Click:Connect(function()
						if selected[opt] then
							selected[opt] = nil
						else
							selected[opt] = true
						end
						local on = selected[opt] ~= nil
						Tween(OptRow,    {BackgroundColor3 = on and T.ElementBG or T.TertiaryBG}, 0.12)
						Tween(ChkBox,    {BackgroundColor3 = on and T.Accent    or T.ElementBG},  0.12)
						Tween(ChkStroke, {Color = on and T.Accent or T.Border}, 0.12)
						Tick.TextTransparency = on and 0 or 1
						OptLabel.TextColor3   = on and T.TextPrimary or T.TextSecondary
						SelLabel.Text         = GetSelText()
						local sel = {}
						for k in pairs(selected) do sel[#sel + 1] = k end
						callback(sel)
					end)
				end

				BtnF.MouseButton1Click:Connect(function()
					open = not open
					local contentH = #options * 29 + 8
					if open then
						UpdatePanelPosition()
						Panel.Size    = UDim2.new(0, 130, 0, 0)
						Panel.Visible = true
						Tween(Panel, {Size = UDim2.new(0, 130, 0, math.min(contentH, 160))}, 0.2)
						Tween(Arrow, {Rotation = 180}, 0.2)
						trackConn = RunService.RenderStepped:Connect(UpdatePanelPosition)
					else
						ClosePanel()
					end
				end)

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				local MultiDropdown = {}
				function MultiDropdown:Get()
					local sel = {}
					for k in pairs(selected) do sel[#sel + 1] = k end
					return sel
				end
				function MultiDropdown:Set(tbl)
					selected = {}
					for _, v in ipairs(tbl) do selected[v] = true end
					SelLabel.Text = GetSelText()
					callback(self:Get())
				end
				return MultiDropdown
			end

			function Section:CreateLabel(config)
				config = config or {}
				local name = config.Name        or ""
				local desc = config.Description or ""

				local Row = Create("Frame", {
					Name             = "LabelRow",
					Size             = UDim2.new(1, 0, 0, (desc ~= "" and 48 or 34)),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)
				AddPadding(Row, 8, 10, 8, 10)
				AddListLayout(Row, 2)

				if name ~= "" then
					Create("TextLabel", {
						Name                   = "LabelName",
						Size                   = UDim2.new(1, 0, 0, 16),
						BackgroundTransparency = 1,
						Text                   = name,
						TextColor3             = T.TextPrimary,
						TextSize               = 13,
						Font                   = Enum.Font.GothamSemibold,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 1013,
						Parent                 = Row,
					})
				end
				if desc ~= "" then
					Create("TextLabel", {
						Name                   = "LabelDesc",
						Size                   = UDim2.new(1, 0, 0, 14),
						BackgroundTransparency = 1,
						Text                   = desc,
						TextColor3             = T.TextMuted,
						TextSize               = 11,
						Font                   = Enum.Font.Gotham,
						TextXAlignment         = Enum.TextXAlignment.Left,
						TextWrapped            = true,
						ZIndex                 = 1013,
						Parent                 = Row,
					})
				end

				return Row
			end

			function Section:CreateColorPicker(config)
				config = config or {}
				local name     = config.Name        or "Color Picker"
				local desc     = config.Description or ""
				local default  = config.Default     or Color3.fromRGB(255, 255, 255)
				local callback = config.Callback    or function() end

				local r0, g0, b0 = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)
				local currentColor   = default
				local tempColor      = default
				local confirmedColor = default
				local currentBrightness = 1

				local Row = Create("Frame", {
					Name             = "ColorPickerRow",
					Size             = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = T.ElementBG,
					BorderSizePixel  = 0,
					ClipsDescendants = false,
					ZIndex           = 1012,
					Parent           = SectionContent,
				})
				AddCorner(Row, 7)

				local LabelF = Create("Frame", {
					Name                   = "CPLabelFrame",
					Size                   = UDim2.new(0.55, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex                 = 1013,
					Parent                 = Row,
				})
				AddPadding(LabelF, 0, 0, 0, 10)

				Create("TextLabel", {
					Name                   = "CPName",
					Size                   = UDim2.new(1, 0, 0, 18),
					Position               = desc ~= "" and UDim2.new(0, 0, 0.5, -17) or UDim2.new(0, 0, 0.5, -9),
					BackgroundTransparency = 1,
					Text                   = name,
					TextColor3             = T.TextPrimary,
					TextSize               = 13,
					Font                   = Enum.Font.GothamSemibold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 1014,
					Parent                 = LabelF,
				})
				if desc ~= "" then
					Create("TextLabel", {
						Name                   = "CPDesc",
						Size                   = UDim2.new(1, 0, 0, 13),
						Position               = UDim2.new(0, 0, 0.5, 2),
						BackgroundTransparency = 1,
						Text                   = desc,
						TextColor3             = T.TextMuted,
						TextSize               = 10,
						Font                   = Enum.Font.Gotham,
						TextXAlignment         = Enum.TextXAlignment.Left,
						ZIndex                 = 1014,
						Parent                 = LabelF,
					})
				end

				local PreviewBtn = Create("TextButton", {
					Name             = "CPPreviewBtn",
					Size             = UDim2.new(0, 26, 0, 26),
					Position         = UDim2.new(1, -34, 0.5, -13),
					BackgroundColor3 = currentColor,
					Text             = "",
					AutoButtonColor  = false,
					ZIndex           = 1015,
					Parent           = Row,
				})
				AddCorner(PreviewBtn, 6)
				AddStroke(PreviewBtn, T.Border, 1)

				-- Color picker panel — ZIndex 5000
				local Panel = Create("Frame", {
					Name             = "CPPanel",
					Size             = UDim2.new(0, 280, 0, 0),
					BackgroundColor3 = T.SecondaryBG,
					BorderSizePixel  = 0,
					ClipsDescendants = true,
					Visible          = false,
					ZIndex           = 5000,
					Parent           = ScreenGui,
				})
				AddCorner(Panel, 10)
				AddStroke(Panel, T.Border, 1)

				local PanelInner = Create("Frame", {
					Name                   = "CPPanelInner",
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex                 = 5001,
					Parent                 = Panel,
				})
				AddPadding(PanelInner, 10, 10, 10, 10)

				local ColorWheelImg = Create("ImageLabel", {
					Name                   = "CPWheel",
					Size                   = UDim2.new(0, 110, 0, 110),
					Position               = UDim2.new(0, 10, 0, 10),
					BackgroundTransparency = 1,
					Image                  = "rbxassetid://6020299385",
					ZIndex                 = 5002,
					Parent                 = PanelInner,
				})
				AddCorner(ColorWheelImg, 55)

				local WheelDrag = Create("TextButton", {
					Name                   = "CPWheelDrag",
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 5004,
					Parent                 = ColorWheelImg,
				})

				local WheelCursor = Create("Frame", {
					Name             = "CPWheelCursor",
					Size             = UDim2.new(0, 10, 0, 10),
					Position         = UDim2.new(0.5, -5, 0.5, -5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 5005,
					Parent           = ColorWheelImg,
				})
				AddCorner(WheelCursor, 5)
				AddStroke(WheelCursor, Color3.fromRGB(0, 0, 0), 1)

				local BrightBG = Create("Frame", {
					Name             = "CPBrightBG",
					Size             = UDim2.new(0, 110, 0, 14),
					Position         = UDim2.new(0, 10, 0, 126),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 5002,
					Parent           = PanelInner,
				})
				AddCorner(BrightBG, 4)

				local BrightGrad = Instance.new("UIGradient")
				BrightGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
				BrightGrad.Rotation = 0
				BrightGrad.Parent   = BrightBG

				local BrightThumb = Create("Frame", {
					Name             = "CPBrightThumb",
					Size             = UDim2.new(0, 10, 0, 20),
					Position         = UDim2.new(1, -5, 0.5, -10),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 5004,
					Parent           = BrightBG,
				})
				AddCorner(BrightThumb, 3)
				AddStroke(BrightThumb, Color3.fromRGB(0, 0, 0), 1)

				local BrightDrag = Create("TextButton", {
					Name                   = "CPBrightDrag",
					Size                   = UDim2.new(1, 0, 1, 8),
					Position               = UDim2.new(0, 0, 0, -4),
					BackgroundTransparency = 1,
					Text                   = "",
					ZIndex                 = 5005,
					Parent                 = BrightBG,
				})

				local rightX = 130

				local function MakeRGBBox(label, posY, defaultVal)
					local Container = Create("Frame", {
						Name                   = "CPContainer_" .. label,
						Size                   = UDim2.new(0, 44, 0, 36),
						Position               = UDim2.new(0, rightX, 0, posY),
						BackgroundTransparency = 1,
						ZIndex                 = 5002,
						Parent                 = PanelInner,
					})

					Create("TextLabel", {
						Name                   = "CPLabel_" .. label,
						Size                   = UDim2.new(1, 0, 0, 13),
						Position               = UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 1,
						Text                   = label,
						TextColor3             = T.TextMuted,
						TextSize               = 10,
						Font                   = Enum.Font.GothamBold,
						TextXAlignment         = Enum.TextXAlignment.Center,
						ZIndex                 = 5003,
						Parent                 = Container,
					})

					local InputBG = Create("Frame", {
						Name             = "CPInputBG_" .. label,
						Size             = UDim2.new(1, 0, 0, 22),
						Position         = UDim2.new(0, 0, 0, 14),
						BackgroundColor3 = T.Background,
						BorderSizePixel  = 0,
						ZIndex           = 5003,
						Parent           = Container,
					})
					AddCorner(InputBG, 5)
					AddStroke(InputBG, T.Border, 1)

					local Input = Create("TextBox", {
						Name                   = "CPInput_" .. label,
						Size                   = UDim2.new(1, -6, 1, 0),
						Position               = UDim2.new(0, 3, 0, 0),
						BackgroundTransparency = 1,
						Text                   = tostring(defaultVal),
						TextColor3             = T.TextPrimary,
						PlaceholderColor3      = T.TextMuted,
						TextSize               = 11,
						Font                   = Enum.Font.GothamBold,
						TextXAlignment         = Enum.TextXAlignment.Center,
						ClearTextOnFocus       = false,
						ZIndex                 = 5004,
						Parent                 = InputBG,
					})

					return Input, InputBG, Container
				end

				local rInput, rBG, rCont = MakeRGBBox("R", 5, r0)
				local gInput, gBG, gCont = MakeRGBBox("G", 5, g0)
				local hInput, hBG, hCont = MakeRGBBox("B", 5, b0)

				rCont.Position = UDim2.new(0, rightX,      0, 5)
				gCont.Position = UDim2.new(0, rightX + 48, 0, 5)
				hCont.Position = UDim2.new(0, rightX + 96, 0, 5)

				local HexBG = Create("Frame", {
					Name             = "CPHexBG",
					Size             = UDim2.new(0, 140, 0, 22),
					Position         = UDim2.new(0, rightX, 0, 47),
					BackgroundColor3 = T.Background,
					BorderSizePixel  = 0,
					ZIndex           = 5002,
					Parent           = PanelInner,
				})
				AddCorner(HexBG, 5)
				AddStroke(HexBG, T.Border, 1)

				Create("TextLabel", {
					Name                   = "CPHexHash",
					Size                   = UDim2.new(0, 16, 1, 0),
					Position               = UDim2.new(0, 4, 0, 0),
					BackgroundTransparency = 1,
					Text                   = "#",
					TextColor3             = T.TextMuted,
					TextSize               = 11,
					Font                   = Enum.Font.GothamBold,
					ZIndex                 = 5003,
					Parent                 = HexBG,
				})

				local HexInput = Create("TextBox", {
					Name                   = "CPHexInput",
					Size                   = UDim2.new(1, -22, 1, 0),
					Position               = UDim2.new(0, 18, 0, 0),
					BackgroundTransparency = 1,
					Text                   = string.format("%02X%02X%02X", r0, g0, b0),
					TextColor3             = T.TextPrimary,
					PlaceholderText        = "RRGGBB",
					PlaceholderColor3      = T.TextMuted,
					TextSize               = 11,
					Font                   = Enum.Font.GothamBold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ClearTextOnFocus       = false,
					ZIndex                 = 5003,
					Parent                 = HexBG,
				})

				Create("TextLabel", {
					Name                   = "CPHexLabel",
					Size                   = UDim2.new(0, 140, 0, 13),
					Position               = UDim2.new(0, rightX, 0, 74),
					BackgroundTransparency = 1,
					Text                   = "HEX",
					TextColor3             = T.TextMuted,
					TextSize               = 10,
					Font                   = Enum.Font.GothamBold,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 5002,
					Parent                 = PanelInner,
				})

				local ConfirmBtn = Create("TextButton", {
					Name             = "CPConfirmBtn",
					Size             = UDim2.new(0, 140, 0, 24),
					Position         = UDim2.new(0, rightX, 0, 92),
					BackgroundColor3 = Color3.fromRGB(0, 200, 80),
					Text             = "Confirm",
					TextColor3       = Color3.fromRGB(0, 0, 0),
					TextSize         = 11,
					Font             = Enum.Font.GothamBold,
					AutoButtonColor  = false,
					ZIndex           = 5002,
					Parent           = PanelInner,
				})
				AddCorner(ConfirmBtn, 5)

				local ColorPickerObj  = {}
				local open            = false
				local trackConn       = nil
				local wheelDragging   = false
				local brightDragging  = false
				local baseHue, baseSat = 0, 1

				local function ColorToHex(c)
					return string.format("%02X%02X%02X",
						math.floor(c.R * 255),
						math.floor(c.G * 255),
						math.floor(c.B * 255)
					)
				end

				local function ApplyBrightness(h, s, v)
					return Color3.fromHSV(h, s, v)
				end

				local function UpdateAll(newColor, fromWheel)
					currentColor = newColor
					local nr = math.floor(newColor.R * 255)
					local ng = math.floor(newColor.G * 255)
					local nb = math.floor(newColor.B * 255)

					rInput.Text   = tostring(nr)
					gInput.Text   = tostring(ng)
					hInput.Text   = tostring(nb)
					HexInput.Text = ColorToHex(newColor)
					tempColor     = newColor
					PreviewBtn.BackgroundColor3 = newColor

					if fromWheel then
						local h, s, _ = Color3.toHSV(newColor)
						BrightGrad.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
						})
					end
				end

				local function SetFromRGB(r, g, b)
					r = math.clamp(r, 0, 255)
					g = math.clamp(g, 0, 255)
					b = math.clamp(b, 0, 255)
					local c = Color3.fromRGB(r, g, b)
					local h, s, v = Color3.toHSV(c)
					baseHue = h
					baseSat = s
					currentBrightness = v

					local px = 0.5 + s * math.cos(h * 2 * math.pi) * 0.5
					local py = 0.5 - s * math.sin(h * 2 * math.pi) * 0.5
					WheelCursor.Position = UDim2.new(px, -5, py, -5)

					local bp = 1 - v
					BrightThumb.Position = UDim2.new(bp, -5, 0.5, -10)
					UpdateAll(c, true)
				end

				local function PickFromWheel(inputPos)
					local abs    = ColorWheelImg.AbsolutePosition
					local size   = ColorWheelImg.AbsoluteSize
					local cx     = abs.X + size.X / 2
					local cy     = abs.Y + size.Y / 2
					local dx     = inputPos.X - cx
					local dy     = inputPos.Y - cy
					local radius = size.X / 2
					local dist   = math.sqrt(dx*dx + dy*dy)
					if dist > radius then
						dx   = dx / dist * radius
						dy   = dy / dist * radius
						dist = radius
					end
					local hue = (math.atan2(dy, -dx) / (2 * math.pi)) % 1
					local sat = dist / radius
					baseHue = hue
					baseSat = sat

					local px = 0.5 + (dx / radius) * 0.5
					local py = 0.5 + (dy / radius) * 0.5
					WheelCursor.Position = UDim2.new(px, -5, py, -5)

					local newColor = ApplyBrightness(hue, sat, currentBrightness)
					BrightGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
					})
					UpdateAll(newColor, false)
				end

				local function PickBrightness(inputPos)
					local abs  = BrightBG.AbsolutePosition
					local size = BrightBG.AbsoluteSize
					local relX = math.clamp((inputPos.X - abs.X) / size.X, 0, 1)
					currentBrightness    = 1 - relX
					BrightThumb.Position = UDim2.new(relX, -5, 0.5, -10)
					UpdateAll(ApplyBrightness(baseHue, baseSat, currentBrightness), false)
				end

				WheelDrag.MouseButton1Down:Connect(function()
					wheelDragging = true
					PickFromWheel(UserInputService:GetMouseLocation())
				end)
				BrightDrag.MouseButton1Down:Connect(function()
					brightDragging = true
					PickBrightness(UserInputService:GetMouseLocation())
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						wheelDragging  = false
						brightDragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						if wheelDragging  then PickFromWheel(input.Position)  end
						if brightDragging then PickBrightness(input.Position) end
					end
				end)

				local function OnRGBInput()
					local r = tonumber(rInput.Text) or 0
					local g = tonumber(gInput.Text) or 0
					local b = tonumber(hInput.Text) or 0
					SetFromRGB(r, g, b)
				end

				rInput.FocusLost:Connect(function() Tween(rBG, {BackgroundColor3 = T.Background}, 0.15) AddStroke(rBG, T.Border, 1) OnRGBInput() end)
				gInput.FocusLost:Connect(function() Tween(gBG, {BackgroundColor3 = T.Background}, 0.15) AddStroke(gBG, T.Border, 1) OnRGBInput() end)
				hInput.FocusLost:Connect(function() Tween(hBG, {BackgroundColor3 = T.Background}, 0.15) AddStroke(hBG, T.Border, 1) OnRGBInput() end)

				rInput.Focused:Connect(function() Tween(rBG, {BackgroundColor3 = T.SecondaryBG}, 0.15) AddStroke(rBG, T.Accent, 1) end)
				gInput.Focused:Connect(function() Tween(gBG, {BackgroundColor3 = T.SecondaryBG}, 0.15) AddStroke(gBG, T.Accent, 1) end)
				hInput.Focused:Connect(function() Tween(hBG, {BackgroundColor3 = T.SecondaryBG}, 0.15) AddStroke(hBG, T.Accent, 1) end)

				HexInput.Focused:Connect(function()
					Tween(HexBG, {BackgroundColor3 = T.SecondaryBG}, 0.15)
					AddStroke(HexBG, T.Accent, 1)
				end)
				HexInput.FocusLost:Connect(function(enter)
					Tween(HexBG, {BackgroundColor3 = T.Background}, 0.15)
					AddStroke(HexBG, T.Border, 1)
					if enter then
						local hex = HexInput.Text:gsub("#", ""):upper()
						if #hex == 6 then
							local r = tonumber(hex:sub(1, 2), 16) or 0
							local g = tonumber(hex:sub(3, 4), 16) or 0
							local b = tonumber(hex:sub(5, 6), 16) or 0
							SetFromRGB(r, g, b)
						end
					end
				end)

				local function UpdatePanelPosition()
					local abs = PreviewBtn.AbsolutePosition
					local sz  = PreviewBtn.AbsoluteSize
					Panel.Position = UDim2.new(0, abs.X - 246, 0, abs.Y + sz.Y + 6)
				end

				local function ClosePanel()
					open = false
					if trackConn then trackConn:Disconnect(); trackConn = nil end
					Tween(Panel, {Size = UDim2.new(0, 280, 0, 0)}, 0.2)
					PreviewBtn.BackgroundColor3 = confirmedColor
					tempColor = confirmedColor
					task.wait(0.2)
					Panel.Visible = false
				end

				PreviewBtn.MouseButton1Click:Connect(function()
					open = not open
					if open then
						UpdatePanelPosition()
						Panel.Size    = UDim2.new(0, 280, 0, 0)
						Panel.Visible = true
						Tween(Panel, {Size = UDim2.new(0, 280, 0, 152)}, 0.25, Enum.EasingStyle.Quart)
						trackConn = RunService.RenderStepped:Connect(UpdatePanelPosition)
						tempColor = confirmedColor
						SetFromRGB(
							math.floor(currentColor.R * 255),
							math.floor(currentColor.G * 255),
							math.floor(currentColor.B * 255)
						)
					else
						ClosePanel()
					end
				end)

				ConfirmBtn.MouseButton1Click:Connect(function()
					confirmedColor = tempColor
					currentColor   = confirmedColor
					callback(confirmedColor)
					ClosePanel()
				end)

				Row.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementHover}, 0.12) end)
				Row.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = T.ElementBG},    0.12) end)

				function ColorPickerObj:Set(color)
					currentColor = color
					SetFromRGB(
						math.floor(color.R * 255),
						math.floor(color.G * 255),
						math.floor(color.B * 255)
					)
				end
				function ColorPickerObj:Get()
					return currentColor
				end

				return ColorPickerObj
			end

			Section.SectionContent = SectionContent
			return Section
		end

		return Tab
	end

	return Window
end

return NexusUI
