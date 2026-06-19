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
