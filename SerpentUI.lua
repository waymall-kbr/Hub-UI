--[[
    SerpentUI v1.0
    Custom Roblox UI Library — dark theme, fluent controls, zero dependencies.

    Usage:
        local UI = loadstring(game:HttpGet("..."))()
        local Window = UI:CreateWindow({ Title = "My Hub", Size = UDim2.fromOffset(540, 400) })
        local Tab = Window:Tab({ Title = "Main", Icon = "home" })
        Tab:Toggle({ Title = "Feature", Callback = function(v) end })
        Tab:Slider({ Title = "Speed", Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) end })
        Tab:Button({ Title = "Do Thing", Callback = function() end })
        Tab:Dropdown({ Title = "Mode", Values = {"A","B"}, Value = "A", Callback = function(v) end })
        Tab:Input({ Title = "Enter name", Placeholder = "type...", Callback = function(t) end })
        Tab:Paragraph({ Title = "Info", Desc = "Some text" })
]]

-- ═══════════════════════════════════════════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════════════════════════════════════════
local T = {
    -- colours
    BG            = Color3.fromHex("#0d0d0f"),
    Card          = Color3.fromHex("#16161a"),
    CardHover     = Color3.fromHex("#1e1e24"),
    Border        = Color3.fromHex("#2a2a32"),
    Accent        = Color3.fromHex("#7c5cfc"),
    AccentGlow    = Color3.fromHex("#9b7fff"),
    TextPrimary   = Color3.fromHex("#e8e8ed"),
    TextSecondary = Color3.fromHex("#8b8b99"),
    ToggleOn      = Color3.fromHex("#7c5cfc"),
    ToggleOff     = Color3.fromHex("#3a3a44"),
    SliderTrack   = Color3.fromHex("#2a2a32"),
    InputBG       = Color3.fromHex("#111115"),
    DotRed        = Color3.fromHex("#ef4444"),
    DotGreen      = Color3.fromHex("#22c55e"),
    Scroll        = Color3.fromHex("#2a2a32"),

    -- sizing
    Radius      = 8,
    TabHeight   = 36,
    ElementGap  = 8,
    SidebarW    = 160,
    TopbarH     = 44,
    FooterH     = 28,

    -- fonts
    Font        = Enum.Font.Gotham,
    FontSmall   = Enum.Font.Gotham,
}

-- ═══════════════════════════════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════

local function make(cls: string, props: {[string]: any}?): Instance
    local o = Instance.new(cls)
    if props then
        for k, v in props do o[k] = v end
    end
    return o
end

local function corner(radius: number, fill: boolean?): UICorner
    local c = make("UICorner", { CornerRadius = UDim.new(0, radius) })
    if fill == false then
        -- keep default but allow caller to set as needed
    end
    return c
end

local function stroke(color: Color3?, thickness: number?): UIStroke
    return make("UIStroke", {
        Color = color or T.Border,
        Thickness = thickness or 1,
        Transparency = 0.4,
    })
end

local function pad(bottom: number?, left: number?, right: number?, top: number?): UIPadding
    return make("UIPadding", {
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left or 0),
        PaddingRight  = UDim.new(0, right or 0),
        PaddingTop    = UDim.new(0, top or 0),
    })
end

local function layout(dir: string?, pad: UIPadding?, sort: boolean?): UIFlexItem?
    local l = make("UIListLayout", {
        FillDirection = if dir then Enum.FillDirection[dir:gsub("^%l", string.upper)] else Enum.FillDirection.Vertical,
        SortOrder = if sort ~= false then Enum.SortOrder.LayoutOrder else Enum.SortOrder.Custom,
        Padding = UDim.new(0, 6),
    })
    if pad then l.Parent = pad.Parent; pad:Destroy() end
    return l
end

local function sizeFit(axis: string, offset: number?): UISize
    return UISize.new(if axis == "X" then UDim.new(0, offset or 0) else UDim.new(0, 0),
                      if axis == "X" then UDim.new(0, 0) else UDim.new(1, 0))
