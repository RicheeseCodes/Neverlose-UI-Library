-- NEVERLOSE UI BUNDLED
local __modules = {}
local function __require(name)
    if type(__modules[name]) == 'function' then
        __modules[name] = __modules[name]()
    end
    return __modules[name]
end

__modules["ThemeManager"] = function()
    local ThemeManager = {
        Theme = {
            Main = Color3.fromRGB(15, 15, 20),
            Accent = Color3.fromRGB(0, 185, 255),
            Outline = Color3.fromRGB(40, 40, 50),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(130, 130, 140),
            Groupbox = Color3.fromRGB(18, 18, 24),
            TabDark = Color3.fromRGB(20, 20, 25),
            ElementBackground = Color3.fromRGB(15, 15, 20),
        },
        Font = {
            Main = Enum.Font.Gotham,
            Bold = Enum.Font.GothamBold,
            Size = 12,
            SmallSize = 11
        }
    }
    
    function ThemeManager:GetColor(name)
        return self.Theme[name] or Color3.new(1, 1, 1)
    end
    
    function ThemeManager:GetFont(name)
        return self.Font[name] or Enum.Font.Gotham
    end
    
    return ThemeManager
    
end

__modules["Utility"] = function()
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local TextService = game:GetService("TextService")
    
    local Utility = {}
    
    function Utility:MakeDraggable(frame, topBar)
        local dragging = false
        local dragInput, dragStart, startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end
    
    function Utility:Tween(object, properties, duration)
        duration = duration or 0.15
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end
    
    function Utility:GetTextBounds(text, font, size)
        return TextService:GetTextSize(text, size, font, Vector2.new(10000, 10000))
    end
    
    return Utility
    
end

__modules["Toggle"] = function()
    local Toggle = {}
    Toggle.__index = Toggle
    
    function Toggle.new(options, groupbox)
        local self = setmetatable({}, Toggle)
        self.Options = options
        self.Text = options.Text
        self.Flag = options.Flag
        self.Callback = options.Callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        self.State = options.Default or false
        
        self.Library.Flags[self.Flag] = self.State
        
        local theme = self.Library.Theme
        local util = self.Library.Util
        
        local container = Instance.new("TextButton")
        container.Size = UDim2.new(1, 0, 0, 15)
        container.BackgroundTransparency = 1
        container.Text = ""
        container.Parent = self.Groupbox.Container
        self.Container = container
        
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 11, 0, 11)
        box.Position = UDim2.new(0, 0, 0.5, -5)
        box.BackgroundColor3 = theme:GetColor("ElementBackground")
        box.BorderColor3 = theme:GetColor("Outline")
        box.Parent = container
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(1, -2, 1, -2)
        fill.Position = UDim2.new(0, 1, 0, 1)
        fill.BackgroundColor3 = theme:GetColor("Accent")
        fill.BorderSizePixel = 0
        fill.BackgroundTransparency = self.State and 0 or 1
        fill.Parent = box
        self.Fill = fill
        
        local label = Instance.new("TextLabel")
        label.Text = self.Text
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 20, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = self.State and theme:GetColor("Text") or theme:GetColor("TextDark")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        self.Label = label
        
        container.MouseButton1Click:Connect(function()
            self:SetState(not self.State)
        end)
        
        return self
    end
    
    function Toggle:SetState(state)
        self.State = state
        self.Library.Flags[self.Flag] = self.State
        
        local theme = self.Library.Theme
        local util = self.Library.Util
        
        util:Tween(self.Fill, {BackgroundTransparency = state and 0 or 1}, 0.15)
        util:Tween(self.Label, {TextColor3 = state and theme:GetColor("Text") or theme:GetColor("TextDark")}, 0.15)
        
        task.spawn(self.Callback, self.State)
    end
    
    return Toggle
    
end

