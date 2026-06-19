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
