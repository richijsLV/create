local EldoraUI = {}
EldoraUI.__index = EldoraUI
EldoraUI.Version = "1.0.0"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function safeCall(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    local ok, result = pcall(callback, ...)
    if not ok then
        warn("[EldoraUI] Callback error:", result)
    end
end

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local clone = {}
    for key, innerValue in pairs(value) do
        clone[key] = deepCopy(innerValue)
    end
    return clone
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function roundToIncrement(value, increment)
    if increment <= 0 then
        return value
    end

    return math.floor((value / increment) + 0.5) * increment
end

local function blend(colorA, colorB, alpha)
    return colorA:Lerp(colorB, alpha)
end

local function extractPosition(inputOrVector)
    if typeof(inputOrVector) == "Vector2" then
        return inputOrVector
    end

    return inputOrVector.Position
end

local function tween(instance, duration, properties, easingStyle, easingDirection)
    local info = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quint, easingDirection or Enum.EasingDirection.Out)
    local activeTween = TweenService:Create(instance, info, properties)
    activeTween:Play()
    return activeTween
end

local function create(className, properties)
    local instance = Instance.new(className)

    for key, value in pairs(properties or {}) do
        if key ~= "Children" and key ~= "Parent" then
            instance[key] = value
        end
    end

    if properties and properties.Children then
        for _, child in ipairs(properties.Children) do
            child.Parent = instance
        end
    end

    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end

    return instance
end

local function serializeValue(value)
    local kind = typeof(value)

    if kind == "Color3" then
        return {
            __type = "Color3",
            R = value.R,
            G = value.G,
            B = value.B,
        }
    end

    if kind == "EnumItem" and value.EnumType == Enum.KeyCode then
        return {
            __type = "KeyCode",
            Name = value.Name,
        }
    end

    if type(value) == "table" then
        local serialized = {}
        for key, innerValue in pairs(value) do
            serialized[key] = serializeValue(innerValue)
        end
        return serialized
    end

    return value
end

