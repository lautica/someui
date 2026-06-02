-- Skidded GUI Luau recreation
-- Single-file Roblox UI library. Returns a callable Library table.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {}
Library.Flags = {}
Library.Windows = {}
Library.IconAssets = {
	A = "rbxassetid://83474567030505",
	B = "rbxassetid://77418185570042",
	C = "rbxassetid://137111999800142",
	D = "rbxassetid://139664165841721",
	E = "rbxassetid://114754134951082",
	F = "rbxassetid://95544887759087",
	G = "rbxassetid://123415750905747",
	H = "rbxassetid://92442831588116",
	I = "rbxassetid://88775097140952",
	J = "rbxassetid://105630744570444",
	K = "rbxassetid://97591161545275",
	L = "rbxassetid://82021438703597",
	M = "rbxassetid://110781909515877",
	N = "rbxassetid://75577888614350",
	O = "rbxassetid://103262728701664",
	P = "rbxassetid://131233830141643",
	Q = "rbxassetid://100667593321549",
	R = "rbxassetid://139804455732286",
}

for key, value in pairs(table.clone(Library.IconAssets)) do
	Library.IconAssets["icon_" .. key] = value
end

local THEME = {
	Accent = Color3.fromRGB(103, 100, 255),

	WindowBackground = Color3.fromRGB(25, 25, 32),
	WindowBar = Color3.fromRGB(17, 17, 22),
	Child = Color3.fromRGB(20, 20, 27),
	Rect = Color3.fromRGB(25, 25, 33),
	Line = Color3.fromRGB(54, 55, 66),

	Text = Color3.fromRGB(255, 255, 255),
	TextInactive = Color3.fromRGB(86, 85, 106),
	SectionOn = Color3.fromRGB(77, 79, 95),
	WidgetsActive = Color3.fromRGB(35, 35, 46),
	WidgetBackground = Color3.fromRGB(28, 28, 39),
	WidgetInactive = Color3.fromRGB(47, 47, 63),
	Field = Color3.fromRGB(27, 27, 33),
	Separator = Color3.fromRGB(29, 29, 37),
	Danger = Color3.fromRGB(255, 122, 124),
}

local DIM = {
	Window = Vector2.new(905, 530),
	RailWidth = 65,
	WindowRounding = 16,

	SectionButton = 35,
	SectionTop = 81,
	SectionPadding = 15,
	SectionSpacing = 10,

	BarHeight = 80,
	BarPadding = 20,

	ContentX = 85,
	ContentY = 80,
	ContentWidth = 800,
	ColumnWidth = 390,
	ColumnGap = 20,
	ChildNameHeight = 24,
	ChildPadding = 10,
	ChildRounding = 8,

	CheckboxHeight = 40,
	CheckboxSize = Vector2.new(30, 20),
	CheckboxCircle = 14,

	SliderHeight = 40,
	SliderSize = Vector2.new(160, 6),
	SliderCircle = 12,

	DropdownHeight = 45,
	DropdownWidth = 160,
	DropdownInnerHeight = 25,
	DropdownRounding = 8,

	ButtonSize = Vector2.new(161, 40),
	SearchClosed = 40,
	SearchOpen = 340,
}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function cleanName(name)
	return tostring(name or ""):gsub("##.*", "")
end

local function resolveIcon(icon)
	if typeof(icon) == "table" then
		icon = icon.Icon or icon.Image or icon.Asset or icon.AssetId or icon.Id or icon[1]
	end
	if icon == nil then
		return ""
	end

	local key = tostring(icon)
	if Library.IconAssets[key] then
		return Library.IconAssets[key]
	end

	local upper = string.upper(key)
	if Library.IconAssets[upper] then
		return Library.IconAssets[upper]
	end

	local digits = key:match("^%s*(%d+)%s*$")
	if digits then
		return "rbxassetid://" .. digits
	end

	return key
end

local function isImageReference(value)
	value = tostring(value or "")
	return value:match("^rbxassetid://") ~= nil
		or value:match("^rbxasset://") ~= nil
		or value:match("^https?://") ~= nil
end

local function tween(instance, info, properties)
	local tw = TweenService:Create(instance, info or TWEEN, properties)
	tw:Play()
	return tw
end

local function safeCallback(callback, ...)
	if typeof(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function create(className, properties, children)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		object[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	return object
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(left, top, right, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
	})
end

local function listLayout(direction, spacing, align)
	return create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, spacing or 0),
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
	})
end

local function textLabel(properties)
	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = properties.Font or Enum.Font.GothamMedium,
		Text = properties.Text or "",
		TextColor3 = properties.TextColor3 or THEME.Text,
		TextSize = properties.TextSize or 14,
		TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center,
		TextTruncate = properties.TextTruncate or Enum.TextTruncate.AtEnd,
		RichText = properties.RichText or false,
		ZIndex = properties.ZIndex or 1,
	})
	for key, value in pairs(properties) do
		if key ~= "Font" and key ~= "Text" and key ~= "TextColor3" and key ~= "TextSize" and key ~= "TextXAlignment" and key ~= "TextYAlignment" and key ~= "TextTruncate" and key ~= "RichText" and key ~= "ZIndex" then
			label[key] = value
		end
	end
	return label
end

local function textButton(properties)
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = properties.BackgroundTransparency == nil and 1 or properties.BackgroundTransparency,
		BorderSizePixel = 0,
		Font = properties.Font or Enum.Font.GothamMedium,
		Text = properties.Text or "",
		TextColor3 = properties.TextColor3 or THEME.Text,
		TextSize = properties.TextSize or 14,
		TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Center,
		TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center,
		ZIndex = properties.ZIndex or 1,
	})
	for key, value in pairs(properties) do
		if key ~= "Font" and key ~= "Text" and key ~= "TextColor3" and key ~= "TextSize" and key ~= "TextXAlignment" and key ~= "TextYAlignment" and key ~= "ZIndex" and key ~= "BackgroundTransparency" then
			button[key] = value
		end
	end
	return button
end

local function imageIcon(icon, properties)
	properties = properties or {}
	local image = create("ImageLabel", {
		Name = properties.Name or "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = resolveIcon(icon),
		ImageColor3 = properties.ImageColor3 or THEME.Text,
		ImageTransparency = properties.ImageTransparency or 0,
		ScaleType = properties.ScaleType or Enum.ScaleType.Fit,
		AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0),
		Position = properties.Position or UDim2.fromOffset(0, 0),
		Size = properties.Size or UDim2.fromOffset(18, 18),
		ZIndex = properties.ZIndex or 1,
		Parent = properties.Parent,
	})
	for key, value in pairs(properties) do
		if key ~= "Name" and key ~= "ImageColor3" and key ~= "ImageTransparency" and key ~= "ScaleType" and key ~= "AnchorPoint" and key ~= "Position" and key ~= "Size" and key ~= "ZIndex" and key ~= "Parent" then
			image[key] = value
		end
	end
	return image
end

local function pointInside(guiObject, point)
	if not guiObject or not guiObject.Parent then
		return false
	end
	local pos = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