__modules["Slider"] = function()
    local UserInputService = game:GetService("UserInputService")
    
    local Slider = {}
    Slider.__index = Slider
    
    function Slider.new(options, groupbox)
        local self = setmetatable({}, Slider)
        self.Options = options
        self.Text = options.Text
        self.Flag = options.Flag
        self.Min = options.Min or 0
        self.Max = options.Max or 100
        self.Callback = options.Callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        self.Value = options.Default or self.Min
        self.Dragging = false
        
        self.Library.Flags[self.Flag] = self.Value
        
        local theme = self.Library.Theme
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = self.Groupbox.Container
        self.Container = container
        
        local label = Instance.new("TextLabel")
        label.Text = self.Text
        label.Size = UDim2.new(1, 0, 0, 15)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("TextDark")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Text = tostring(self.Value)
        valLabel.Size = UDim2.new(1, 0, 0, 15)
        valLabel.BackgroundTransparency = 1
        valLabel.TextColor3 = theme:GetColor("Text")
        valLabel.TextSize = theme:GetFont("SmallSize")
        valLabel.Font = theme:GetFont("Main")
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = container
        self.ValueLabel = valLabel
        
        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(1, 0, 0, 6)
        bar.Position = UDim2.new(0, 0, 0, 18)
        bar.BackgroundColor3 = theme:GetColor("ElementBackground")
        bar.BorderColor3 = theme:GetColor("Outline")
        bar.Text = ""
        bar.AutoButtonColor = false
        bar.Parent = container
        self.Bar = bar
        
        local initialPct = (self.Value - self.Min) / (self.Max - self.Min)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(initialPct, 0, 1, 0)
        fill.BackgroundColor3 = theme:GetColor("Accent")
        fill.BorderSizePixel = 0
        fill.Parent = bar
        self.Fill = fill
        
        bar.MouseButton1Down:Connect(function()
            self.Dragging = true
            self:Update(UserInputService:GetMouseLocation().X)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                self:Update(UserInputService:GetMouseLocation().X)
            end
        end)
        
        return self
    end
    
    function Slider:Update(mouseX)
        local barPos = self.Bar.AbsolutePosition.X
        local barSize = self.Bar.AbsoluteSize.X
        local pct = math.clamp((mouseX - barPos) / barSize, 0, 1)
        
        self.Value = math.floor(self.Min + ((self.Max - self.Min) * pct))
        self.Library.Flags[self.Flag] = self.Value
        self.ValueLabel.Text = tostring(self.Value)
        
        local util = self.Library.Util
        util:Tween(self.Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
        
        task.spawn(self.Callback, self.Value)
    end
    
    function Slider:SetValue(val)
        self.Value = math.clamp(val, self.Min, self.Max)
        self.Library.Flags[self.Flag] = self.Value
        local pct = (self.Value - self.Min) / (self.Max - self.Min)
        self.ValueLabel.Text = tostring(self.Value)
        
        local util = self.Library.Util
        util:Tween(self.Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
        
        task.spawn(self.Callback, self.Value)
    end
    
    return Slider
    
end

__modules["Button"] = function()
    local Button = {}
    Button.__index = Button
    
    function Button.new(text, callback, groupbox)
        local self = setmetatable({}, Button)
        self.Text = text
        self.Callback = callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        
        local theme = self.Library.Theme
        local util = self.Library.Util
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = theme:GetColor("ElementBackground")
        btn.BorderColor3 = theme:GetColor("Outline")
        btn.Text = self.Text
        btn.TextColor3 = theme:GetColor("Text")
        btn.TextSize = theme:GetFont("SmallSize")
        btn.Font = theme:GetFont("Main")
        btn.AutoButtonColor = false
        btn.Parent = self.Groupbox.Container
        self.Container = btn
        
        btn.MouseEnter:Connect(function()
            util:Tween(btn, {BorderColor3 = theme:GetColor("Accent")}, 0.15)
        end)
        
        btn.MouseLeave:Connect(function()
            util:Tween(btn, {BorderColor3 = theme:GetColor("Outline")}, 0.15)
        end)
        
        btn.MouseButton1Down:Connect(function()
            util:Tween(btn, {BackgroundColor3 = theme:GetColor("Outline")}, 0.1)
        end)
        
        btn.MouseButton1Up:Connect(function()
            util:Tween(btn, {BackgroundColor3 = theme:GetColor("ElementBackground")}, 0.1)
        end)
        
        btn.MouseButton1Click:Connect(function()
            task.spawn(self.Callback)
        end)
        
        return self
    end
    
    return Button
    
end

__modules["Dropdown"] = function()
    local Dropdown = {}
    Dropdown.__index = Dropdown
    
    function Dropdown.new(options, groupbox)
        local self = setmetatable({}, Dropdown)
        self.OptionsTable = options
        self.Text = options.Text
        self.Flag = options.Flag
        self.Options = options.Values or {}
        self.Callback = options.Callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        self.Value = options.Default or self.Options[1] or ""
        self.Open = false
        
        self.Library.Flags[self.Flag] = self.Value
        
        local theme = self.Library.Theme
        local util = self.Library.Util
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 40)
        container.BackgroundTransparency = 1
        container.Parent = self.Groupbox.Container
        self.Container = container
        
        local label = Instance.new("TextLabel")
        label.Text = self.Text
        label.Size = UDim2.new(1, 0, 0, 15)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("TextDark")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.Position = UDim2.new(0, 0, 0, 18)
        btn.BackgroundColor3 = theme:GetColor("ElementBackground")
        btn.BorderColor3 = theme:GetColor("Outline")
        btn.Text = " " .. tostring(self.Value)
        btn.TextColor3 = theme:GetColor("Text")
        btn.TextSize = theme:GetFont("SmallSize")
        btn.Font = theme:GetFont("Main")
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = container
        self.Button = btn
        
        local icon = Instance.new("TextLabel")
        icon.Text = "+"
        icon.Size = UDim2.new(0, 20, 1, 0)
        icon.Position = UDim2.new(1, -20, 0, 0)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = theme:GetColor("TextDark")
        icon.TextSize = 14
        icon.Font = theme:GetFont("Main")
        icon.Parent = btn
        self.Icon = icon
        
        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(0, 100, 0, 100)
        list.BackgroundColor3 = theme:GetColor("ElementBackground")
        list.BorderColor3 = theme:GetColor("Outline")
        list.ScrollBarThickness = 2
        list.ScrollBarImageColor3 = theme:GetColor("Accent")
        list.Visible = false
        list.ZIndex = 101
        list.Parent = self.Library.Window.PopupContainer
        self.List = list
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = list
        
        btn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        
        self:BuildOptions()
        
        return self
    end
    
    function Dropdown:Toggle()
        self.Open = not self.Open
        self.List.Visible = self.Open
        self.Icon.Text = self.Open and "-" or "+"
        
        if self.Open then
            local absPos = self.Button.AbsolutePosition
            local absSize = self.Button.AbsoluteSize
            self.List.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            self.List.Size = UDim2.new(0, absSize.X, 0, math.min(#self.Options * 20, 100))
            self.List.CanvasSize = UDim2.new(0, 0, 0, #self.Options * 20)
        end
    end
    
    function Dropdown:BuildOptions()
        local theme = self.Library.Theme
        
        for _, child in pairs(self.List:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, opt in pairs(self.Options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 20)
            optBtn.BackgroundColor3 = theme:GetColor("ElementBackground")
            optBtn.BorderSizePixel = 0
            optBtn.Text = " " .. tostring(opt)
            optBtn.TextColor3 = (self.Value == opt) and theme:GetColor("Accent") or theme:GetColor("TextDark")
            optBtn.TextSize = theme:GetFont("SmallSize")
            optBtn.Font = theme:GetFont("Main")
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 102
            optBtn.Parent = self.List
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundColor3 = theme:GetColor("Outline")
            end)
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundColor3 = theme:GetColor("ElementBackground")
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                self:SetValue(opt)
                self:Toggle()
            end)
        end
    end
    
    function Dropdown:SetValue(val)
        self.Value = val
        self.Library.Flags[self.Flag] = self.Value
        self.Button.Text = " " .. tostring(val)
        self:BuildOptions()
        task.spawn(self.Callback, self.Value)
    end
    
    return Dropdown
    
end

__modules["ColorPicker"] = function()
    local ColorPicker = {}
    ColorPicker.__index = ColorPicker
    
    function ColorPicker.new(options, groupbox)
        local self = setmetatable({}, ColorPicker)
        self.OptionsTable = options
        self.Text = options.Text
        self.Flag = options.Flag
        self.Color = options.Default or Color3.new(1, 1, 1)
        self.Callback = options.Callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        self.Open = false
        
        self.Library.Flags[self.Flag] = self.Color
        
        local theme = self.Library.Theme
        local util = self.Library.Util
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 15)
        container.BackgroundTransparency = 1
        container.Parent = self.Groupbox.Container
        self.Container = container
        
        local label = Instance.new("TextLabel")
        label.Text = self.Text
        label.Size = UDim2.new(1, -30, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("TextDark")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 20, 0, 10)
        btn.Position = UDim2.new(1, -20, 0.5, -5)
        btn.BackgroundColor3 = self.Color
        btn.BorderColor3 = theme:GetColor("Outline")
        btn.Text = ""
        btn.Parent = container
        self.Button = btn
        
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 150, 0, 110)
        popup.BackgroundColor3 = theme:GetColor("ElementBackground")
        popup.BorderColor3 = theme:GetColor("Outline")
        popup.Visible = false
        popup.ZIndex = 101
        popup.Parent = self.Library.Window.PopupContainer
        self.Popup = popup
        
        local rSlider = self:CreateRGBSlider(popup, "R", 10, self.Color.R)
        local gSlider = self:CreateRGBSlider(popup, "G", 40, self.Color.G)
        local bSlider = self:CreateRGBSlider(popup, "B", 70, self.Color.B)
        
        local function UpdateColor()
            self.Color = Color3.new(rSlider.Value, gSlider.Value, bSlider.Value)
            self.Library.Flags[self.Flag] = self.Color
            self.Button.BackgroundColor3 = self.Color
            task.spawn(self.Callback, self.Color)
        end
        
        rSlider.Callback = UpdateColor
        gSlider.Callback = UpdateColor
        bSlider.Callback = UpdateColor
        
        btn.MouseButton1Click:Connect(function()
            self.Open = not self.Open
            popup.Visible = self.Open
            if self.Open then
                local absPos = btn.AbsolutePosition
                popup.Position = UDim2.new(0, absPos.X - 130, 0, absPos.Y + 15)
            end
        end)
        
        return self
    end
    
    function ColorPicker:CreateRGBSlider(parent, name, yPos, initialVal)
        local theme = self.Library.Theme
        local UserInputService = game:GetService("UserInputService")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 20)
        frame.Position = UDim2.new(0, 5, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.ZIndex = 102
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Text = name
        label.Size = UDim2.new(0, 15, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("Text")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.ZIndex = 102
        label.Parent = frame
        
        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(1, -20, 0, 6)
        bar.Position = UDim2.new(0, 20, 0.5, -3)
        bar.BackgroundColor3 = theme:GetColor("Main")
        bar.BorderColor3 = theme:GetColor("Outline")
        bar.Text = ""
        bar.ZIndex = 102
        bar.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(initialVal, 0, 1, 0)
        fill.BackgroundColor3 = theme:GetColor("Accent")
        fill.BorderSizePixel = 0
        fill.ZIndex = 102
        fill.Parent = bar
        
        local sliderObj = {Value = initialVal, Callback = function() end}
        local dragging = false
        
        bar.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                sliderObj.Value = pct
                sliderObj.Callback()
            end
        end)
        
        return sliderObj
    end
    
    return ColorPicker
    
end

__modules["Keybind"] = function()
    local UserInputService = game:GetService("UserInputService")
    
    local Keybind = {}
    Keybind.__index = Keybind
    
    function Keybind.new(options, groupbox)
        local self = setmetatable({}, Keybind)
        self.OptionsTable = options
        self.Text = options.Text
        self.Flag = options.Flag
        self.Key = options.Default or Enum.KeyCode.Unknown
        self.Callback = options.Callback or function() end
        self.Groupbox = groupbox
        self.Library = groupbox.Library
        self.Binding = false
        
        self.Library.Flags[self.Flag] = self.Key
        
        local theme = self.Library.Theme
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 15)
        container.BackgroundTransparency = 1
        container.Parent = self.Groupbox.Container
        self.Container = container
        
        local label = Instance.new("TextLabel")
        label.Text = self.Text
        label.Size = UDim2.new(1, -50, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("TextDark")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 45, 0, 15)
        btn.Position = UDim2.new(1, -45, 0, 0)
        btn.BackgroundColor3 = theme:GetColor("ElementBackground")
        btn.BorderColor3 = theme:GetColor("Outline")
        btn.Text = self:GetKeyName()
        btn.TextColor3 = theme:GetColor("Text")
        btn.TextSize = theme:GetFont("SmallSize")
        btn.Font = theme:GetFont("Main")
        btn.Parent = container
        self.Button = btn
        
        btn.MouseButton1Click:Connect(function()
            self.Binding = true
            btn.Text = "..."
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if self.Binding then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    self.Key = input.KeyCode
                    self.Library.Flags[self.Flag] = self.Key
                    self.Binding = false
                    btn.Text = self:GetKeyName()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    self.Key = input.UserInputType
                    self.Library.Flags[self.Flag] = self.Key
                    self.Binding = false
                    btn.Text = self:GetKeyName()
                end
            else
                if input.KeyCode == self.Key or input.UserInputType == self.Key then
                    task.spawn(self.Callback)
                end
            end
        end)
        
        return self
    end
    
    function Keybind:GetKeyName()
        if self.Key == Enum.KeyCode.Unknown then return "None" end
        local name = self.Key.Name
        if string.find(name, "MouseButton") then
            return "MB" .. string.sub(name, -1)
        end
        return name
    end
    
    return Keybind
    