local function deserializeValue(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__type == "Color3" then
        return Color3.new(value.R, value.G, value.B)
    end

    if value.__type == "KeyCode" then
        return Enum.KeyCode[value.Name]
    end

    local deserialized = {}
    for key, innerValue in pairs(value) do
        if key ~= "__type" then
            deserialized[key] = deserializeValue(innerValue)
        end
    end
    return deserialized
end

local function protectGui(gui)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
        return
    end

    if protectgui then
        pcall(protectgui, gui)
    end
end

local function resolveGuiParent()
    if gethui then
        local ok, parent = pcall(gethui)
        if ok and parent then
            return parent
        end
    end

    return CoreGui
end

local DEFAULT_THEME = {
    Background = Color3.fromRGB(10, 14, 24),
    Surface = Color3.fromRGB(19, 24, 38),
    SurfaceAlt = Color3.fromRGB(27, 34, 52),
    SurfaceRaised = Color3.fromRGB(36, 45, 68),
    Accent = Color3.fromRGB(90, 167, 255),
    AccentMuted = Color3.fromRGB(54, 103, 160),
    AccentSoft = Color3.fromRGB(24, 49, 82),
    Text = Color3.fromRGB(245, 247, 255),
    TextMuted = Color3.fromRGB(170, 182, 204),
    Outline = Color3.fromRGB(64, 78, 110),
    Divider = Color3.fromRGB(42, 52, 76),
    Success = Color3.fromRGB(84, 206, 139),
    Warning = Color3.fromRGB(255, 184, 77),
    Danger = Color3.fromRGB(255, 98, 98),
    Shadow = Color3.fromRGB(5, 8, 14),
}

EldoraUI.Themes = {
    Midnight = deepCopy(DEFAULT_THEME),
    Ember = {
        Background = Color3.fromRGB(16, 10, 10),
        Surface = Color3.fromRGB(28, 17, 17),
        SurfaceAlt = Color3.fromRGB(39, 24, 24),
        SurfaceRaised = Color3.fromRGB(52, 32, 32),
        Accent = Color3.fromRGB(255, 124, 92),
        AccentMuted = Color3.fromRGB(171, 78, 58),
        AccentSoft = Color3.fromRGB(75, 31, 22),
        Text = Color3.fromRGB(255, 245, 242),
        TextMuted = Color3.fromRGB(214, 185, 176),
        Outline = Color3.fromRGB(114, 63, 55),
        Divider = Color3.fromRGB(72, 42, 42),
        Success = Color3.fromRGB(91, 221, 151),
        Warning = Color3.fromRGB(255, 197, 99),
        Danger = Color3.fromRGB(255, 105, 105),
        Shadow = Color3.fromRGB(10, 6, 6),
    },
    Glacier = {
        Background = Color3.fromRGB(7, 14, 21),
        Surface = Color3.fromRGB(13, 26, 36),
        SurfaceAlt = Color3.fromRGB(18, 36, 49),
        SurfaceRaised = Color3.fromRGB(26, 49, 64),
        Accent = Color3.fromRGB(58, 218, 209),
        AccentMuted = Color3.fromRGB(34, 141, 135),
        AccentSoft = Color3.fromRGB(17, 68, 66),
        Text = Color3.fromRGB(239, 252, 255),
        TextMuted = Color3.fromRGB(170, 205, 213),
        Outline = Color3.fromRGB(60, 105, 114),
        Divider = Color3.fromRGB(36, 66, 75),
        Success = Color3.fromRGB(108, 224, 165),
        Warning = Color3.fromRGB(255, 204, 97),
        Danger = Color3.fromRGB(255, 125, 125),
        Shadow = Color3.fromRGB(3, 7, 11),
    },
}

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local function mergeTheme(base, override)
    local merged = deepCopy(base)
    for key, value in pairs(override or {}) do
        merged[key] = value
    end
    return merged
end

local function applyStrokeTheme(window, stroke, token)
    window:_trackTheme(function(theme)
        stroke.Color = theme[token]
    end)
end

local function applyBackgroundTheme(window, object, token)
    window:_trackTheme(function(theme)
        object.BackgroundColor3 = theme[token]
    end)
end

local function applyTextTheme(window, object, token)
    window:_trackTheme(function(theme)
        object.TextColor3 = theme[token]
    end)
end

local function applyImageTheme(window, object, token)
    window:_trackTheme(function(theme)
        object.ImageColor3 = theme[token]
    end)
end

local function createSignal()
    local event = Instance.new("BindableEvent")
    return {
        Fire = function(_, ...)
            event:Fire(...)
        end,
        Connect = function(_, callback)
            return event.Event:Connect(callback)
        end,
        Wait = function(_)
            return event.Event:Wait()
        end,
        Destroy = function(_)
            event:Destroy()
        end,
        Event = event.Event,
    }
end

local function createController(window, options)
    local controller = {
        Flag = options.Flag,
        Value = options.Value,
        Changed = createSignal(),
    }

    function controller:Set(value, silent)
        local nextValue = options.Normalize and options.Normalize(value) or value
        self.Value = nextValue

        if self.Flag then
            window.State[self.Flag] = nextValue
        end

        if options.Apply then
            options.Apply(nextValue)
        end

        if not silent and options.Callback then
            task.spawn(safeCall, options.Callback, nextValue)
        end

        self.Changed:Fire(nextValue)
    end

    function controller:Get()
        return self.Value
    end

    function controller:OnChanged(callback)
        return self.Changed:Connect(callback)
    end

    function controller:Destroy()
        self.Changed:Destroy()
    end

    if controller.Flag then
        window.Controllers[controller.Flag] = controller
        window.State[controller.Flag] = controller.Value
    end

    return controller
end

function EldoraUI:RegisterTheme(name, themeTable)
    assert(type(name) == "string", "Theme name must be a string.")
    assert(type(themeTable) == "table", "Theme table must be a table.")

    self.Themes[name] = mergeTheme(DEFAULT_THEME, themeTable)
end

function EldoraUI:CreateWindow(options)
    options = options or {}

    local screenGui = create("ScreenGui", {
        Name = options.ScreenGuiName or "EldoraUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    protectGui(screenGui)
    screenGui.Parent = resolveGuiParent()

    local selfWindow = setmetatable({
        Name = options.Name or "Eldora UI",
        Subtitle = options.Subtitle or "Polished script interface",
        ThemeName = "Midnight",
        Theme = deepCopy(DEFAULT_THEME),
        ScreenGui = screenGui,
        Controllers = {},
        State = {},
        Tabs = {},
        ThemeBindings = {},
        Cleanup = {},
        Visible = true,
        ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightControl,
    }, Window)

    selfWindow:_buildChrome()
    if type(options.Theme) == "string" and self.Themes[options.Theme] then
        selfWindow:SetTheme(options.Theme)
    elseif type(options.Theme) == "table" then
        selfWindow:SetTheme(options.Theme)
    else
        selfWindow:SetTheme("Midnight")
    end
    selfWindow:SetToggleKey(selfWindow.ToggleKeybind)
    return selfWindow
end

function Window:_trackTheme(callback)
    table.insert(self.ThemeBindings, callback)
    callback(self.Theme)
end

function Window:_trackCleanup(item)
    table.insert(self.Cleanup, item)
    return item
end

function Window:_buildChrome()
    local overlay = create("Frame", {
        Name = "Overlay",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = self.ScreenGui,
    })

    local backdrop = create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.24,
        Size = UDim2.fromScale(1, 1),
        Parent = overlay,
    })
    self:_trackTheme(function(theme)
        backdrop.BackgroundColor3 = theme.Background
    end)

    local notifications = create("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -24, 1, -24),
        Size = UDim2.new(0, 360, 1, -48),
        Parent = overlay,
    })
    local notificationLayout = create("UIListLayout", {
        Parent = notifications,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    self:_trackCleanup(notificationLayout)
    self.NotificationHolder = notifications

    local shell = create("Frame", {
        Name = "Shell",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1060, 0, 680),
        BackgroundTransparency = 1,
        Parent = overlay,
    })

    create("UISizeConstraint", {
        Parent = shell,
        MinSize = Vector2.new(900, 580),
    })

    local shadow = create("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 18),
        BackgroundColor3 = self.Theme.Shadow,
        BackgroundTransparency = 0.45,
        Parent = shell,
    })
    create("UICorner", {
        Parent = shadow,
        CornerRadius = UDim.new(0, 28),
    })
    self:_trackTheme(function(theme)
        shadow.BackgroundColor3 = theme.Shadow
    end)

    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Theme.Surface,
        Parent = shell,
    })
    create("UICorner", {
        Parent = main,
        CornerRadius = UDim.new(0, 24),
    })
    local mainStroke = create("UIStroke", {
        Parent = main,
        Thickness = 1,
        Transparency = 0.15,
        Color = self.Theme.Outline,
    })
    applyBackgroundTheme(self, main, "Surface")
    applyStrokeTheme(self, mainStroke, "Outline")

    local mainGradient = create("UIGradient", {
        Parent = main,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.SurfaceRaised),
            ColorSequenceKeypoint.new(1, self.Theme.Surface),
        }),
    })
    self:_trackTheme(function(theme)
        mainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, blend(theme.SurfaceRaised, theme.AccentSoft, 0.12)),
            ColorSequenceKeypoint.new(1, theme.Surface),
        })
    end)

    self.Root = shell
    self.Main = main

    local topBar = create("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 74),
        Position = UDim2.new(0, 12, 0, 12),
        Parent = main,
    })

    local titleHolder = create("Frame", {
        Name = "TitleHolder",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -180, 1, 0),
        Parent = topBar,
    })

    local title = create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, 0, 0, 28),
        Font = Enum.Font.GothamBold,
        Text = self.Name,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder,
    })
    applyTextTheme(self, title, "Text")

    local subtitle = create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = self.Subtitle,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder,
    })
    applyTextTheme(self, subtitle, "TextMuted")

    local actions = create("Frame", {
        Name = "Actions",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 156, 0, 42),
        Parent = topBar,
    })
    create("UIListLayout", {
        Parent = actions,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
    })

    local function createActionButton(buttonText)
        local button = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.SurfaceAlt,
            Size = UDim2.new(0, 42, 0, 42),
            Font = Enum.Font.GothamBold,
            Text = buttonText,
            TextSize = 18,
            Parent = actions,
        })
        create("UICorner", {
            Parent = button,
            CornerRadius = UDim.new(1, 0),
        })
        local stroke = create("UIStroke", {
            Parent = button,
            Thickness = 1,
            Transparency = 0.3,
        })
        applyBackgroundTheme(self, button, "SurfaceAlt")
        applyStrokeTheme(self, stroke, "Outline")
        applyTextTheme(self, button, "Text")
        self:_registerPressable(button, button)
        return button
    end

    local minimizeButton = createActionButton("-")
    local closeButton = createActionButton("x")

    local divider = create("Frame", {
        Name = "Divider",
        BackgroundColor3 = self.Theme.Divider,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 86),
        Parent = main,
    })
    self:_trackTheme(function(theme)
        divider.BackgroundColor3 = theme.Divider
    end)

    local body = create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 102),
        Size = UDim2.new(1, -24, 1, -114),
        Parent = main,
    })

    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = self.Theme.Background,
        Size = UDim2.new(0, 250, 1, 0),
        Parent = body,
    })
    create("UICorner", {
        Parent = sidebar,
        CornerRadius = UDim.new(0, 20),
    })
    local sidebarStroke = create("UIStroke", {
        Parent = sidebar,
        Thickness = 1,
        Transparency = 0.2,
    })
    applyBackgroundTheme(self, sidebar, "Background")
    applyStrokeTheme(self, sidebarStroke, "Outline")

    local sidebarHeader = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 64),
        Position = UDim2.new(0, 14, 0, 14),
        Parent = sidebar,
    })

    local badge = create("Frame", {
        Size = UDim2.new(0, 52, 0, 52),
        BackgroundColor3 = self.Theme.AccentSoft,
        Parent = sidebarHeader,
    })
    create("UICorner", {
        Parent = badge,
        CornerRadius = UDim.new(0, 16),
    })
    local badgeStroke = create("UIStroke", {
        Parent = badge,
        Thickness = 1,
        Transparency = 0.25,
    })
    applyBackgroundTheme(self, badge, "AccentSoft")
    applyStrokeTheme(self, badgeStroke, "Outline")

    local badgeText = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold,
        Text = "E",
        TextSize = 26,
        Parent = badge,
    })
    applyTextTheme(self, badgeText, "Accent")

    local productName = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 66, 0, 4),
        Size = UDim2.new(1, -66, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "Eldora UI",
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebarHeader,
    })
    applyTextTheme(self, productName, "Text")

    local productMeta = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 66, 0, 30),
        Size = UDim2.new(1, -66, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "v" .. EldoraUI.Version .. " | " .. self.ThemeName,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebarHeader,
    })
    applyTextTheme(self, productMeta, "TextMuted")
    self.ProductMeta = productMeta

    local tabHolder = create("ScrollingFrame", {
        Name = "TabHolder",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, 92),
        Size = UDim2.new(1, -28, 1, -154),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 1,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = sidebar,
    })
    create("UIListLayout", {
        Parent = tabHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })

    local sidebarFooter = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceAlt,
        Size = UDim2.new(1, -28, 0, 54),
        Position = UDim2.new(0, 14, 1, -68),
        Parent = sidebar,
    })
    create("UICorner", {
        Parent = sidebarFooter,
        CornerRadius = UDim.new(0, 16),
    })
    local footerStroke = create("UIStroke", {
        Parent = sidebarFooter,
        Thickness = 1,
        Transparency = 0.25,
    })
    applyBackgroundTheme(self, sidebarFooter, "SurfaceAlt")
    applyStrokeTheme(self, footerStroke, "Outline")

    local footerLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -28, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "Toggle Window",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebarFooter,
    })
    applyTextTheme(self, footerLabel, "Text")

    self.ToggleDisplay = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 26),
        Size = UDim2.new(1, -28, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Press " .. self.ToggleKeybind.Name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebarFooter,
    })
    applyTextTheme(self, self.ToggleDisplay, "TextMuted")

    local pageHolder = create("Frame", {
        Name = "PageHolder",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 266, 0, 0),
        Size = UDim2.new(1, -266, 1, 0),
        Parent = body,
    })

    local dragInput
    local dragStart
    local shellStart
    local function updateDrag(input)
        local delta = input.Position - dragStart
        shell.Position = UDim2.new(shellStart.X.Scale, shellStart.X.Offset + delta.X, shellStart.Y.Scale, shellStart.Y.Offset + delta.Y)
    end

    self:_trackCleanup(topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            shellStart = shell.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end))

    self:_trackCleanup(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart and shellStart then
            updateDrag(input)
        end
    end))

    self:_trackCleanup(minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleVisible(not self.Visible)
    end))

    self:_trackCleanup(closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end))

    self.Overlay = overlay
    self.Body = body
    self.Sidebar = sidebar
    self.TabHolder = tabHolder
    self.PageHolder = pageHolder
