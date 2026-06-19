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