end

-- ═══════════════════════════════════════════════════════════════════════════
--  NOTIFY
-- ═══════════════════════════════════════════════════════════════════════════

local NotifyQueue: {Instance} = {}
local function showNotify(title: string, content: string, icon: string?, duration: number?)
    duration = duration or 3
    local PlayerGui = game.Players.LocalPlayer.PlayerGui
    local existing = PlayerGui:FindFirstChild("SerpentNotify")
    if not existing then
        existing = make("ScreenGui", { Name = "SerpentNotify", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999 })
        existing.Parent = PlayerGui
    end

    local container = existing:FindFirstChild("Container") or function()
        local c = make("Frame", { Name = "Container", Size = UDim2.fromOffset(320, 0), Position = UDim2.new(1, -20, 1, -20), AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1 })
        local ll = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right })
        ll.Parent = c
        c.Parent = existing
        return c
    end()

    local card = make("Frame", {
        Size = UDim2.fromOffset(300, 80),
        BackgroundTransparency = 0,
        BackgroundColor3 = T.Card,
        LayoutOrder = #container:GetChildren(),
    })
    corner(T.Radius)(card)
    stroke(T.Border)(card)

    local innerPad = pad(10, 12, 12, 10)
    innerPad.Parent = card

    local iconText = make("TextLabel", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = T.Accent,
        Text = icon and icon:sub(1, 1):upper() or "!",
        TextColor3 = T.TextPrimary,
        TextScaled = true,
        Font = T.Font,
    })
    corner(T.Radius - 2)(iconText)
    iconText.Parent = card

    local titleLabel = make("TextLabel", {
        Size = UDim2.new(1, -44, 0, 18),
        Position = UDim2.fromOffset(36, 0),
        BackgroundTransparency = 1,
        Text = title or "",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    titleLabel.Parent = card

    local contentLabel = make("TextLabel", {
        Size = UDim2.new(1, -10, 0, container.AbsoluteSize.Y or 100),
        Position = UDim2.fromOffset(10, 20),
        BackgroundTransparency = 1,
        Text = content or "",
        TextColor3 = T.TextSecondary,
        Font = T.FontSmall,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    contentLabel.Parent = card

    card.Parent = container

    -- slide in
    card.Position = UDim2.fromScale(1.05, 0)
    game:GetService("TweenService"):Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(1, 0)
    }):Play()

    task.delay(duration, function()
        if not card or not card.Parent then return end
        local ts = game:GetService("TweenService")
        ts:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.fromScale(1.05, 0)
        }):Play()
        task.delay(0.3, function()
            if card and card.Parent then card:Destroy() end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════════════════════

export type WindowConfig = {
    Title: string?,
    Author: string?,
    Size: UDim2?,
    Theme: string?,
    Resizable: boolean?,
    Transparent: boolean?,
    ToggleKey: Enum.KeyCode?,
    SidebarWidth: number?,
}

export type TabConfig = {
    Title: string?,
    Icon: string?,
}

export type ElementConfig = {
    Title: string?,
    Desc: string?,
    Value: any?,
    Values: {string}?,
    Callback: ((any) -> ())?,
    Placeholder: string?,
}

local WindowMT = {}
WindowMT.__index = WindowMT

function WindowMT:Tab(cfg: TabConfig?)
    local tab: Tab = {
        Title = cfg and cfg.Title or "Tab",
        Icon = cfg and cfg.Icon or nil,
        Elements = {},
        _parent = self,
    }
    setmetatable(tab, TabMT)
    -- build sidebar button
    local btn = tab:_buildNavButton()
    btn.LayoutOrder = #self._tabs + 1
    btn.Parent = self._sidebarNav

    -- build tab panel holder
    local holder = make("ScrollingFrame", {
        Name = tab.Title,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = T.Scroll,
        Visible = (#self._tabs == 0), -- first tab visible
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim.new(0, 0),
    })
    pad(10, 10, 10, 10)(holder)
    local ll = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, T.ElementGap) })
    ll.Parent = holder
    holder.Parent = self._contentClip

    tab._holder = holder
    tab._btn = btn
    table.insert(self._tabs, tab)
    return tab