end

__modules["Groupbox"] = function()
    local Toggle = __require("Toggle")
    local Slider = __require("Slider")
    local Button = __require("Button")
    local Dropdown = __require("Dropdown")
    local ColorPicker = __require("ColorPicker")
    local Keybind = __require("Keybind")
    
    local Groupbox = {}
    Groupbox.__index = Groupbox
    
    function Groupbox.new(name, tab)
        local self = setmetatable({}, Groupbox)
        self.Name = name
        self.Tab = tab
        self.Library = tab.Library
        self.Elements = {}
        
        local theme = self.Library.Theme
        
        local gb = Instance.new("Frame")
        gb.Size = UDim2.new(1, -10, 0, 20)
        gb.BackgroundColor3 = theme:GetColor("Groupbox")
        gb.BorderColor3 = theme:GetColor("Outline")
        gb.Parent = self.Tab.Content
        self.Container = gb
        
        local title = Instance.new("TextLabel")
        title.Text = " " .. self.Name .. " "
        title.Size = UDim2.new(0, 0, 0, 10)
        title.Position = UDim2.new(0, 10, 0, -5)
        title.AutomaticSize = Enum.AutomaticSize.X
        title.BackgroundColor3 = theme:GetColor("Main")
        title.BorderSizePixel = 0
        title.TextColor3 = theme:GetColor("Text")
        title.TextSize = theme:GetFont("SmallSize")
        title.Font = theme:GetFont("Main")
        title.Parent = gb
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.Parent = gb
        self.Layout = layout
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 12)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = gb
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            gb.Size = UDim2.new(1, -10, 0, layout.AbsoluteContentSize.Y + 22)
            self.Tab.Content.CanvasSize = UDim2.new(0, 0, 0, self.Tab.Layout.AbsoluteContentSize.Y + 10)
        end)
        
        return self
    end
    
    function Groupbox:AddToggle(idx, options)
        options = options or {}
        options.Flag = idx
        options.Text = options.Text or idx
        local toggle = Toggle.new(options, self)
        table.insert(self.Elements, toggle)
        return toggle
    end
    
    function Groupbox:AddSlider(idx, options)
        options = options or {}
        options.Flag = idx
        options.Text = options.Text or idx
        local slider = Slider.new(options, self)
        table.insert(self.Elements, slider)
        return slider
    end
    
    function Groupbox:AddButton(text, callback)
        local button = Button.new(text, callback, self)
        table.insert(self.Elements, button)
        return button
    end
    
    function Groupbox:AddDropdown(idx, options)
        options = options or {}
        options.Flag = idx
        options.Text = options.Text or idx
        local dropdown = Dropdown.new(options, self)
        table.insert(self.Elements, dropdown)
        return dropdown
    end
    
    function Groupbox:AddColorPicker(idx, options)
        options = options or {}
        options.Flag = idx
        options.Text = options.Text or idx
        local picker = ColorPicker.new(options, self)
        table.insert(self.Elements, picker)
        return picker
    end
    
    function Groupbox:AddKeybind(idx, options)
        options = options or {}
        options.Flag = idx
        options.Text = options.Text or idx
        local keybind = Keybind.new(options, self)
        table.insert(self.Elements, keybind)
        return keybind
    end
    
    return Groupbox
    