local function getDefaultParent()
	local localPlayer = Players.LocalPlayer
	if localPlayer then
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
		if playerGui then
			return playerGui
		end
	end
	return game:GetService("CoreGui")
end

local function makeSeparator(parent)
	return create("Frame", {
		Name = "Separator",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.Separator,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
end

local Window = {}
Window.__index = Window

local Section = {}
Section.__index = Section

local Child = {}
Child.__index = Child

local Control = {}
Control.__index = Control

function Control:Get()
	return self.Value
end

function Control:Set(value, silent)
	if self.SetValue then
		self:SetValue(value, silent)
	end
end

function Control:Destroy()
	if self.Row then
		self.Row:Destroy()
	end
end

function Window:_bindAccent(instance, property, transparencyWhenOff)
	table.insert(self.AccentBinds, {
		Instance = instance,
		Property = property,
		TransparencyWhenOff = transparencyWhenOff,
	})
	instance[property] = self.Theme.Accent
end

function Window:_setAccent(color)
	self.Theme.Accent = color
	THEME.Accent = color
	for _, bind in ipairs(self.AccentBinds) do
		if bind.Instance and bind.Instance.Parent then
			tween(bind.Instance, TWEEN, { [bind.Property] = color })
		end
	end
end

function Window:_registerControl(control)
	table.insert(self.Controls, control)
	table.insert(control.Child.Controls, control)
	if control.Flag then
		Library.Flags[control.Flag] = control.Value
	end
	return control
end

function Window:_applySearch()
	local query = string.lower(self.SearchText or "")
	for _, section in ipairs(self.Sections) do
		local sectionVisible = section == self.ActiveSection
		section.Page.Visible = sectionVisible
		if sectionVisible then
			for _, child in ipairs(section.Children) do
				local anyVisible = false
				for _, control in ipairs(child.Controls) do
					local matches = query == "" or string.find(string.lower(control.SearchName), query, 1, true) ~= nil
					control.Row.Visible = matches
					anyVisible = anyVisible or matches
				end
				child.Container.Visible = anyVisible or query == ""
			end
		end
	end
end

function Window:_closePopup()
	if self.SubPopup then
		self:_closeSubPopup()
	end

	local popup = self.OpenPopup
	if not popup then
		return
	end

	self.OpenPopup = nil
	if popup.Connection then
		popup.Connection:Disconnect()
	end

	local frame = popup.Frame
	if frame and frame.Parent then
		tween(frame, TWEEN_FAST, { GroupTransparency = 1 })
		task.delay(0.13, function()
			if frame and frame.Parent then
				frame:Destroy()
			end
		end)
	end
end

function Window:_closeSubPopup()
	local popup = self.SubPopup
	if not popup then
		return
	end

	self.SubPopup = nil
	if popup.Connection then
		popup.Connection:Disconnect()
	end

	local frame = popup.Frame
	if frame and frame.Parent then
		tween(frame, TWEEN_FAST, { GroupTransparency = 1 })
		task.delay(0.13, function()
			if frame and frame.Parent then
				frame:Destroy()
			end
		end)
	end
end

function Window:_openPopup(owner, width, build, positionMode, asSubPopup)
	if asSubPopup then
		self:_closeSubPopup()
	else
		self:_closePopup()
	end

	local popup = create("CanvasGroup", {
		Name = "Popup",
		BackgroundColor3 = THEME.WindowBackground,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Size = UDim2.fromOffset(width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 70,
		Parent = self.PopupLayer,
	}, {
		corner(8),
		padding(8, 8, 8, 8),
		listLayout(Enum.FillDirection.Vertical, 1),
	})

	build(popup)

	RunService.Heartbeat:Wait()
	local ownerPos = owner.AbsolutePosition
	local rootPos = self.Main.AbsolutePosition
	local x = ownerPos.X - rootPos.X
	local y
	if positionMode == "center" then
		y = ownerPos.Y - rootPos.Y + owner.AbsoluteSize.Y / 2 - popup.AbsoluteSize.Y / 2
	else
		y = ownerPos.Y - rootPos.Y + owner.AbsoluteSize.Y + 10
	end
	popup.Position = UDim2.fromOffset(math.floor(x), math.floor(y))

	local connection
	connection = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		task.defer(function()
			local point = Vector2.new(input.Position.X, input.Position.Y)
			if not pointInside(popup, point) and not pointInside(owner, point) then
				if asSubPopup then
					self:_closeSubPopup()
				else
					self:_closePopup()
				end
			end
		end)
	end)

	local record = {
		Frame = popup,
		Connection = connection,
	}
	if asSubPopup then
		self.SubPopup = record
	else
		self.OpenPopup = record
	end

	tween(popup, TWEEN_FAST, { GroupTransparency = 0 })
	return popup
end

function Window:SetVisible(visible)
	self.Visible = visible
	self.VisibilityToken = (self.VisibilityToken or 0) + 1
	local token = self.VisibilityToken
	if visible then
		self.Container.Visible = true
	end
	tween(self.Container, TWEEN, { GroupTransparency = visible and 0 or 1 })
	task.delay(visible and 0 or 0.18, function()
		if self.Container and self.Container.Parent and self.VisibilityToken == token then
			self.Container.Visible = visible
		end
	end)
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:SetDPI(percent)
	local scale = tonumber(percent) or 100
	self.Scale.Scale = scale / 100
	self.DPI = scale
end

function Window:GetFlag(flag)
	return Library.Flags[flag]
end

function Window:SetAccent(color)
	self:_setAccent(color)
end

function Window:Destroy()
	self:_closePopup()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

function Window:SetSection(section)
	if typeof(section) == "number" then
		section = self.Sections[section]
	end
	if not section or section == self.ActiveSection then
		return
	end

	local old = self.ActiveSection
	self.ActiveSection = section

	for _, entry in ipairs(self.Sections) do
		local active = entry == section
		entry.Page.Visible = active
		tween(entry.Button, TWEEN, {
			BackgroundTransparency = active and 0.8 or 1,
		})
		if entry.IconImage then
			tween(entry.IconImage, TWEEN, { ImageColor3 = active and THEME.Text or THEME.TextInactive })
		end
		if entry.FallbackIcon then
			tween(entry.FallbackIcon, TWEEN, { TextColor3 = active and THEME.Text or THEME.TextInactive })
		end
		if active then
			entry.Page.GroupTransparency = 1
			tween(entry.Page, TWEEN, { GroupTransparency = 0 })
		elseif old == entry then
			entry.Page.GroupTransparency = 1
		end
	end

	self:_applySearch()
end

function Window:Section(name, icon)
	local iconValue = icon
	if typeof(iconValue) == "table" then
		iconValue = iconValue.Icon or iconValue.Image or iconValue.Asset or iconValue.AssetId or iconValue.Id or iconValue[1]
	end

	local section = setmetatable({
		Window = self,
		Name = tostring(name or ("sec" .. tostring(#self.Sections + 1))),
		Icon = iconValue or string.sub(tostring(name or "?"), 1, 1),
		Children = {},
		ColumnCounts = { Left = 0, Right = 0 },
	}, Section)

	local index = #self.Sections + 1
	local button = textButton({
		Name = "Section_" .. section.Name,
		Text = "",
		BackgroundColor3 = THEME.SectionOn,
		BackgroundTransparency = index == 1 and 0.8 or 1,
		Size = UDim2.fromOffset(DIM.SectionButton, DIM.SectionButton),
		LayoutOrder = index,
		Parent = self.SectionList,
	})
	corner(4).Parent = button

	local initialIcon = resolveIcon(section.Icon)
	local hasInitialImage = isImageReference(initialIcon)

	section.IconImage = imageIcon(hasInitialImage and initialIcon or "", {
		Name = "TabIcon",
		ImageColor3 = index == 1 and THEME.Text or THEME.TextInactive,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = button.ZIndex + 1,
		Parent = button,
	})
	section.FallbackIcon = textLabel({
		Name = "FallbackIcon",
		Text = tostring(section.Icon),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = index == 1 and THEME.Text or THEME.TextInactive,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Visible = not hasInitialImage,
		ZIndex = button.ZIndex + 1,
		Parent = button,
	})
	section.IconImage.Visible = hasInitialImage

	button.MouseEnter:Connect(function()
		if self.ActiveSection ~= section then
			tween(section.IconImage, TWEEN, { ImageColor3 = THEME.Text })
			tween(section.FallbackIcon, TWEEN, { TextColor3 = THEME.Text })
		end
	end)
	button.MouseLeave:Connect(function()
		if self.ActiveSection ~= section then
			tween(section.IconImage, TWEEN, { ImageColor3 = THEME.TextInactive })
			tween(section.FallbackIcon, TWEEN, { TextColor3 = THEME.TextInactive })
		end
	end)
	button.MouseButton1Click:Connect(function()
		self:SetSection(section)
	end)
	section.Button = button

	local page = create("CanvasGroup", {
		Name = "Page_" .. section.Name,
		BackgroundTransparency = 1,
		GroupTransparency = index == 1 and 0 or 1,
		Position = UDim2.fromOffset(DIM.ContentX, DIM.ContentY),
		Size = UDim2.fromOffset(DIM.ContentWidth, 450),
		Visible = index == 1,
		ZIndex = 10,
		Parent = self.Main,
	})
	section.Page = page

	local leftColumn = create("Frame", {
		Name = "LeftColumn",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(DIM.ColumnWidth, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
		Parent = page,
	}, {
		listLayout(Enum.FillDirection.Vertical, DIM.ColumnGap),
	})

	local rightColumn = create("Frame", {
		Name = "RightColumn",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(DIM.ColumnWidth + DIM.ColumnGap, 0),
		Size = UDim2.fromOffset(DIM.ColumnWidth, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
		Parent = page,
	}, {
		listLayout(Enum.FillDirection.Vertical, DIM.ColumnGap),
	})

	section.LeftColumn = leftColumn
	section.RightColumn = rightColumn

	table.insert(self.Sections, section)
	if index == 1 then
		self.ActiveSection = section
	end

	return section
end

Window.CreateSection = Window.Section
Window.CreateTab = Window.Section
Window.Tab = Window.Section

function Section:SetIcon(icon)
	self.Icon = icon
	local resolved = resolveIcon(icon)
	local hasImage = isImageReference(resolved)
	local color = self.Window.ActiveSection == self and THEME.Text or THEME.TextInactive

	if self.IconImage then
		self.IconImage.Image = hasImage and resolved or ""
		self.IconImage.Visible = hasImage
		self.IconImage.ImageColor3 = color
	end

	if self.FallbackIcon then
		self.FallbackIcon.Text = tostring(icon or "")
		self.FallbackIcon.Visible = not hasImage
		self.FallbackIcon.TextColor3 = color
	end
end

function Window:SetSectionIcon(section, icon)
	if typeof(section) == "number" then
		section = self.Sections[section]
	elseif typeof(section) == "string" then
		for _, entry in ipairs(self.Sections) do
			if entry.Name == section then
				section = entry
				break
			end
		end
	end

	if section and section.SetIcon then
		section:SetIcon(icon)
	end
end

function Section:Child(name, side)
	local chosenSide = side
	if chosenSide ~= "Left" and chosenSide ~= "Right" then
		chosenSide = self.ColumnCounts.Left <= self.ColumnCounts.Right and "Left" or "Right"
	end
	self.ColumnCounts[chosenSide] += 1

	local child = setmetatable({
		Section = self,
		Window = self.Window,
		Name = tostring(name or "CHILD"),
		Controls = {},
	}, Child)

	local parentColumn = chosenSide == "Left" and self.LeftColumn or self.RightColumn

	local container = create("Frame", {
		Name = "Child_" .. child.Name,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(DIM.ColumnWidth, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self.ColumnCounts[chosenSide],
		ZIndex = 10,
		Parent = parentColumn,
	}, {
		listLayout(Enum.FillDirection.Vertical, 0),
	})

	local title = textLabel({
		Name = "Title",
		Text = string.upper(child.Name),
		TextColor3 = THEME.TextInactive,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, DIM.ChildNameHeight),
		ZIndex = 11,
		Parent = container,
	})

	local body = create("Frame", {
		Name = "Body",
		BackgroundColor3 = THEME.Child,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(DIM.ColumnWidth, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
		Parent = container,
	}, {
		corner(DIM.ChildRounding),
		stroke(THEME.Rect, 1, 0),
		padding(DIM.ChildPadding, 0, DIM.ChildPadding, 0),
		listLayout(Enum.FillDirection.Vertical, 1),
	})

	child.Container = container
	child.Title = title
	child.Body = body

	table.insert(self.Children, child)
	return child
end

Section.CreateChild = Section.Child
Section.Group = Section.Child

function Child:_controlBase(kind, options, height)
	options = options or {}
	local display = cleanName(options.Name or options.Title or kind)
	local flag = options.Flag or options.Name or options.Title

	local row = create("TextButton", {
		Name = kind .. "_" .. display,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 0, height),
		ZIndex = 12,
		Parent = self.Body,
	})
	makeSeparator(row)

	local label = textLabel({
		Name = "Label",
		Text = display,
		TextColor3 = THEME.TextInactive,
		TextSize = 14,
		Size = UDim2.new(1, -185, 1, 0),
		ZIndex = 13,
		Parent = row,
	})

	local control = setmetatable({
		Type = kind,
		Child = self,
		Window = self.Window,
		Row = row,
		Label = label,
		Options = options,
		Flag = flag,
		SearchName = string.lower(display),
		Value = options.Default,
		Callback = options.Callback,
	}, Control)

	return control
end

function Child:Toggle(options)
	local control = self:_controlBase("Toggle", options, DIM.CheckboxHeight)
	local value = options.Default == true
	control.Value = value

	local switch = create("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(DIM.CheckboxSize.X, DIM.CheckboxSize.Y),
		BackgroundColor3 = THEME.WidgetBackground,
		BorderSizePixel = 0,
		ZIndex = 14,
		Parent = control.Row,
	}, {
		corner(100),
	})

	local accentOverlay = create("Frame", {
		Name = "AccentOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = self.Window.Theme.Accent,
		BackgroundTransparency = value and 0.9 or 1,
		BorderSizePixel = 0,
		ZIndex = 15,
		Parent = switch,
	}, {
		corner(100),
	})
	self.Window:_bindAccent(accentOverlay, "BackgroundColor3")

	local knob = create("Frame", {
		Name = "Knob",
		Position = UDim2.fromOffset(value and 13 or 3, 3),
		Size = UDim2.fromOffset(DIM.CheckboxCircle, DIM.CheckboxCircle),
		BackgroundColor3 = value and self.Window.Theme.Accent or THEME.WidgetInactive,
		BorderSizePixel = 0,
		ZIndex = 16,
		Parent = switch,
	}, {
		corner(100),
	})

	local keyButton
	local keybind = {
		Key = options.Key,
		Mode = "Toggle",
		Show = true,
	}

	local function render(animated)
		local info = animated and TWEEN or TweenInfo.new(0)
		tween(control.Label, info, { TextColor3 = value and THEME.Text or THEME.TextInactive })
		tween(accentOverlay, info, { BackgroundTransparency = value and 0.9 or 1 })
		tween(knob, info, {
			Position = UDim2.fromOffset(value and 13 or 3, 3),
			BackgroundColor3 = value and self.Window.Theme.Accent or THEME.WidgetInactive,
		})
	end

	function control:SetValue(newValue, silent)
		value = newValue == true
		self.Value = value
		if self.Flag then
			Library.Flags[self.Flag] = value
		end
		render(true)
		if not silent then
			safeCallback(self.Callback, value)
		end
	end

	if options.Keybind then
		keyButton = textButton({
			Name = "Keybind",
			Text = "",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -45, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			ZIndex = 20,
			Parent = control.Row,
		})
		local keyIcon = imageIcon("I", {
			ImageColor3 = THEME.TextInactive,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			ZIndex = keyButton.ZIndex + 1,
			Parent = keyButton,
		})

		local captureConnection
		local function openKeybindPopup()
			self.Window:_openPopup(keyButton, 160, function(popup)
				local bindKey = textButton({
					Text = keybind.Key and ("Key: " .. keybind.Key.Name) or "New bind",
					TextColor3 = THEME.Text,
					TextSize = 12,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = bindKey

				local mode = textButton({
					Text = "Mode: " .. keybind.Mode,
					TextColor3 = THEME.Text,
					TextSize = 12,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = mode

				local reset = textButton({
					Text = "Reset",
					TextColor3 = THEME.Danger,
					TextSize = 12,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = reset

				local function hover(button, activeColor)
					button.MouseEnter:Connect(function()
						tween(button, TWEEN_FAST, { BackgroundTransparency = 0 })
					end)
					button.MouseLeave:Connect(function()
						tween(button, TWEEN_FAST, { BackgroundTransparency = 1 })
					end)
				end
				hover(bindKey)
				hover(mode)
				hover(reset)

				bindKey.MouseButton1Click:Connect(function()
					bindKey.Text = "Press a key"
					if captureConnection then
						captureConnection:Disconnect()
					end
					captureConnection = UserInputService.InputBegan:Connect(function(input, processed)
						if processed then
							return
						end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							keybind.Key = input.KeyCode
							bindKey.Text = "Key: " .. input.KeyCode.Name
							if captureConnection then
								captureConnection:Disconnect()
								captureConnection = nil
							end
						end
					end)
				end)

				mode.MouseButton1Click:Connect(function()
					keybind.Mode = keybind.Mode == "Toggle" and "Hold" or "Toggle"
					mode.Text = "Mode: " .. keybind.Mode
				end)

				reset.MouseButton1Click:Connect(function()
					keybind.Key = nil
					bindKey.Text = "New bind"
				end)
			end)
		end

		keyButton.MouseEnter:Connect(function()
			tween(keyIcon, TWEEN, { ImageColor3 = THEME.Text })
		end)
		keyButton.MouseLeave:Connect(function()
			tween(keyIcon, TWEEN, { ImageColor3 = THEME.TextInactive })
		end)
		keyButton.MouseButton1Click:Connect(openKeybindPopup)

		UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not keybind.Key or input.KeyCode ~= keybind.Key then
				return
			end
			if keybind.Mode == "Hold" then
				control:SetValue(true)
			else
				control:SetValue(not control.Value)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if keybind.Mode == "Hold" and keybind.Key and input.KeyCode == keybind.Key then
				control:SetValue(false)
			end
		end)
	end

	control.Row.MouseButton1Click:Connect(function()
		control:SetValue(not value)
	end)

	render(false)
	self.Window:_registerControl(control)
	return control
end

Child.Checkbox = Child.Toggle
Child.AddToggle = Child.Toggle

function Child:Slider(options)
	local control = self:_controlBase("Slider", options, DIM.SliderHeight)
	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	local decimals = tonumber(options.Decimals) or 0
	local value = tonumber(options.Default) or min
	value = math.clamp(value, min, max)
	control.Value = value

	local valueLabel = textLabel({
		Name = "Value",
		Text = "",
		TextColor3 = THEME.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -175, 0.5, 0),
		Size = UDim2.fromOffset(65, 24),
		ZIndex = 14,
		Parent = control.Row,
	})

	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(DIM.SliderSize.X, DIM.SliderSize.Y),
		BackgroundColor3 = THEME.WidgetBackground,
		BorderSizePixel = 0,
		ZIndex = 14,
		Parent = control.Row,
	}, {
		corner(100),
	})

	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromOffset(0, DIM.SliderSize.Y),
		BackgroundColor3 = self.Window.Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 15,
		Parent = track,
	}, {
		corner(100),
	})
	self.Window:_bindAccent(fill, "BackgroundColor3")

	local knob = create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(DIM.SliderCircle, DIM.SliderCircle),
		BackgroundColor3 = THEME.Text,
		BorderSizePixel = 0,
		ZIndex = 16,
		Parent = track,
	}, {
		corner(100),
	})

	local dragging = false

	local function formatValue(number)
		if typeof(options.Format) == "function" then
			return options.Format(number)
		end
		if typeof(options.Format) == "string" then
			return string.format(options.Format, number)
		end
		local rounded = decimals > 0 and tonumber(string.format("%." .. decimals .. "f", number)) or math.floor(number + 0.5)
		return tostring(rounded) .. tostring(options.Suffix or "")
	end

	local function render(animated)
		local alpha = (value - min) / math.max(max - min, 1)
		local px = alpha * DIM.SliderSize.X
		local info = animated and TWEEN or TweenInfo.new(0)
		valueLabel.Text = formatValue(value)
		tween(fill, info, { Size = UDim2.fromOffset(px, DIM.SliderSize.Y) })
		tween(knob, info, { Position = UDim2.fromOffset(px, DIM.SliderSize.Y / 2) })
	end

	local function fromInput(input, silent)
		local x = input.Position.X
		local startX = track.AbsolutePosition.X
		local width = track.AbsoluteSize.X
		local alpha = math.clamp((x - startX) / math.max(width, 1), 0, 1)
		local nextValue = min + (max - min) * alpha
		if decimals <= 0 then
			nextValue = math.floor(nextValue + 0.5)
		else
			local mult = 10 ^ decimals
			nextValue = math.floor(nextValue * mult + 0.5) / mult
		end
		control:SetValue(nextValue, silent)
	end

	function control:SetValue(newValue, silent)
		value = math.clamp(tonumber(newValue) or min, min, max)
		self.Value = value
		if self.Flag then
			Library.Flags[self.Flag] = value
		end
		render(true)
		if not silent then
			safeCallback(self.Callback, value)
		end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	render(false)
	self.Window:_registerControl(control)
	return control
end

Child.AddSlider = Child.Slider

function Child:Dropdown(options)
	local control = self:_controlBase("Dropdown", options, DIM.DropdownHeight)
	local items = options.Items or options.Values or {}
	local index = tonumber(options.DefaultIndex)
	local selected = options.Default
	if index and items[index] then
		selected = items[index]
	elseif selected == nil then
		selected = items[1]
	end
	control.Value = selected

	local button = textButton({
		Name = "DropdownButton",
		Text = "",
		BackgroundColor3 = THEME.WidgetBackground,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(DIM.DropdownWidth, DIM.DropdownInnerHeight),
		ZIndex = 14,
		Parent = control.Row,
	})
	corner(4).Parent = button

	local preview = textLabel({
		Name = "Preview",
		Text = tostring(selected or "..."),
		TextColor3 = THEME.Text,
		TextSize = 11,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -32, 1, 0),
		ZIndex = 15,
		Parent = button,
	})

	local arrow = imageIcon("G", {
		Name = "Arrow",
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Size = UDim2.fromOffset(10, DIM.DropdownInnerHeight),
		ZIndex = 15,
		Parent = button,
	})

	function control:SetValue(newValue, silent)
		selected = newValue
		self.Value = selected
		preview.Text = tostring(selected or "...")
		if self.Flag then
			Library.Flags[self.Flag] = selected
		end
		if not silent then
			safeCallback(self.Callback, selected)
		end
	end

	local function open()
		self.Window:_openPopup(button, DIM.DropdownWidth, function(popup)
			for _, item in ipairs(items) do
				local active = item == selected
				local itemButton = textButton({
					Text = tostring(item),
					TextColor3 = active and THEME.Text or THEME.TextInactive,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = active and 0 or 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = itemButton

				local check = imageIcon("R", {
					ImageColor3 = THEME.Text,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(12, 24),
					Visible = active,
					ZIndex = 73,
					Parent = itemButton,
				})
				itemButton.TextXAlignment = Enum.TextXAlignment.Left
				itemButton.Text = "     " .. tostring(item)

				itemButton.MouseEnter:Connect(function()
					tween(itemButton, TWEEN_FAST, { TextColor3 = THEME.Text, BackgroundTransparency = 0 })
				end)
				itemButton.MouseLeave:Connect(function()
					if item ~= selected then
						tween(itemButton, TWEEN_FAST, { TextColor3 = THEME.TextInactive, BackgroundTransparency = 1 })
					end
				end)
				itemButton.MouseButton1Click:Connect(function()
					control:SetValue(item)
					self.Window:_closePopup()
				end)
			end
		end, "center")
	end

	button.MouseButton1Click:Connect(open)
	control.Row.MouseButton1Click:Connect(open)
	self.Window:_registerControl(control)
	return control
end

Child.AddDropdown = Child.Dropdown

function Child:MultiDropdown(options)
	local control = self:_controlBase("MultiDropdown", options, DIM.DropdownHeight)
	local items = options.Items or options.Values or {}
	local state = {}
	for _, item in ipairs(items) do
		state[item] = false
	end
	for _, item in ipairs(options.Default or {}) do
		state[item] = true
	end

	local button = textButton({
		Name = "MultiDropdownButton",
		Text = "",
		BackgroundColor3 = THEME.WidgetBackground,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(DIM.DropdownWidth, DIM.DropdownInnerHeight),
		ZIndex = 14,
		Parent = control.Row,
	})
	corner(4).Parent = button

	local preview = textLabel({
		Name = "Preview",
		Text = "...",
		TextColor3 = THEME.Text,
		TextSize = 11,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -32, 1, 0),
		ZIndex = 15,
		Parent = button,
	})

	imageIcon("G", {
		Name = "Arrow",
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Size = UDim2.fromOffset(10, DIM.DropdownInnerHeight),
		ZIndex = 15,
		Parent = button,
	})

	local function selectedArray()
		local out = {}
		for _, item in ipairs(items) do
			if state[item] then
				table.insert(out, item)
			end
		end
		return out
	end

	local function renderPreview()
		local chosen = selectedArray()
		preview.Text = #chosen > 0 and table.concat(chosen, ", ") or "..."
		control.Value = chosen
		if control.Flag then
			Library.Flags[control.Flag] = chosen
		end
	end

	function control:SetValue(newValue, silent)
		for _, item in ipairs(items) do
			state[item] = false
		end
		for _, item in ipairs(newValue or {}) do
			if state[item] ~= nil then
				state[item] = true
			end
		end
		renderPreview()
		if not silent then
			safeCallback(self.Callback, self.Value)
		end
	end

	local function open()
		self.Window:_openPopup(button, DIM.DropdownWidth, function(popup)
			for _, item in ipairs(items) do
				local itemButton = textButton({
					Text = "     " .. tostring(item),
					TextColor3 = state[item] and THEME.Text or THEME.TextInactive,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = state[item] and 0 or 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = itemButton

				local check = imageIcon("R", {
					ImageColor3 = THEME.Text,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(12, 24),
					Visible = state[item],
					ZIndex = 73,
					Parent = itemButton,
				})

				itemButton.MouseEnter:Connect(function()
					tween(itemButton, TWEEN_FAST, { TextColor3 = THEME.Text, BackgroundTransparency = 0 })
				end)
				itemButton.MouseLeave:Connect(function()
					if not state[item] then
						tween(itemButton, TWEEN_FAST, { TextColor3 = THEME.TextInactive, BackgroundTransparency = 1 })
					end
				end)
				itemButton.MouseButton1Click:Connect(function()
					state[item] = not state[item]
					check.Visible = state[item]
					tween(itemButton, TWEEN_FAST, {
						TextColor3 = state[item] and THEME.Text or THEME.TextInactive,
						BackgroundTransparency = state[item] and 0 or 1,
					})
					renderPreview()
					safeCallback(control.Callback, control.Value)
				end)
			end
		end, "center")
	end

	button.MouseButton1Click:Connect(open)
	control.Row.MouseButton1Click:Connect(open)
	renderPreview()
	self.Window:_registerControl(control)
	return control
end

Child.AddMultiDropdown = Child.MultiDropdown

function Child:Button(options)
	local control = self:_controlBase("Button", options, DIM.DropdownHeight)
	control.Label.Visible = false

	local button = textButton({
		Name = "Button",
		Text = cleanName(options.Name or "Button"),
		TextColor3 = THEME.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = THEME.Child,
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(DIM.ButtonSize.X, DIM.ButtonSize.Y),
		Position = UDim2.fromOffset(0, 2),
		ZIndex = 14,
		Parent = control.Row,
	})
	corner(8).Parent = button
	local buttonStroke = stroke(THEME.Rect, 1, 0)
	buttonStroke.Parent = button

	local iconRect = create("Frame", {
		Name = "IconRect",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(40, 40),
		ZIndex = 15,
		Parent = button,
	})
	create("Frame", {
		Name = "IconLine",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(1, 40),
		BackgroundColor3 = THEME.Rect,
		BorderSizePixel = 0,
		ZIndex = 16,
		Parent = iconRect,
	})
	imageIcon(options.Icon or "H", {
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 17,
		Parent = iconRect,
	})
	button.Text = "            " .. cleanName(options.Name or "Button")

	button.MouseEnter:Connect(function()
		tween(buttonStroke, TWEEN, { Color = self.Window.Theme.Accent })
	end)
	button.MouseLeave:Connect(function()
		tween(buttonStroke, TWEEN, { Color = THEME.Rect })
	end)
	button.MouseButton1Click:Connect(function()
		tween(buttonStroke, TWEEN_FAST, { Color = self.Window.Theme.Accent })
		task.delay(0.16, function()
			if buttonStroke and buttonStroke.Parent then
				tween(buttonStroke, TWEEN, { Color = THEME.Rect })
			end
		end)
		safeCallback(options.Callback)
	end)

	self.Window:_registerControl(control)
	return control
end

Child.AddButton = Child.Button

function Child:Textbox(options)
	local control = self:_controlBase("Textbox", options, 50)
	control.Label.Visible = false
	local value = tostring(options.Default or "")
	control.Value = value

	local boxFrame = create("Frame", {
		Name = "TextboxFrame",
		BackgroundColor3 = THEME.Field,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		ZIndex = 14,
		Parent = control.Row,
	}, {
		corner(4),
	})

	local box = create("TextBox", {
		Name = "Textbox",
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		Text = value,
		PlaceholderText = cleanName(options.Name or "Text"),
		PlaceholderColor3 = THEME.TextInactive,
		TextColor3 = THEME.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -46, 1, 0),
		ZIndex = 15,
		Parent = boxFrame,
	})

	imageIcon("K", {
		ImageColor3 = THEME.TextInactive,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(14, 30),
		ZIndex = 15,
		Parent = boxFrame,
	})

	function control:SetValue(newValue, silent)
		value = tostring(newValue or "")
		self.Value = value
		box.Text = value
		if self.Flag then
			Library.Flags[self.Flag] = value
		end
		if not silent then
			safeCallback(self.Callback, value)
		end
	end

	box:GetPropertyChangedSignal("Text"):Connect(function()
		value = box.Text
		control.Value = value
		if control.Flag then
			Library.Flags[control.Flag] = value
		end
		safeCallback(control.Callback, value)
	end)

	self.Window:_registerControl(control)
	return control
end

Child.Input = Child.Textbox
Child.AddTextbox = Child.Textbox

function Window:_makeSearch()
	local searchFrame = create("Frame", {
		Name = "Search",
		BackgroundColor3 = THEME.Child,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.fromOffset(DIM.SearchClosed, 40),
		ZIndex = 20,
		Parent = self.TopBar,
	}, {
		corner(8),
		stroke(THEME.Rect, 1, 0),
	})

	local box = create("TextBox", {
		Name = "SearchBox",
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		Text = "",
		PlaceholderText = "",
		TextColor3 = THEME.Text,
		TextTransparency = 1,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -48, 1, 0),
		ZIndex = 21,
		Parent = searchFrame,
	})

	imageIcon("J", {
		Name = "Icon",
		ImageColor3 = THEME.TextInactive,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Size = UDim2.fromOffset(16, 40),
		ZIndex = 22,
		Parent = searchFrame,
	})

	local function updateSize()
		local active = box:IsFocused() or #box.Text > 0
		local width = active and DIM.SearchOpen or DIM.SearchClosed
		tween(searchFrame, TWEEN_SLOW, { Size = UDim2.fromOffset(width, 40) })
		tween(box, TWEEN, { TextTransparency = active and 0 or 1 })
		tween(self.ConfigButton, TWEEN_SLOW, { Position = UDim2.fromOffset(20 + width + 20, 20) })
	end

	box.Focused:Connect(updateSize)
	box.FocusLost:Connect(updateSize)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		self.SearchText = box.Text
		self:_applySearch()
		updateSize()
	end)

	self.SearchFrame = searchFrame
	self.SearchBox = box
end

function Window:_makeConfigDropdown()
	local items = { "New Config 1", "New Config 2", "New Config 3" }
	self.SelectedConfig = items[1]

	local button = textButton({
		Name = "ConfigDropdown",
		Text = "",
		BackgroundColor3 = THEME.Child,
		BackgroundTransparency = 0,
		Position = UDim2.fromOffset(20 + DIM.SearchClosed + 20, 20),
		Size = UDim2.fromOffset(DIM.ButtonSize.X, DIM.ButtonSize.Y),
		ZIndex = 20,
		Parent = self.TopBar,
	})
	corner(8).Parent = button
	stroke(THEME.Rect, 1, 0).Parent = button

	create("Frame", {
		BackgroundColor3 = THEME.Rect,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.fromOffset(1, 40),
		ZIndex = 21,
		Parent = button,
	})

	imageIcon("H", {
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.fromOffset(14, 40),
		ZIndex = 22,
		Parent = button,
	})

	local preview = textLabel({
		Text = self.SelectedConfig,
		TextColor3 = THEME.Text,
		TextSize = 14,
		Position = UDim2.fromOffset(55, 0),
		Size = UDim2.new(1, -80, 1, 0),
		ZIndex = 22,
		Parent = button,
	})

	local arrow = imageIcon("G", {
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Size = UDim2.fromOffset(10, 40),
		ZIndex = 22,
		Parent = button,
	})

	button.MouseButton1Click:Connect(function()
		self:_openPopup(button, DIM.ButtonSize.X, function(popup)
			for _, item in ipairs(items) do
				local active = item == self.SelectedConfig
				local itemButton = textButton({
					Text = "     " .. item,
					TextColor3 = active and THEME.Text or THEME.TextInactive,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = THEME.WidgetsActive,
					BackgroundTransparency = active and 0 or 1,
					Size = UDim2.new(1, 0, 0, 24),
					ZIndex = 72,
					Parent = popup,
				})
				corner(4).Parent = itemButton
				imageIcon("R", {
					ImageColor3 = THEME.Text,
					Size = UDim2.fromOffset(12, 24),
					Visible = active,
					ZIndex = 73,
					Parent = itemButton,
				})
				itemButton.MouseButton1Click:Connect(function()
					self.SelectedConfig = item
					preview.Text = item
					self:_closePopup()
				end)
			end
		end)
	end)

	self.ConfigButton = button
end

function Window:_makeSettings()
	local button = textButton({
		Name = "SettingsButton",
		Text = "PO",
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.Text,
		TextSize = 11,
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = 0,
		Position = UDim2.fromOffset(15, 480),
		Size = UDim2.fromOffset(35, 35),
		ZIndex = 25,
		Parent = self.Main,
	})
	corner(100).Parent = button
	self:_bindAccent(button, "BackgroundColor3")
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, self.Theme.Accent),
		}),
		Rotation = 45,
		Parent = button,
	})

	local function settingsRow(parent, order, icon, name, preview, callback)
		local row = textButton({
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 17),
			LayoutOrder = order,
			ZIndex = 82,
			Parent = parent,
		})
		imageIcon(icon, {
			ImageColor3 = THEME.Text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(0, 8.5),
			Size = UDim2.fromOffset(12, 12),
			ZIndex = 83,
			Parent = row,
		})
		textLabel({
			Text = name,
			TextSize = 12,
			TextColor3 = THEME.Text,
			Position = UDim2.fromOffset(15, 0),
			Size = UDim2.new(1, -95, 1, 0),
			ZIndex = 83,
			Parent = row,
		})
		local prev = textLabel({
			Text = preview,
			TextSize = 12,
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -17, 0, 0),
			Size = UDim2.fromOffset(65, 17),
			ZIndex = 83,
			Parent = row,
		})
		imageIcon("G", {
			ImageColor3 = THEME.Text,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(8, 17),
			ZIndex = 83,
			Parent = row,
		})
		row.MouseButton1Click:Connect(function()
			callback(row, prev)
		end)
		return row, prev
	end

	button.MouseButton1Click:Connect(function()
		self:_closePopup()
		local popup = create("CanvasGroup", {
			Name = "SettingsPopup",
			BackgroundColor3 = THEME.WindowBackground,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			Position = UDim2.fromOffset(15, 480),
			Size = UDim2.fromOffset(250, 151),
			ZIndex = 80,
			Parent = self.PopupLayer,
		}, {
			corner(16),
		})

		local avatar = create("Frame", {
			BackgroundColor3 = self.Theme.Accent,
			Position = UDim2.fromOffset(15, 15),
			Size = UDim2.fromOffset(30, 30),
			BorderSizePixel = 0,
			ZIndex = 81,
			Parent = popup,
		}, {
			corner(100),
		})
		textLabel({
			Text = "PO",
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 82,
			Parent = avatar,
		})
		self:_bindAccent(avatar, "BackgroundColor3")

		textLabel({
			Text = "Past Owl",
			TextSize = 14,
			TextColor3 = THEME.Text,
			Position = UDim2.fromOffset(60, 12),
			Size = UDim2.fromOffset(180, 20),
			ZIndex = 82,
			Parent = popup,
		})
		textLabel({
			Text = "Till: 1 Jan 2025",
			TextSize = 12,
			TextColor3 = THEME.TextInactive,
			Position = UDim2.fromOffset(60, 30),
			Size = UDim2.fromOffset(180, 22),
			ZIndex = 82,
			Parent = popup,
		})
		create("Frame", {
			BackgroundColor3 = THEME.WidgetsActive,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(15, 60),
			Size = UDim2.new(1, -30, 0, 1),
			ZIndex = 82,
			Parent = popup,
		})

		local bottom = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(15, 76),
			Size = UDim2.new(1, -30, 0, 70),
			ZIndex = 82,
			Parent = popup,
		}, {
			listLayout(Enum.FillDirection.Vertical, 8),
		})

		settingsRow(bottom, 1, "K", "Language", self.Language, function(owner, prev)
			local values = { "English", "Russian" }
			self:_openPopup(owner, 160, function(menu)
				for _, item in ipairs(values) do
					local row = textButton({
						Text = "     " .. item,
						TextColor3 = item == self.Language and THEME.Text or THEME.TextInactive,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = THEME.WidgetsActive,
						BackgroundTransparency = item == self.Language and 0 or 1,
						Size = UDim2.new(1, 0, 0, 24),
						ZIndex = 90,
						Parent = menu,
					})
					corner(4).Parent = row
					row.MouseButton1Click:Connect(function()
						self.Language = item
						prev.Text = item
						self:_closeSubPopup()
					end)
				end
			end, nil, true)
		end)

		settingsRow(bottom, 2, "L", "DPI Menu", tostring(self.DPI) .. "%", function(owner, prev)
			local values = { 75, 100, 150, 200 }
			self:_openPopup(owner, 160, function(menu)
				for _, item in ipairs(values) do
					local row = textButton({
						Text = "     " .. tostring(item) .. "%",
						TextColor3 = item == self.DPI and THEME.Text or THEME.TextInactive,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = THEME.WidgetsActive,
						BackgroundTransparency = item == self.DPI and 0 or 1,
						Size = UDim2.new(1, 0, 0, 24),
						ZIndex = 90,
						Parent = menu,
					})
					corner(4).Parent = row
					row.MouseButton1Click:Connect(function()
						self:SetDPI(item)
						prev.Text = tostring(item) .. "%"
						self:_closeSubPopup()
					end)
				end
			end, nil, true)
		end)

		local styles = textButton({
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 17),
			LayoutOrder = 3,
			ZIndex = 82,
			Parent = bottom,
		})
		imageIcon("M", {
			ImageColor3 = THEME.Text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(0, 8.5),
			Size = UDim2.fromOffset(12, 12),
			ZIndex = 83,
			Parent = styles,
		})
		textLabel({
			Text = "Styles",
			TextSize = 12,
			TextColor3 = THEME.Text,
			Position = UDim2.fromOffset(15, 0),
			Size = UDim2.new(1, -95, 1, 0),
			ZIndex = 83,
			Parent = styles,
		})

		local colors = {
			Color3.fromRGB(103, 100, 255),
			Color3.fromRGB(102, 209, 160),
			Color3.fromRGB(255, 122, 124),
			Color3.fromRGB(255, 187, 92),
			Color3.fromRGB(95, 189, 255),
		}
		for i, color in ipairs(colors) do
			local swatch = textButton({
				Text = "",
				BackgroundColor3 = color,
				BackgroundTransparency = 0,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -((#colors - i) * 18), 0, 1),
				Size = UDim2.fromOffset(12, 12),
				ZIndex = 84,
				Parent = styles,
			})
			corner(4).Parent = swatch
			swatch.MouseButton1Click:Connect(function()
				self:_setAccent(color)
			end)
		end

		local outsideConnection
		outsideConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			task.defer(function()
				local point = Vector2.new(input.Position.X, input.Position.Y)
				if not pointInside(popup, point) and not pointInside(button, point) then
					if outsideConnection then
						outsideConnection:Disconnect()
					end
					tween(popup, TWEEN_FAST, { GroupTransparency = 1 })
					task.delay(0.13, function()
						if popup and popup.Parent then
							popup:Destroy()
						end
					end)
				end
			end)
		end)

		self.OpenPopup = {
			Frame = popup,
			Connection = outsideConnection,
		}

		tween(popup, TWEEN_FAST, { GroupTransparency = 0 })
	end)