end

function WindowMT:Destroy()
    if self._root and self._root.Parent then
        self._root:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════════════════════════════

local TabMT = {}
TabMT.__index = TabMT

function TabMT:_buildNavButton()
    local btn = make("TextButton", {
        Size = UDim2.new(1, -10, 0, T.TabHeight - 4),
        BackgroundColor3 = T.ToggleOff,
        Text = self.Title,
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    corner(6)(btn)
    pad(0, 10, 10, 0)(btn)

    local iconLabel = make("TextLabel", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.fromOffset(4, (T.TabHeight - 24) / 2 - 2),
        BackgroundTransparency = 1,
        Text = self.Icon and self.Icon:sub(1, 1):upper() or "•",
        TextColor3 = T.AccentGlow,
        Font = T.Font,
        TextSize = 13,
    })
    iconLabel.Parent = btn
    self._iconLabel = iconLabel

    local hoverConn
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = T.CardHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = T.ToggleOff
    end)
    btn.Activated:Connect(function()
        self._parent:_selectTab(self)
    end)
    return btn
end

function TabMT:_select()
    self._btn.BackgroundColor3 = T.Accent
    self._iconLabel.TextColor3 = T.TextPrimary
    if self._holder then self._holder.Visible = true end
end

function TabMT:_deselect()
    self._btn.BackgroundColor3 = T.ToggleOff
    self._iconLabel.TextColor3 = T.AccentGlow
    if self._holder then self._holder.Visible = false end
end

function TabMT:_getHolder()
    return self._holder
end

-- -- element factory helper
local function elementCard(tab: Tab, opts: {[string]: any}?)
    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, (opts and opts.Height) or 44),
        BackgroundColor3 = T.Card,
        LayoutOrder = (opts and opts.LayoutOrder) or 0,
        BackgroundTransparency = opts and opts.Transparent or 0,
    })
    corner(T.Radius)(card)
    stroke(T.Border)(card)
    pad(10, 12, 12, 10)(card)
    card.Parent = tab:_getHolder()
    return card
end

-- ═══════════════════════════════════════════════════════════════════════════
--  ELEMENTS
-- ═══════════════════════════════════════════════════════════════════════════

function TabMT:Paragraph(cfg: ElementConfig)
    local card = elementCard(self, { Height = #(cfg.Desc or ""):gsub("\n", "\n") * 16 + 44 })
    local title = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = cfg.Title or "",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    })
    title.Parent = card

    local desc = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 20),
        BackgroundTransparency = 1,
        Text = cfg.Desc or "",
        TextColor3 = T.TextSecondary,
        Font = T.FontSmall,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    desc.Parent = card
    desc.Size = UDim2.new(1, 0, 0, desc.AutomaticSize.Y.Offset or 0)

    local api = {
        SetDesc = function(t: string) desc.Text = t end,
        SetTitle = function(t: string) title.Text = t end,
    }
    return api
end

function TabMT:Button(cfg: ElementConfig)
    local card = elementCard(self, { Height = 44 })
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = T.Accent,
        Text = cfg.Title or "Button",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        AutoButtonColor = false,
    })
    corner(6)(btn)
    pad(0, 8, 8, 0)(btn)
    -- overlay flash
    local flash = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    })
    corner(6)(flash)
    flash.Parent = btn
    local ts = game:GetService("TweenService")
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = T.AccentGlow
        ts:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 0.85 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = T.Accent
        ts:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    end)
    btn.Activated:Connect(function()
        if cfg.Callback then task.spawn(cfg.Callback) end
    end)
    btn.Parent = card
end