end

__modules["Tab"] = function()
    local Groupbox = __require("Groupbox")
    
    local Tab = {}
    Tab.__index = Tab
    
    function Tab.new(name, window)
        local self = setmetatable({}, Tab)
        self.Name = name
        self.Window = window
        self.Library = window.Library
        self.Groupboxes = {}
        
        local theme = self.Library.Theme
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = theme:GetColor("TabDark")
        btn.BorderSizePixel = 0
        btn.Text = self.Name
        btn.TextColor3 = theme:GetColor("TextDark")
        btn.TextSize = theme:GetFont("Size")
        btn.Font = theme:GetFont("Main")
        btn.Parent = self.Window.TabContainer
        self.Button = btn
        
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -10)
        content.Position = UDim2.new(0, 5, 0, 5)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 2
        content.ScrollBarImageColor3 = theme:GetColor("Accent")
        content.Visible = false
        content.Parent = self.Window.ContentContainer
        self.Content = content
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.Parent = content
        self.Layout = layout
        
        btn.MouseButton1Click:Connect(function()
            self:Select()
        end)
        
        return self
    end
    
    function Tab:Select()
        local theme = self.Library.Theme
        for _, tab in pairs(self.Window.Tabs) do
            tab.Content.Visible = false
            tab.Button.TextColor3 = theme:GetColor("TextDark")
        end
        self.Content.Visible = true
        self.Button.TextColor3 = theme:GetColor("Accent")
        self.Window.CurrentTab = self
    end
    
    function Tab:CreateGroupbox(name)
        local gb = Groupbox.new(name, self)
        table.insert(self.Groupboxes, gb)
        return gb
    end
    
    return Tab
    