end

function Window:_registerPressable(button, visualTarget)
    local target = visualTarget or button
    local scale = create("UIScale", {
        Parent = target,
        Scale = 1,
    })

    local function hoverEnter()
        tween(scale, 0.18, { Scale = 1.015 })
        tween(target, 0.18, { BackgroundColor3 = blend(self.Theme.SurfaceAlt, self.Theme.AccentSoft, 0.22) })
    end

    local function hoverLeave()
        tween(scale, 0.18, { Scale = 1 })
        tween(target, 0.18, { BackgroundColor3 = self.Theme.SurfaceAlt })
    end

    local function press()
        tween(scale, 0.12, { Scale = 0.985 }, Enum.EasingStyle.Quad)
    end

    local function release()
        tween(scale, 0.16, { Scale = 1.01 }, Enum.EasingStyle.Quad)
    end

    self:_trackCleanup(button.MouseEnter:Connect(hoverEnter))
    self:_trackCleanup(button.MouseLeave:Connect(hoverLeave))
    self:_trackCleanup(button.MouseButton1Down:Connect(press))
    self:_trackCleanup(button.MouseButton1Up:Connect(release))
end

function Window:SetToggleKey(keyCode)
    self.ToggleKeybind = keyCode or Enum.KeyCode.RightControl

    if self.ToggleDisplay then
        self.ToggleDisplay.Text = "Press " .. self.ToggleKeybind.Name
    end

    if self.ToggleConnection then
        self.ToggleConnection:Disconnect()
    end

    self.ToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if input.KeyCode == self.ToggleKeybind then
            self:ToggleVisible(not self.Visible)
        end
    end)

    self:_trackCleanup(self.ToggleConnection)
