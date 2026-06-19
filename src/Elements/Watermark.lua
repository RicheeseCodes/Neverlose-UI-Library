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