end

function Window:_makeChrome()
	local main = self.Main

	create("Frame", {
		Name = "RightBackdrop",
		BackgroundColor3 = THEME.WindowBar,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(DIM.RailWidth, 0),
		Size = UDim2.fromOffset(DIM.Window.X - DIM.RailWidth, DIM.Window.Y),
		ZIndex = 2,
		Parent = main,
	}, {
		corner(DIM.WindowRounding),
	})

	local logo = imageIcon("A", {
		Name = "Logo",
		ImageColor3 = self.Theme.Accent,
		Position = UDim2.fromOffset(21, 22),
		Size = UDim2.fromOffset(22, 21),
		ZIndex = 5,
		Parent = main,
	})
	self:_bindAccent(logo, "ImageColor3")

	create("Frame", {
		Name = "LogoLine",
		BackgroundColor3 = THEME.Line,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(21, 65),
		Size = UDim2.fromOffset(21, 1),
		ZIndex = 5,
		Parent = main,
	})

	imageIcon("G", {
		Name = "RailBottomIcon",
		ImageColor3 = THEME.Text,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(DIM.RailWidth / 2, 455),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 5,
		Parent = main,
	})

	self.SectionList = create("Frame", {
		Name = "SectionList",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(15, DIM.SectionTop),
		Size = UDim2.fromOffset(DIM.SectionButton, 350),
		ZIndex = 12,
		Parent = main,
	}, {
		listLayout(Enum.FillDirection.Vertical, DIM.SectionSpacing, Enum.HorizontalAlignment.Center),
	})

	self.TopBar = create("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(DIM.RailWidth, 0),
		Size = UDim2.fromOffset(DIM.Window.X - DIM.RailWidth, DIM.BarHeight),
		ZIndex = 12,
		Parent = main,
	})

	self.PopupLayer = create("Frame", {
		Name = "PopupLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 60,
		Parent = main,
	})

	self:_makeConfigDropdown()
	self:_makeSearch()
	self:_makeSettings()