end

__modules["Window"] = function()
    local Tab = __require("Tab")
    
    local Window = {}
    Window.__index = Window
    
    function Window.new(options, library)
        local self = setmetatable({}, Window)
        self.Library = library
        self.Options = options or {}
        self.TitleText = self.Options.Title or "Neverlose-Style Library"
        self.Tabs = {}
        self.CurrentTab = nil
        
        local function GetContainer()
            if gethui then return gethui() end
            local s, cg = pcall(function() return game:GetService("CoreGui") end)
            if s and cg then return cg end
            return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local container = GetContainer()
        
        -- Cleanup previous
        if container:FindFirstChild("NeverloseLibrary") then
            container.NeverloseLibrary:Destroy()
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NeverloseLibrary"
        screenGui.Parent = container
        self.ScreenGui = screenGui
        
        local theme = self.Library.Theme
        
        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Size = self.Options.Size or UDim2.new(0, 550, 0, 380)
        main.Position = self.Options.Position or UDim2.new(0.5, -275, 0.5, -190)
        main.BackgroundColor3 = theme:GetColor("Main")
        main.BorderSizePixel = 1
        main.BorderColor3 = theme:GetColor("Outline")
        main.Parent = screenGui
        main.Active = true
        self.Main = main
        
        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(1, 0, 0, 2)
        accent.BackgroundColor3 = theme:GetColor("Accent")
        accent.BorderSizePixel = 0
        accent.Parent = main
        
        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 25)
        topBar.Position = UDim2.new(0, 0, 0, 2)
        topBar.BackgroundTransparency = 1
        topBar.Parent = main
        
        local title = Instance.new("TextLabel")
        title.Text = "  " .. self.TitleText
        title.Size = UDim2.new(1, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.TextColor3 = theme:GetColor("Text")
        title.TextSize = theme:GetFont("Size")
        title.Font = theme:GetFont("Bold")
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = "TabContainer"
        tabContainer.Size = UDim2.new(0, 120, 1, -27)
        tabContainer.Position = UDim2.new(0, 0, 0, 27)
        tabContainer.BackgroundColor3 = theme:GetColor("TabDark")
        tabContainer.BorderSizePixel = 1
        tabContainer.BorderColor3 = theme:GetColor("Outline")
        tabContainer.Parent = main
        self.TabContainer = tabContainer
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = tabContainer
        
        local contentContainer = Instance.new("Frame")
        contentContainer.Name = "ContentContainer"
        contentContainer.Size = UDim2.new(1, -121, 1, -28)
        contentContainer.Position = UDim2.new(0, 121, 0, 28)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = main
        self.ContentContainer = contentContainer
        
        local popupContainer = Instance.new("Frame")
        popupContainer.Name = "PopupContainer"
        popupContainer.Size = UDim2.new(1, 0, 1, 0)
        popupContainer.BackgroundTransparency = 1
        popupContainer.ZIndex = 100
        popupContainer.Parent = screenGui
        self.PopupContainer = popupContainer
        
        self.Library.Util:MakeDraggable(main, topBar)
        
        return self
    end
    
    function Window:CreateTab(name)
        local tab = Tab.new(name, self)
        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then
            tab:Select()
        end
        return tab
    end
    
    return Window
    
end

__modules["Notification"] = function()
    local TweenService = game:GetService("TweenService")
    
    local NotificationSystem = {
        List = {}
    }
    
    function NotificationSystem:Init(library)
        self.Library = library
        
        local function GetContainer()
            if gethui then return gethui() end
            local s, cg = pcall(function() return game:GetService("CoreGui") end)
            if s and cg then return cg end
            return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local parentContainer = GetContainer()
        
        if parentContainer:FindFirstChild("NeverloseNotifications") then
            parentContainer.NeverloseNotifications:Destroy()
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NeverloseNotifications"
        screenGui.Parent = parentContainer
        
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 300, 1, -20)
        container.Position = UDim2.new(1, -320, 0, 20)
        container.BackgroundTransparency = 1
        container.Parent = screenGui
        self.Container = container
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Parent = container
    end
    
    function NotificationSystem:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local text = options.Content or ""
        local duration = options.Duration or 3
        
        local theme = self.Library.Theme
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.BackgroundColor3 = theme:GetColor("Main")
        frame.BorderColor3 = theme:GetColor("Outline")
        frame.ClipsDescendants = true
        frame.Parent = self.Container
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(1, 0, 0, 2)
        accent.BackgroundColor3 = theme:GetColor("Accent")
        accent.BorderSizePixel = 0
        accent.Parent = frame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = "  " .. title
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.Position = UDim2.new(0, 0, 0, 2)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = theme:GetColor("Text")
        titleLabel.TextSize = theme:GetFont("SmallSize")
        titleLabel.Font = theme:GetFont("Bold")
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame
        
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Text = "  " .. text
        contentLabel.Size = UDim2.new(1, 0, 0, 20)
        contentLabel.Position = UDim2.new(0, 0, 0, 22)
        contentLabel.BackgroundTransparency = 1
        contentLabel.TextColor3 = theme:GetColor("TextDark")
        contentLabel.TextSize = theme:GetFont("SmallSize")
        contentLabel.Font = theme:GetFont("Main")
        contentLabel.TextWrapped = true
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.Parent = frame
        
        local height = 45
        
        local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, height)})
        tweenIn:Play()
        
        task.delay(duration, function()
            local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                frame:Destroy()
            end)
        end)
    end
    
    return NotificationSystem
    
