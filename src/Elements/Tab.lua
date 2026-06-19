local Groupbox = require(script.Parent.Groupbox)

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