end

function Window:_makeDraggable()
	local dragging = false
	local dragStart
	local startPosition

	self.Main.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		startPosition = self.Container.Position
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then
			return
		end
		local delta = input.Position - dragStart
		self.Container.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Library:CreateWindow(options)
	options = typeof(options) == "table" and options or { Title = tostring(options or "Past Owl") }

	local screenGui = create("ScreenGui", {
		Name = options.Name or "SkiddedGui",
		DisplayOrder = options.DisplayOrder or 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = options.Parent or getDefaultParent(),
	})

	local container = create("CanvasGroup", {
		Name = "WindowContainer",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(DIM.Window.X, DIM.Window.Y),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		ZIndex = 1,
		Parent = screenGui,
	})

	local scale = create("UIScale", {
		Name = "DPI",
		Scale = (options.DPI or 100) / 100,
		Parent = container,
	})

	local main = create("Frame", {
		Name = "Main",
		BackgroundColor3 = THEME.WindowBackground,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(DIM.Window.X, DIM.Window.Y),
		ZIndex = 1,
		Parent = container,
	}, {
		corner(DIM.WindowRounding),
	})

	local window = setmetatable({
		ScreenGui = screenGui,
		Container = container,
		Scale = scale,
		Main = main,
		Title = options.Title or options.Name or "Past Owl",
		Theme = table.clone(THEME),
		Sections = {},
		Controls = {},
		AccentBinds = {},
		DPI = options.DPI or 100,
		Language = "English",
		Visible = true,
		SearchText = "",
	}, Window)

	window:_makeChrome()
	window:_makeDraggable()

	table.insert(self.Windows, window)
	return window