end

__modules["Watermark"] = function()
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    
    local WatermarkSystem = {}
    
    function WatermarkSystem:Init(library)
        self.Library = library
        self.Visible = false
        self.Text = "Neverlose | {fps} fps | {ping} ms"
        
        local theme = self.Library.Theme
        
        local screenGui = self.Library.Window and self.Library.Window.ScreenGui or nil
        if not screenGui then return end
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 0, 0, 20)
        container.Position = UDim2.new(0, 10, 0, 10)
        container.BackgroundColor3 = theme:GetColor("Main")
        container.BorderColor3 = theme:GetColor("Outline")
        container.Visible = false
        container.ZIndex = 1000
        container.Parent = screenGui
        self.Container = container
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(1, 0, 0, 2)
        accent.BackgroundColor3 = theme:GetColor("Accent")
        accent.BorderSizePixel = 0
        accent.ZIndex = 1001
        accent.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Text = " " .. self.Text .. " "
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = theme:GetColor("Text")
        label.TextSize = theme:GetFont("SmallSize")
        label.Font = theme:GetFont("Main")
        label.ZIndex = 1001
        label.Parent = container
        self.Label = label
        
        label:GetPropertyChangedSignal("TextBounds"):Connect(function()
            container.Size = UDim2.new(0, label.TextBounds.X + 10, 0, 20)
        end)
        
        local frames = 0
        local lastUpdate = tick()
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            if tick() - lastUpdate >= 1 then
                local fps = frames
                frames = 0
                lastUpdate = tick()
                
                local ping = "0"
                pcall(function()
                    ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
                end)
                
                if self.Visible then
                    local formatted = string.gsub(self.Text, "{fps}", tostring(fps))
                    formatted = string.gsub(formatted, "{ping}", ping)
                    self.Label.Text = " " .. formatted .. " "
                end
            end
        end)
    end
    
    function WatermarkSystem:SetVisibility(state)
        self.Visible = state
        if self.Container then
            self.Container.Visible = state
        end
    end
    
    function WatermarkSystem:SetText(text)
        self.Text = text
        if self.Label and not string.find(text, "{fps}") then
            self.Label.Text = " " .. text .. " "
        end
    end
    
    return WatermarkSystem
    