end

function Window:ToggleVisible(state)
    if self.Destroyed then
        return
    end

    self.Visible = state
    self.Main.Visible = true

    if state then
        self.Main.Visible = true
        self.Main.BackgroundTransparency = 1
        self.Sidebar.Position = UDim2.new(0, -20, 0, 0)
        self.PageHolder.Position = UDim2.new(0, 296, 0, 0)
        tween(self.Main, 0.22, { BackgroundTransparency = 0 })
        tween(self.Sidebar, 0.22, { Position = UDim2.new(0, 0, 0, 0) })
        tween(self.PageHolder, 0.22, { Position = UDim2.new(0, 266, 0, 0) })
        return
    end

    local fadeTween = tween(self.Main, 0.18, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
    tween(self.Sidebar, 0.18, { Position = UDim2.new(0, -24, 0, 0) }, Enum.EasingStyle.Quad)
    tween(self.PageHolder, 0.18, { Position = UDim2.new(0, 294, 0, 0) }, Enum.EasingStyle.Quad)
    fadeTween.Completed:Wait()
    if not self.Visible and not self.Destroyed then
        self.Main.Visible = false
    end
end

function Window:SetTheme(themeInput)
    if type(themeInput) == "string" and EldoraUI.Themes[themeInput] then
        self.Theme = mergeTheme(DEFAULT_THEME, EldoraUI.Themes[themeInput])
        self.ThemeName = themeInput
    elseif type(themeInput) == "table" then
        self.Theme = mergeTheme(DEFAULT_THEME, themeInput)
        self.ThemeName = "Custom"
    else
        self.Theme = deepCopy(DEFAULT_THEME)
        self.ThemeName = "Midnight"
    end

    for _, callback in ipairs(self.ThemeBindings) do
        callback(self.Theme)
    end

    if self.ProductMeta then
        self.ProductMeta.Text = "v" .. EldoraUI.Version .. " | " .. self.ThemeName
    end

    if self.ActiveTab then
        self:_setActiveTab(self.ActiveTab)
    end
end

function Window:GetController(flag)
    return self.Controllers[flag]
end

function Window:GetState()
    return self.State
end

function Window:CreateTab(options)
    options = options or {}

    local tabButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceAlt,
        Size = UDim2.new(1, 0, 0, 52),
        Text = "",
        Parent = self.TabHolder,
    })
    create("UICorner", {
        Parent = tabButton,
        CornerRadius = UDim.new(0, 16),
    })
    local buttonStroke = create("UIStroke", {
        Parent = tabButton,
        Thickness = 1,
        Transparency = 0.25,
    })
    applyBackgroundTheme(self, tabButton, "SurfaceAlt")
    applyStrokeTheme(self, buttonStroke, "Outline")
    self:_registerPressable(tabButton, tabButton)

    local buttonIcon = create("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = options.Icon or "",
        ImageTransparency = options.Icon and 0 or 1,
        Parent = tabButton,
    })
    applyImageTheme(self, buttonIcon, "Accent")

    local buttonTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, options.Icon and 44 or 16, 0, 11),
        Size = UDim2.new(1, -92, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = options.Name or ("Tab " .. tostring(#self.Tabs + 1)),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabButton,
    })
    applyTextTheme(self, buttonTitle, "Text")

    local buttonDescription = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, options.Icon and 44 or 16, 0, 27),
        Size = UDim2.new(1, -92, 0, 14),
        Font = Enum.Font.Gotham,
        Text = options.Description or "Configure the controls in this category.",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabButton,
    })
    applyTextTheme(self, buttonDescription, "TextMuted")

    local activeBar = create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 4, 0, 22),
        Visible = false,
        Parent = tabButton,
    })
    create("UICorner", {
        Parent = activeBar,
        CornerRadius = UDim.new(1, 0),
    })
    self:_trackTheme(function(theme)
        activeBar.BackgroundColor3 = theme.Accent
    end)

    local page = create("ScrollingFrame", {
        Name = buttonTitle.Text .. "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 1,
        Visible = false,
        Parent = self.PageHolder,
    })
    local pageLayout = create("UIListLayout", {
        Parent = page,
        Padding = UDim.new(0, 14),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    create("UIPadding", {
        Parent = page,
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
    })
    self:_trackCleanup(pageLayout)

    local newTab = setmetatable({
        Window = self,
        Button = tabButton,
        ActiveBar = activeBar,
        Page = page,
        Sections = {},
    }, Tab)

    self:_trackCleanup(tabButton.MouseButton1Click:Connect(function()
        self:_setActiveTab(newTab)
    end))

    table.insert(self.Tabs, newTab)

    if not self.ActiveTab then
        self:_setActiveTab(newTab)
    end

    return newTab
end

function Window:_setActiveTab(targetTab)
    for _, tab in ipairs(self.Tabs) do
        local isActive = tab == targetTab
        tab.Page.Visible = isActive
        tab.ActiveBar.Visible = isActive

        tween(tab.Button, 0.18, {
            BackgroundColor3 = isActive and blend(self.Theme.SurfaceRaised, self.Theme.AccentSoft, 0.16) or self.Theme.SurfaceAlt,
        }, Enum.EasingStyle.Quad)
    end

    self.ActiveTab = targetTab
end

function Window:Notify(options)
    options = options or {}

    local slot = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 92),
        Parent = self.NotificationHolder,
    })

    local card = create("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = slot,
    })
    create("UICorner", {
        Parent = card,
        CornerRadius = UDim.new(0, 20),
    })
    local stroke = create("UIStroke", {
        Parent = card,
        Thickness = 1,
        Transparency = 0.2,
        Color = self.Theme.Outline,
    })
    self:_trackTheme(function(theme)
        stroke.Color = theme.Outline
    end)

    local gradient = create("UIGradient", {
        Parent = card,
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, blend(self.Theme.SurfaceRaised, self.Theme.AccentSoft, 0.2)),
            ColorSequenceKeypoint.new(1, self.Theme.Surface),
        }),
    })
    self:_trackTheme(function(theme)
        card.BackgroundColor3 = theme.Surface
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, blend(theme.SurfaceRaised, theme.AccentSoft, 0.2)),
            ColorSequenceKeypoint.new(1, theme.Surface),
        })
    end)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 14),
        Size = UDim2.new(1, -36, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = options.Title or "Notification",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    applyTextTheme(self, title, "Text")

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 36),
        Size = UDim2.new(1, -36, 0, 34),
        Font = Enum.Font.Gotham,
        Text = options.Content or "Something happened.",
        TextWrapped = true,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })
    applyTextTheme(self, content, "TextMuted")

    local progress = create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 18, 1, -14),
        Size = UDim2.new(1, -36, 0, 4),
        Parent = card,
    })
    create("UICorner", {
        Parent = progress,
        CornerRadius = UDim.new(1, 0),
    })
    self:_trackTheme(function(theme)
        progress.BackgroundColor3 = theme.Accent
    end)

    card.Position = UDim2.new(0, 60, 0, 0)
    tween(card, 0.24, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)

    local duration = options.Duration or 4
    tween(progress, duration, {
        Size = UDim2.new(0, 0, 0, 4),
    }, Enum.EasingStyle.Linear)

    task.spawn(function()
        task.wait(duration)
        tween(card, 0.22, { Position = UDim2.new(0, 42, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
        task.wait(0.22)
        if slot then
            slot:Destroy()
        end
    end)
end

function Window:ExportState()
    local serialized = {}
    for flag, value in pairs(self.State) do
        serialized[flag] = serializeValue(value)
    end
    return HttpService:JSONEncode(serialized)
end

function Window:ImportState(serializedState, fireCallbacks)
    local decoded = serializedState
    if type(serializedState) == "string" then
        local ok, result = pcall(HttpService.JSONDecode, HttpService, serializedState)
        if not ok then
            warn("[EldoraUI] Failed to decode imported state:", result)
            return
        end
        decoded = result
    end

    for flag, value in pairs(decoded) do
        local controller = self.Controllers[flag]
        if controller then
            controller:Set(deserializeValue(value), not fireCallbacks)
        end
    end
end

function Window:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    for _, controller in pairs(self.Controllers) do
        controller:Destroy()
    end

    for _, item in ipairs(self.Cleanup) do
        if typeof(item) == "RBXScriptConnection" then
            item:Disconnect()
        elseif typeof(item) == "Instance" then
            item:Destroy()
        elseif type(item) == "table" and item.Destroy then
            item:Destroy()
        end
    end

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function Tab:CreateSection(options)
    options = options or {}

    local card = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Surface,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Page,
    })
    create("UICorner", {
        Parent = card,
        CornerRadius = UDim.new(0, 20),
    })
    local stroke = create("UIStroke", {
        Parent = card,
        Thickness = 1,
        Transparency = 0.18,
        Color = self.Window.Theme.Outline,
    })
    applyBackgroundTheme(self.Window, card, "Surface")
    applyStrokeTheme(self.Window, stroke, "Outline")

    local headerButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 64),
        Text = "",
        Parent = card,
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 14),
        Size = UDim2.new(1, -74, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = options.Name or "Section",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerButton,
    })
    applyTextTheme(self.Window, title, "Text")

    local description = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 34),
        Size = UDim2.new(1, -74, 0, 14),
        Font = Enum.Font.Gotham,
        Text = options.Description or "Useful controls live here.",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerButton,
    })
    applyTextTheme(self.Window, description, "TextMuted")

    local chevron = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = ">",
        TextSize = 18,
        Rotation = 90,
        Parent = headerButton,
    })
    applyTextTheme(self.Window, chevron, "TextMuted")

    local separator = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Divider,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -36, 0, 1),
        Position = UDim2.new(0, 18, 0, 64),
        Parent = card,
    })
    self.Window:_trackTheme(function(theme)
        separator.BackgroundColor3 = theme.Divider
    end)

    local content = create("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card,
    })
    create("UIPadding", {
        Parent = content,
        PaddingBottom = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        PaddingTop = UDim.new(0, 6),
    })
    local contentLayout = create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    self.Window:_trackCleanup(contentLayout)

    local section = setmetatable({
        Window = self.Window,
        Tab = self,
        Card = card,
        Content = content,
        Collapsed = options.Collapsed == true,
    }, Section)

    local function syncCollapsed()
        content.Visible = not section.Collapsed
        separator.Visible = not section.Collapsed
        tween(chevron, 0.18, {
            Rotation = section.Collapsed and 0 or 90,
        }, Enum.EasingStyle.Quad)
    end

    section.Window:_trackCleanup(headerButton.MouseButton1Click:Connect(function()
        section.Collapsed = not section.Collapsed
        syncCollapsed()
    end))

    syncCollapsed()

    table.insert(self.Sections, section)
    return section
