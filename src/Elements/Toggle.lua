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
