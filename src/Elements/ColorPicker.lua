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
