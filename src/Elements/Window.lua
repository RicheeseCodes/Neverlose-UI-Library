local CoreGui = game:GetService("CoreGui")
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

function Window.new(options, library)
    local self = setmetatable({}, Window)
    self.Library = library
    self.Options = options or {}
    self.TitleText = self.Options.Title or "Neverlose-Style Library"
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Cleanup previous
    if CoreGui:FindFirstChild("NeverloseLibrary") then
        CoreGui.NeverloseLibrary:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeverloseLibrary"
    screenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
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