end

__modules["SaveManager"] = function()
    local HttpService = game:GetService("HttpService")
    
    local SaveManager = {}
    SaveManager.Folder = "NeverloseConfigs"
    SaveManager.Library = nil
    
    function SaveManager:SetLibrary(library)
        self.Library = library
    end
    
    function SaveManager:SetFolder(folderName)
        self.Folder = folderName
    end
    
    function SaveManager:Save(name)
        local flags = self.Library.Flags
        local saveTable = {}
        
        for key, value in pairs(flags) do
            if typeof(value) == "Color3" then
                saveTable[key] = {Type = "Color3", R = value.R, G = value.G, B = value.B}
            elseif typeof(value) == "EnumItem" then
                saveTable[key] = {Type = "EnumItem", Value = value.Value, Name = value.Name}
            else
                saveTable[key] = value
            end
        end
        
        local json = HttpService:JSONEncode(saveTable)
        
        if writefile then
            if not isfolder(self.Folder) then
                makefolder(self.Folder)
            end
            writefile(self.Folder .. "/" .. name .. ".json", json)
            self.Library:Notify({Title = "Config Saved", Content = "Saved config: " .. name, Duration = 3})
        else
            warn("[SaveManager Fallback] Configuration JSON:\n", json)
            self.Library:Notify({Title = "Config (Studio)", Content = "Saved config to console (writefile unsupported).", Duration = 3})
        end
    end
    
    function SaveManager:Load(name)
        if readfile then
            local path = self.Folder .. "/" .. name .. ".json"
            if isfile(path) then
                local json = readfile(path)
                local success, data = pcall(function() return HttpService:JSONDecode(json) end)
                if success and type(data) == "table" then
                    for key, value in pairs(data) do
                        if type(value) == "table" and value.Type == "Color3" then
                            self.Library.Flags[key] = Color3.new(value.R, value.G, value.B)
                        else
                            self.Library.Flags[key] = value
                        end
                    end
                    self.Library:Notify({Title = "Config Loaded", Content = "Loaded config: " .. name, Duration = 3})
                end
            else
                self.Library:Notify({Title = "Config Error", Content = "Config not found: " .. name, Duration = 3})
            end
        else
            self.Library:Notify({Title = "Config Error", Content = "readfile is unsupported in this environment.", Duration = 3})
        end
    end
    
    return SaveManager
    