end

function Section:_createControlFrame(options)
    options = options or {}

    local frame = create("Frame", {
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Content,
    })
    create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 16),
    })
    local stroke = create("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Transparency = 0.22,
        Color = self.Window.Theme.Outline,
    })
    applyBackgroundTheme(self.Window, frame, "SurfaceAlt")
    applyStrokeTheme(self.Window, stroke, "Outline")

    create("UIPadding", {
        Parent = frame,
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 14),
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -140, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Name or "Control",
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    applyTextTheme(self.Window, title, "Text")

    local description
    if options.Description then
        description = create("TextLabel", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, -140, 0, 0),
            Font = Enum.Font.Gotham,
            Text = options.Description,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = frame,
        })
        applyTextTheme(self.Window, description, "TextMuted")
    end

    return frame, title, description
end

function Section:CreateButton(options)
    options = options or {}

    local frame = self:_createControlFrame(options)
    local actionButton = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 136, 0, 38),
        BackgroundColor3 = self.Window.Theme.Accent,
        Font = Enum.Font.GothamBold,
        Text = options.ButtonText or "Run",
        TextSize = 13,
        Parent = frame,
    })
    create("UICorner", {
        Parent = actionButton,
        CornerRadius = UDim.new(0, 12),
    })
    self.Window:_trackTheme(function(theme)
        actionButton.BackgroundColor3 = theme.Accent
        actionButton.TextColor3 = theme.Text
    end)
    self.Window:_registerPressable(actionButton, actionButton)

    self.Window:_trackCleanup(actionButton.MouseButton1Click:Connect(function()
        safeCall(options.Callback)
    end))

    return {
        Press = function()
            safeCall(options.Callback)
        end,
    }