function TabMT:Toggle(cfg: ElementConfig)
    local card = elementCard(self, { Height = 44 })
    local state = cfg.Value == true
    local titleLbl = make("TextLabel", {
        Size = UDim2.new(1, -56, 0, 18),
        Position = UDim2.fromOffset(0, 6),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Toggle",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    titleLbl.Parent = card

    if cfg.Desc then
        local desc = make("TextLabel", {
            Size = UDim2.new(1, -20, 0, 14),
            Position = UDim2.fromOffset(0, 22),
            BackgroundTransparency = 1,
            Text = cfg.Desc,
            TextColor3 = T.TextSecondary,
            Font = T.FontSmall,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        desc.Parent = card
    end

    local switch = make("Frame", {
        Size = UDim2.fromOffset(42, 24),
        Position = UDim2.new(1, -52, 0.5, -12),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
    })
    corner(12)(switch)
    local thumb = make("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(state and 22 or 4, 4),
        BackgroundColor3 = T.TextPrimary,
    })
    corner(8)(thumb)
    thumb.Parent = switch
    switch.Parent = card

    local function set(v: boolean)
        state = v
        switch.BackgroundColor3 = v and T.ToggleOn or T.ToggleOff
        thumb.Position = UDim2.fromOffset(v and 22 or 4, 4)
        if cfg.Callback then task.spawn(cfg.Callback, v) end
    end

    switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    set(not state)
                    conn:Disconnect()
                end
            end)
        end
    end)
    -- allow whole card click too
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    set(not state)
                    conn:Disconnect()
                end
            end)
        end
    end)
end

function TabMT:Slider(cfg: ElementConfig)
    local card = elementCard(self, { Height = 64 })
    local currVal = (cfg.Value and cfg.Value.Default) or 0
    local minV, maxV = (cfg.Value and cfg.Value.Min) or 0, (cfg.Value and cfg.Value.Max) or 100
    local step = cfg.Step or 1

    local titleLbl = make("TextLabel", {
        Size = UDim2.new(1, -10, 0, 18),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Slider",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    })
    titleLbl.Parent = card

    -- value pill
    local valPill = make("TextLabel", {
        Size = UDim2.fromOffset(52, 20),
        Position = UDim2.new(1, -60, 0, 6),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = T.ToggleOff,
        Text = tostring(currVal),
        TextColor3 = T.TextSecondary,
        Font = T.FontSmall,
        TextSize = 11,
    })
    corner(4)(valPill)
    valPill.Parent = card

    -- track
    local trackW = 200
    local track = make("Frame", {
        Size = UDim2.new(0, trackW, 0, 6),
        Position = UDim2.fromOffset(0, 28),
        BackgroundColor3 = T.SliderTrack,
    })
    corner(3)(track)
    track.Parent = card

    -- fill
    local fillW = math.clamp((currVal - minV) / (maxV - minV), 0, 1) * trackW
    local fill = make("Frame", {
        Size = UDim2.fromOffset(fillW, 6),
        BackgroundColor3 = T.Accent,
    })
    corner(3)(fill)
    fill.Parent = track

    -- thumb
    local thumbSize = 16
    local thumb = make("Frame", {
        Size = UDim2.fromOffset(thumbSize, thumbSize),
        Position = UDim2.fromOffset(fillW - thumbSize / 2, 28 - (thumbSize - 6) / 2),
        BackgroundColor3 = T.TextPrimary,
    })
    corner(8)(thumb)
    thumb.Parent = card

    local function update(v: number)
        v = math.clamp(math.floor(v / step + 0.5) * step, minV, maxV)
        currVal = v
        fillW = math.clamp((v - minV) / (maxV - minV), 0, 1) * trackW
        fill.Size = UDim2.fromOffset(fillW, 6)
        thumb.Position = UDim2.fromOffset(fillW - thumbSize / 2, 28 - (thumbSize - 6) / 2)
        valPill.Text = tostring(v)
        if cfg.Callback then task.spawn(cfg.Callback, v) end
    end

    local dragging = false
    local function getVal(input: InputObject)
        local rel = input.Position.X - track.AbsolutePosition.X
        local t = math.clamp(rel / trackW, 0, 1)
        return minV + t * (maxV - minV)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(getVal(input))
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(getVal(input))
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(getVal(input))
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
        end
    end)
end

function TabMT:Dropdown(cfg: ElementConfig)
    local card = elementCard(self, { Height = 52 })
    local selected = cfg.Value or ""
    local values = cfg.Values or {}
    local expanded = false

    local titleLbl = make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Dropdown",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    titleLbl.Parent = card

    local btn = make("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = T.InputBG,
        Text = "  " .. (selected or values[1] or "(none)"),
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    corner(6)(btn)
    stroke(T.Border)(btn)
    btn.Parent = card

    local arrow = make("TextLabel", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -30, 0, 25),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = T.TextSecondary,
        Font = T.Font,
        TextSize = 14,
    })
    arrow.Parent = card

    local listFrame: Frame?
    local function close()
        if listFrame then listFrame:Destroy(); listFrame = nil end
        expanded = false
        arrow.Text = "▾"
        card.Size = UDim2.new(1, 0, 0, 52)
    end
    local function open()
        if expanded then close(); return end
        expanded = true
        arrow.Text = "▴"
        local n = #values
        local h = n * 30 + 6
        card.Size = UDim2.new(1, 0, 0, 52 + h)

        listFrame = make("Frame", {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.fromOffset(0, 50),
            BackgroundColor3 = T.Card,
        })
        corner(T.Radius)(listFrame)
        stroke(T.Border)(listFrame)
        listFrame.Parent = card

        local ll = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })
        ll.Parent = listFrame
        pad(3, 3, 3, 3)(listFrame)

        for _, v in values do
            local item = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 0,
                BackgroundColor3 = T.CardHover,
                Text = v,
                TextColor3 = T.TextPrimary,
                Font = T.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
            })
            corner(4)(item)
            pad(0, 8, 8, 0)(item)
            item.LayoutOrder = table.find(values, v)
            item.Parent = listFrame
            item.MouseEnter:Connect(function() item.BackgroundColor3 = T.Accent end)
            item.MouseLeave:Connect(function() item.BackgroundColor3 = T.CardHover end)
            item.Activated:Connect(function()
                selected = v
                btn.Text = "  " .. v
                close()
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end)
        end
    end

    btn.Activated:Connect(function()
        if expanded then close() else open() end
    end)
    -- close on outside click
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local hit = game:GetService("Players").LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            local inside = false
            for _, o in hit do
                if o == card or o:IsDescendantOf(card) then inside = true; break end
            end
            if not inside then close() end
        end
    end)