end

__modules["init"] = function()
    local ThemeManager = __require("ThemeManager")
    local Utility = __require("Utility")
    
    local Elements = script.Elements
    local Window = __require("Window")
    local Notification = __require("Notification")
    local Watermark = __require("Watermark")
    
    local Library = {
        Theme = ThemeManager,
        Util = Utility,
        Flags = {},
        Unloaded = false
    }
    
    local SaveManager = __require("SaveManager")
    Library.SaveManager = SaveManager
    SaveManager:SetLibrary(Library)
    
    Notification:Init(Library)
    
    function Library:Notify(options)
        Notification:Notify(options)
    end
    
    function Library:SetWatermarkVisibility(state)
        Watermark:SetVisibility(state)
    end
    
    function Library:SetWatermark(text)
        Watermark:SetText(text)
    end
    
    function Library:CreateWindow(options)
        local win = Window.new(options, self)
        self.Window = win
        Watermark:Init(self)
        return win
    end
    
    return Library
    
end

local Library = __require('init')

-- neverlose_demo.lua


local win = Library:CreateWindow({
    Title = "NEVERLOSE v3",
    Size = UDim2.new(0, 600, 0, 450)
})

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Neverlose | {fps} FPS | {ping} ms | user")

local aimbotTab = win:CreateTab("Aimbot")
local visualsTab = win:CreateTab("Visuals")
local movementTab = win:CreateTab("Movement")
local miscTab = win:CreateTab("Misc")

-- ====================
-- AIMBOT TAB
-- ====================
local aimMain = aimbotTab:CreateGroupbox("Main Settings")
aimMain:AddToggle("AimEnabled", { Text = "Enable Aimbot", Default = false })
aimMain:AddKeybind("AimKey", { Text = "Aimbot Key", Default = Enum.UserInputType.MouseButton2 })
aimMain:AddDropdown("AimHitbox", { Text = "Target Hitbox", Values = {"Head", "Torso", "Random"}, Default = "Head" })
aimMain:AddToggle("AimVisCheck", { Text = "Visibility Check", Default = true })

local aimParams = aimbotTab:CreateGroupbox("Parameters")
aimParams:AddSlider("AimFOV", { Text = "FOV Radius", Min = 1, Max = 360, Default = 90 })
aimParams:AddSlider("AimSmooth", { Text = "Smoothness", Min = 1, Max = 100, Default = 50 })

-- ====================
-- VISUALS TAB
-- ====================
local espMain = visualsTab:CreateGroupbox("ESP Settings")
espMain:AddToggle("EspEnabled", { Text = "Enable ESP", Default = false })
espMain:AddToggle("EspBoxes", { Text = "Show Boxes", Default = false })
espMain:AddColorPicker("BoxColor", { Text = "Box Color", Default = Color3.fromRGB(255, 255, 255) })
espMain:AddToggle("EspNames", { Text = "Show Names", Default = false })
espMain:AddToggle("EspHealth", { Text = "Show Health Bar", Default = false })

local espChams = visualsTab:CreateGroupbox("Chams")
espChams:AddToggle("ChamsEnabled", { Text = "Enable Chams", Default = false })
espChams:AddColorPicker("ChamsColor", { Text = "Chams Color", Default = Color3.fromRGB(0, 255, 150) })

-- ====================
-- MOVEMENT TAB
-- ====================
local moveMain = movementTab:CreateGroupbox("Movement Helpers")
moveMain:AddToggle("BunnyHop", { Text = "Auto BunnyHop", Default = false })
moveMain:AddToggle("AutoStrafe", { Text = "Auto Strafe", Default = false })
moveMain:AddSlider("WalkSpeed", { Text = "WalkSpeed Override", Min = 16, Max = 200, Default = 16 })
moveMain:AddSlider("JumpPower", { Text = "JumpPower Override", Min = 50, Max = 300, Default = 50 })

-- ====================
-- MISC TAB
-- ====================
local configGb = miscTab:CreateGroupbox("Configuration")
configGb:AddDropdown("ConfigList", { Text = "Select Config", Values = {"Legit", "Rage", "Semi-Rage"}, Default = "Legit" })
configGb:AddButton("Save Config", function()
    Library.SaveManager:Save(Library.Flags["ConfigList"])
end)
configGb:AddButton("Load Config", function()
    Library.SaveManager:Load(Library.Flags["ConfigList"])
end)

Library:Notify({
    Title = "Neverlose injected",
    Content = "Welcome back! Menu fully initialized.",
    Duration = 5
})