end

function Section:CreateToggle(options)
    options = options or {}
    local frame = self:_createControlFrame(options)

    local hitbox = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 58, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame,
    })

    local switch = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Background,
        Size = UDim2.fromScale(1, 1),
        Parent = hitbox,
    })
    create("UICorner", {
        Parent = switch,
        CornerRadius = UDim.new(1, 0),
    })
    local stroke = create("UIStroke", {
        Parent = switch,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, switch, "Background")
    applyStrokeTheme(self.Window, stroke, "Outline")

    local knob = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Text,
        Position = UDim2.new(0, 4, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Parent = switch,
    })
    create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0),
    })
    self.Window:_trackTheme(function(theme)
        knob.BackgroundColor3 = theme.Text
    end)

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = options.CurrentValue == true,
        Callback = options.Callback,
        Normalize = function(value)
            return value == true
        end,
    })

    local function sync(value)
        tween(switch, 0.18, {
            BackgroundColor3 = value and blend(self.Window.Theme.Accent, self.Window.Theme.SurfaceAlt, 0.25) or self.Window.Theme.Background,
        }, Enum.EasingStyle.Quad)
        tween(knob, 0.18, {
            Position = value and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12),
        }, Enum.EasingStyle.Quint)
    end

    controller.Changed:Connect(sync)
    self.Window:_trackTheme(function()
        sync(controller:Get())
    end)
    controller:Set(controller.Value, true)

    self.Window:_trackCleanup(hitbox.MouseButton1Click:Connect(function()
        controller:Set(not controller:Get())
    end))

    return controller
end

function Section:CreateSlider(options)
    options = options or {}
    local range = options.Range or { 0, 100 }
    local minimum = range[1] or 0
    local maximum = range[2] or 100
    local increment = options.Increment or 1
    local suffix = options.Suffix or ""
    local span = maximum - minimum

    local frame = self:_createControlFrame(options)

    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 120, 0, 18),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })
    applyTextTheme(self.Window, valueLabel, "Accent")

    local bar = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Window.Theme.Background,
        Position = UDim2.new(0, 0, 0, options.Description and 50 or 28),
        Size = UDim2.new(1, 0, 0, 12),
        Text = "",
        Parent = frame,
    })
    create("UICorner", {
        Parent = bar,
        CornerRadius = UDim.new(1, 0),
    })
    applyBackgroundTheme(self.Window, bar, "Background")

    local fill = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = bar,
    })
    create("UICorner", {
        Parent = fill,
        CornerRadius = UDim.new(1, 0),
    })
    self.Window:_trackTheme(function(theme)
        fill.BackgroundColor3 = theme.Accent
    end)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Window.Theme.Text,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = bar,
    })
    create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0),
    })
    self.Window:_trackTheme(function(theme)
        knob.BackgroundColor3 = theme.Text
    end)

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = clamp(roundToIncrement(options.CurrentValue or minimum, increment), minimum, maximum),
        Callback = options.Callback,
        Normalize = function(value)
            return clamp(roundToIncrement(value, increment), minimum, maximum)
        end,
    })

    local dragging = false

    local function sync(value)
        local alpha = span == 0 and 0 or ((value - minimum) / span)
        valueLabel.Text = tostring(value) .. suffix
        tween(fill, 0.14, { Size = UDim2.new(alpha, 0, 1, 0) }, Enum.EasingStyle.Quad)
        tween(knob, 0.14, { Position = UDim2.new(alpha, 0, 0.5, 0) }, Enum.EasingStyle.Quad)
    end

    local function updateFromInput(input)
        local position = extractPosition(input)
        local alpha = clamp((position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        controller:Set(minimum + (span * alpha))
    end

    controller.Changed:Connect(sync)
    self.Window:_trackTheme(function()
        sync(controller:Get())
    end)
    controller:Set(controller.Value, true)

    self.Window:_trackCleanup(bar.MouseButton1Down:Connect(function()
        dragging = true
        updateFromInput(UserInputService:GetMouseLocation())
    end))

    self.Window:_trackCleanup(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    self.Window:_trackCleanup(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end))

    return controller
end

function Section:CreateDropdown(options)
    options = options or {}
    local multi = options.Multi == true
    local optionList = deepCopy(options.Options or {})
    local frame = self:_createControlFrame(options)

    local button = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 190, 0, 38),
        BackgroundColor3 = self.Window.Theme.Background,
        Font = Enum.Font.Gotham,
        Text = "",
        Parent = frame,
    })
    create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 12),
    })
    local buttonStroke = create("UIStroke", {
        Parent = button,
        Thickness = 1,
        Transparency = 0.24,
    })
    applyBackgroundTheme(self.Window, button, "Background")
    applyStrokeTheme(self.Window, buttonStroke, "Outline")

    local selectedText = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })
    applyTextTheme(self.Window, selectedText, "Text")

    local arrow = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "v",
        TextSize = 12,
        Parent = button,
    })
    applyTextTheme(self.Window, arrow, "TextMuted")

    local dropdown = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Background,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = frame,
    })
    create("UICorner", {
        Parent = dropdown,
        CornerRadius = UDim.new(0, 14),
    })
    local dropdownStroke = create("UIStroke", {
        Parent = dropdown,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, dropdown, "Background")
    applyStrokeTheme(self.Window, dropdownStroke, "Outline")

    create("UIPadding", {
        Parent = dropdown,
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
    })

    local optionLayout = create("UIListLayout", {
        Parent = dropdown,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    self.Window:_trackCleanup(optionLayout)

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = multi and deepCopy(options.CurrentValue or {}) or (options.CurrentValue or optionList[1]),
        Callback = options.Callback,
        Normalize = function(value)
            return value
        end,
    })

    local open = false
    local optionButtons = {}

    local function formatValue(value)
        if multi then
            local items = {}
            for _, option in ipairs(optionList) do
                if value[option] then
                    table.insert(items, option)
                end
            end
            return #items > 0 and table.concat(items, ", ") or "Select values"
        end

        return value or "Select value"
    end

    local function syncSelection()
        selectedText.Text = formatValue(controller:Get())
        for option, optionButton in pairs(optionButtons) do
            local active = multi and controller:Get()[option] or controller:Get() == option
            tween(optionButton, 0.15, {
                BackgroundColor3 = active and blend(self.Window.Theme.AccentSoft, self.Window.Theme.SurfaceAlt, 0.2) or self.Window.Theme.SurfaceAlt,
            }, Enum.EasingStyle.Quad)
        end
    end

    local function toggleOpen(state)
        open = state
        dropdown.Visible = state
        tween(arrow, 0.18, { Rotation = state and 180 or 0 }, Enum.EasingStyle.Quad)
    end

    local function rebuildOptions()
        for _, child in ipairs(dropdown:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        optionButtons = {}

        for _, option in ipairs(optionList) do
            local optionButton = create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = self.Window.Theme.SurfaceAlt,
                Size = UDim2.new(1, 0, 0, 34),
                Font = Enum.Font.Gotham,
                Text = option,
                TextSize = 12,
                Parent = dropdown,
            })
            create("UICorner", {
                Parent = optionButton,
                CornerRadius = UDim.new(0, 10),
            })
            self.Window:_trackTheme(function(theme)
                if optionButtons[option] == optionButton then
                    optionButton.TextColor3 = theme.Text
                end
            end)

            self.Window:_trackCleanup(optionButton.MouseButton1Click:Connect(function()
                if multi then
                    local current = deepCopy(controller:Get())
                    current[option] = not current[option]
                    controller:Set(current)
                else
                    controller:Set(option)
                    toggleOpen(false)
                end
                syncSelection()
            end))

            optionButtons[option] = optionButton
        end

        syncSelection()
    end

    controller.Changed:Connect(syncSelection)
    self.Window:_trackTheme(function()
        syncSelection()
    end)
    rebuildOptions()
    controller:Set(controller.Value, true)

    self.Window:_trackCleanup(button.MouseButton1Click:Connect(function()
        toggleOpen(not open)
    end))

    return {
        Get = function()
            return controller:Get()
        end,
        Set = function(_, value)
            controller:Set(value)
        end,
        Refresh = function(_, newOptions, preserveValue)
            optionList = deepCopy(newOptions or {})
            rebuildOptions()

            if not preserveValue then
                if multi then
                    controller:Set({})
                else
                    controller:Set(optionList[1])
                end
            end
        end,
        OnChanged = function(_, callback)
            return controller:OnChanged(callback)
        end,
        Destroy = function()
            controller:Destroy()
        end,
    }
