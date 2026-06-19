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
