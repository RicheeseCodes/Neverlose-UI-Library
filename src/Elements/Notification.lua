local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local NotificationSystem = {
    List = {}
}

function NotificationSystem:Init(library)
    self.Library = library
    
    if CoreGui:FindFirstChild("NeverloseNotifications") then
        CoreGui.NeverloseNotifications:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeverloseNotifications"
    screenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    
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