end

function Section:CreateInput(options)
    options = options or {}
    local frame = self:_createControlFrame(options)

    local box = create("TextBox", {
        BackgroundColor3 = self.Window.Theme.Background,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 220, 0, 38),
        Font = Enum.Font.Gotham,
        PlaceholderText = options.PlaceholderText or "Type here",
        Text = tostring(options.CurrentValue or ""),
        TextSize = 12,
        ClearTextOnFocus = false,
        Parent = frame,
    })
    create("UICorner", {
        Parent = box,
        CornerRadius = UDim.new(0, 12),
    })
    local boxStroke = create("UIStroke", {
        Parent = box,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, box, "Background")
    applyStrokeTheme(self.Window, boxStroke, "Outline")
    applyTextTheme(self.Window, box, "Text")
    self.Window:_trackTheme(function(theme)
        box.PlaceholderColor3 = theme.TextMuted
    end)

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = tostring(options.CurrentValue or ""),
        Callback = options.Callback,
        Normalize = function(value)
            return tostring(value or "")
        end,
        Apply = function(value)
            box.Text = value
        end,
    })

    self.Window:_trackCleanup(box.FocusLost:Connect(function(enterPressed)
        if options.RemoveTextAfterFocusLost then
            controller:Set(box.Text)
            box.Text = ""
            return
        end

        if not options.OnlyCallbackOnEnter or enterPressed then
            controller:Set(box.Text)
        end
    end))

    return controller
end

function Section:CreateParagraph(options)
    options = options or {}

    local frame = create("Frame", {
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Content,
    })
    create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 16),
    })
    local stroke = create("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, frame, "SurfaceAlt")
    applyStrokeTheme(self.Window, stroke, "Outline")
    create("UIPadding", {
        Parent = frame,
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 14),
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Name or "Paragraph",
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    applyTextTheme(self.Window, title, "Text")

    local text = create("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 0),
        Font = Enum.Font.Gotham,
        Text = options.Content or "",
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
    })
    applyTextTheme(self.Window, text, "TextMuted")

    return {
        Set = function(_, newContent)
            text.Text = tostring(newContent or "")
        end,
    }
end

function Section:CreateLabel(options)
    options = options or {}
    local frame = create("Frame", {
        BackgroundColor3 = self.Window.Theme.AccentSoft,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Content,
    })
    create("UICorner", {
        Parent = frame,
        CornerRadius = UDim.new(0, 14),
    })
    create("UIPadding", {
        Parent = frame,
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 12),
    })
    self.Window:_trackTheme(function(theme)
        frame.BackgroundColor3 = theme.AccentSoft
    end)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Text or "Label",
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    applyTextTheme(self.Window, label, "Text")

    return {
        Set = function(_, textValue)
            label.Text = tostring(textValue or "")
        end,
    }