end

function TabMT:Input(cfg: ElementConfig)
    local card = elementCard(self, { Height = 56 })
    local titleLbl = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Input",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    titleLbl.Parent = card
    local box = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 22),
        BackgroundColor3 = T.InputBG,
        PlaceholderText = cfg.Placeholder or "",
        Text = "",
        TextColor3 = T.TextPrimary,
        PlaceholderColor3 = T.TextSecondary,
        Font = T.Font,
        TextSize = 12,
        ClearTextOnFocus = false,
    })
    corner(6)(box)
    stroke(T.Border)(box)
    box.Parent = card

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and cfg.Callback then
            task.spawn(cfg.Callback, box.Text)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  CREATEWINDOW
-- ═══════════════════════════════════════════════════════════════════════════

export type LibraryAPI = {
    CreateWindow: (WindowConfig) -> any,
    Notify: ({Title: string, Content: string, Icon: string?, Duration: number?}) -> (),
}

function LibraryAPI:CreateWindow(cfg: WindowConfig?)
    cfg = cfg or {}
    local LP = game:GetService("Players").LocalPlayer
    local PlayerGui = LP.PlayerGui

    -- root
    local root = make("ScreenGui", { Name = "SerpentUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9998 })
    root.Parent = PlayerGui

    local win = make("Frame", {
        Name = "Window",
        Size = cfg.Size or UDim2.fromOffset(540, 400),
        Position = UDim2.new(0.5, -(cfg.Size and cfg.Size.X.Offset or 540) / 2, 0.5, -(cfg.Size and cfg.Size.Y.Offset or 400) / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.BG,
        Draggable = true,
    })
    corner(T.Radius)(win)
    stroke(T.Border)(win)
    win.Parent = root

    -- shadow frame (bigger, behind)
    local shadow = make("Frame", {
        Size = UDim2.new(1, 16, 1, 16),
        Position = UDim2.fromOffset(-8, -8),
        BackgroundColor3 = Color3.fromHex("#000000"),
        BackgroundTransparency = 0.6,
        ZIndex = 0,
    })
    corner(T.Radius + 2)(shadow)
    shadow.Parent = win

    local contentClip = make("Frame", {
        Size = UDim2.new(1, 0, 1, -T.TopbarH),
        Position = UDim2.fromOffset(0, T.TopbarH),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })
    contentClip.Parent = win

    -- topbar
    local topbar = make("Frame", {
        Size = UDim2.new(1, 0, 0, T.TopbarH),
        BackgroundColor3 = T.Card,
    })
    corner(T.Radius, false)(topbar)
    -- clip only top corners (placeholder — leaving full-radius for consistency)
    pad(0, 12, 12, 0)(topbar)
    topbar.Parent = win

    local titleLabel = make("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = cfg.Title or "SerpentUI",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    titleLabel.Parent = topbar

    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = T.ToggleOff,
        Text = "✕",
        TextColor3 = T.TextPrimary,
        Font = T.Font,
        TextSize = 12,
        AutoButtonColor = false,
    })
    corner(6)(closeBtn)
    closeBtn.Parent = topbar
    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = T.DotRed end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = T.ToggleOff end)
    closeBtn.Activated:Connect(function()
        win.Visible = false
    end)
    -- re-show on toggle key if set
    if cfg.ToggleKey then
        game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == cfg.ToggleKey then
                win.Visible = not win.Visible
            end
        end)
    end

    -- sidebar
    local sidebar = make("Frame", {
        Size = UDim2.new(0, cfg.SidebarWidth or T.SidebarW, 1, -T.TopbarH),
        Position = UDim2.fromOffset(0, T.TopbarH),
        BackgroundColor3 = T.Card,
    })
    corner(T.Radius, false)(sidebar)
    local sPad = pad(8, 6, 6, 8)
    sPad.Parent = sidebar
    sidebar.Parent = win
    local sidebarNav = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    })
    local navLL = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
    navLL.Parent = sidebarNav
    sidebarNav.Parent = sidebar

    -- content box
    local contentBox = make("ScrollingFrame", {
        Size = UDim2.new(1, -(cfg.SidebarWidth or T.SidebarW), 1, 0),
        Position = UDim2.new(0, cfg.SidebarWidth or T.SidebarW, 0, T.TopbarH),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = T.Scroll,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim.new(0, 0),
        ClipsDescendants = true,
    })
    pad(12, 8, 8, 8)(contentBox)
    local cLL = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, T.ElementGap) })
    cLL.Parent = contentBox
    contentBox.Parent = win

    local self2 = {
        _root = root,
        _win = win,
        _topbar = topbar,
        _sidebar = sidebar,
        _sidebarNav = sidebarNav,
        _contentClip = contentBox,
        _content = contentBox,
        _tabs = {},
        _titleLabel = titleLabel,
        _config = cfg,
    }
    setmetatable(self2, { __index = WindowMT })

    -- select first tab by default
    self2:_selectTab = function(_, tab: Tab)
        for _, t in self2._tabs do t:_deselect() end
        tab:_select()
    end

    function self2:SetTitle(t: string)
        self._titleLabel.Text = t
    end

    function self2:Notify(n: {Title: string, Content: string, Icon: string?, Duration: number?})
        showNotify(n.Title, n.Content, n.Icon, n.Duration)
    end

    return self2
end

-- ═══════════════════════════════════════════════════════════════════════════
--  EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

local Library: LibraryAPI = {}
setmetatable(Library, { __index = LibraryAPI })

return Library