end

function Library:GetIcon(icon)
	return resolveIcon(icon)
end

function Library:LoadDemo(options)
	local window = self:CreateWindow(options or { Name = "SkiddedGui", Title = "Past Owl" })

	local sec1 = window:Section("sec1", "B")
	window:Section("sec2", "D")
	window:Section("sec3", "C")
	window:Section("sec4", "E")
	window:Section("sec5", "F")

	local aimbot = sec1:Child("AIMBOT", "Left")
	aimbot:Toggle({
		Name = "Enable aimbot",
		Default = true,
		Keybind = true,
		Flag = "enable_aimbot",
		Callback = function(value)
			Library.Flags.enable_aimbot = value
		end,
	})
	aimbot:Dropdown({
		Name = "Conditions",
		Items = { "Head", "Chest", "Stomach", "Arms", "Legs", "Feat" },
		Default = "Head",
		Flag = "aimbot_conditions",
	})
	aimbot:MultiDropdown({
		Name = "Bone aimbot",
		Items = { "Through", "Smoke", "Always" },
		Flag = "bone_aimbot",
	})
	aimbot:MultiDropdown({
		Name = "Hitboxes",
		Items = { "Head", "Chest", "Stomach", "Smoke" },
		Flag = "hitboxes",
	})
	aimbot:Slider({
		Name = "Field of view",
		Min = 0,
		Max = 180,
		Default = 90,
		Format = "%du",
		Flag = "field_of_view",
	})
	aimbot:Slider({
		Name = "Smoothing",
		Min = 0,
		Max = 100,
		Default = 50,
		Format = "%d%%",
		Flag = "smoothing",
	})
	aimbot:Slider({
		Name = "Reaction time",
		Min = 0,
		Max = 5000,
		Default = 2000,
		Format = "%dmc",
		Flag = "reaction_time",
	})
	aimbot:Slider({
		Name = "Target switch delay",
		Min = 0,
		Max = 5000,
		Default = 2000,
		Format = "%dmc",
		Flag = "target_switch_delay",
	})
	aimbot:Toggle({
		Name = "First bullet delay",
		Default = true,
		Flag = "first_bullet_delay",
	})
	aimbot:Toggle({
		Name = "Recoil control",
		Default = false,
		Flag = "recoil_control",
	})

	local triggerbot = sec1:Child("TRIGGERBOT", "Right")
	triggerbot:Toggle({
		Name = "Enable triggerbot",
		Default = true,
		Flag = "enable_triggerbot",
	})
	triggerbot:Dropdown({
		Name = "Conditions##1",
		Items = { "Head", "Chest", "Stomach", "Arms", "Legs", "Feat" },
		Default = "Head",
		Flag = "trigger_conditions",
	})
	triggerbot:Slider({
		Name = "Hit change",
		Min = 0,
		Max = 100,
		Default = 100,
		Format = "%d%%",
		Flag = "hit_change",
	})
	triggerbot:Slider({
		Name = "Reaction time##1",
		Min = 0,
		Max = 100,
		Default = 0,
		Format = "%dmc",
		Flag = "trigger_reaction_time",
	})
	triggerbot:Slider({
		Name = "Burst time",
		Min = 0,
		Max = 100,
		Default = 0,
		Format = "%dmc",
		Flag = "burst_time",
	})
	triggerbot:Toggle({
		Name = "Quick scope",
		Default = true,
		Flag = "quick_scope",
	})

	return window
end

Library.Window = Window
Library.Section = Section
Library.Child = Child
Library.Theme = THEME
Library.Icons = Library.IconAssets

return setmetatable(Library, {
	__call = function(self)
		return self
	end,
})