end

function Section:CreateKeybind(options)
    options = options or {}
    local frame = self:_createControlFrame(options)

    local button = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 160, 0, 38),
        BackgroundColor3 = self.Window.Theme.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = frame,
    })
    create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 12),
    })
    local stroke = create("UIStroke", {
        Parent = button,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, button, "Background")
    applyStrokeTheme(self.Window, stroke, "Outline")
    applyTextTheme(self.Window, button, "Text")

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = options.CurrentKeybind or Enum.KeyCode.Unknown,
        Callback = nil,
        Normalize = function(value)
            return value
        end,
        Apply = function(value)
            button.Text = value == Enum.KeyCode.Unknown and "Unbound" or value.Name
        end,
    })

    local listening = false

    self.Window:_trackCleanup(button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "Press a key..."
    end))

    self.Window:_trackCleanup(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                controller:Set(input.KeyCode)
            end
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == controller:Get() and controller:Get() ~= Enum.KeyCode.Unknown then
            safeCall(options.Callback, input.KeyCode)
        end
    end))

    controller:Set(controller.Value, true)
    return controller
end

function Section:CreateColorPicker(options)
    options = options or {}
    local frame = self:_createControlFrame(options)

    local toggleButton = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 180, 0, 38),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = "",
        Parent = frame,
    })
    create("UICorner", {
        Parent = toggleButton,
        CornerRadius = UDim.new(0, 12),
    })
    local toggleStroke = create("UIStroke", {
        Parent = toggleButton,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, toggleButton, "Background")
    applyStrokeTheme(self.Window, toggleStroke, "Outline")

    local preview = create("Frame", {
        BackgroundColor3 = options.CurrentValue or Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 8, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        Parent = toggleButton,
    })
    create("UICorner", {
        Parent = preview,
        CornerRadius = UDim.new(1, 0),
    })

    local previewLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleButton,
    })
    applyTextTheme(self.Window, previewLabel, "Text")

    local picker = create("Frame", {
        BackgroundColor3 = self.Window.Theme.Background,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = frame,
    })
    create("UICorner", {
        Parent = picker,
        CornerRadius = UDim.new(0, 14),
    })
    local pickerStroke = create("UIStroke", {
        Parent = picker,
        Thickness = 1,
        Transparency = 0.22,
    })
    applyBackgroundTheme(self.Window, picker, "Background")
    applyStrokeTheme(self.Window, pickerStroke, "Outline")
    create("UIPadding", {
        Parent = picker,
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
    })

    local satVal = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Size = UDim2.new(1, -28, 0, 140),
        Text = "",
        Parent = picker,
    })
    create("UICorner", {
        Parent = satVal,
        CornerRadius = UDim.new(0, 12),
    })
    create("UIGradient", {
        Parent = satVal,
        Rotation = 0,
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })
    local darkness = create("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = satVal,
    })
    create("UICorner", {
        Parent = darkness,
        CornerRadius = UDim.new(0, 12),
    })
    create("UIGradient", {
        Parent = darkness,
        Rotation = 90,
        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
    })

    local satCursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 14, 0, 14),
        Parent = satVal,
    })
    create("UICorner", {
        Parent = satCursor,
        CornerRadius = UDim.new(1, 0),
    })

    local hue = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 0, 0, 152),
        Size = UDim2.new(1, -28, 0, 14),
        Text = "",
        Parent = picker,
    })
    create("UICorner", {
        Parent = hue,
        CornerRadius = UDim.new(1, 0),
    })
    create("UIGradient", {
        Parent = hue,
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    })
    local hueCursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Parent = hue,
    })
    create("UICorner", {
        Parent = hueCursor,
        CornerRadius = UDim.new(1, 0),
    })

    local controller = createController(self.Window, {
        Flag = options.Flag,
        Value = options.CurrentValue or Color3.fromRGB(255, 255, 255),
        Callback = options.Callback,
        Normalize = function(value)
            return value
        end,
    })

    local open = false
    local hueValue, saturationValue, brightnessValue = controller.Value:ToHSV()
    local draggingSatVal = false
    local draggingHue = false

    local function refreshPicker()
        local color = Color3.fromHSV(hueValue, saturationValue, brightnessValue)
        controller:Set(color)
    end

    local function setFromColor(color)
        hueValue, saturationValue, brightnessValue = color:ToHSV()
        preview.BackgroundColor3 = color
        previewLabel.Text = string.format("RGB %d, %d, %d", color.R * 255, color.G * 255, color.B * 255)
        satVal.BackgroundColor3 = Color3.fromHSV(hueValue, 1, 1)
        satCursor.Position = UDim2.new(saturationValue, 0, 1 - brightnessValue, 0)
        hueCursor.Position = UDim2.new(hueValue, 0, 0.5, 0)
    end

    local function updateSatVal(input)
        local position = extractPosition(input)
        local x = clamp((position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
        local y = clamp((position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
        saturationValue = x
        brightnessValue = 1 - y
        refreshPicker()
    end

    local function updateHue(input)
        local position = extractPosition(input)
        local alpha = clamp((position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
        hueValue = alpha
        refreshPicker()
    end

    self.Window:_trackCleanup(toggleButton.MouseButton1Click:Connect(function()
        open = not open
        picker.Visible = open
    end))

    self.Window:_trackCleanup(satVal.MouseButton1Down:Connect(function()
        draggingSatVal = true
        updateSatVal(UserInputService:GetMouseLocation())
    end))

    self.Window:_trackCleanup(hue.MouseButton1Down:Connect(function()
        draggingHue = true
        updateHue(UserInputService:GetMouseLocation())
    end))

    self.Window:_trackCleanup(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSatVal = false
            draggingHue = false
        end
    end))

    self.Window:_trackCleanup(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if draggingSatVal then
            updateSatVal(input)
        elseif draggingHue then
            updateHue(input)
        end
    end))

    controller.Changed:Connect(function(color)
        setFromColor(color)
    end)
    setFromColor(controller.Value)
    return controller
end

return EldoraUI
