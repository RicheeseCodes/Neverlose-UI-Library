-- neverlose_demo.lua
local Library = require(script.Parent.src)

local win = Library:CreateWindow({
    Title = "NEVERLOSE v3",
    Size = UDim2.new(0, 600, 0, 450)
})

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Neverlose | {fps} FPS | {ping} ms | user")

local aimbotTab = win:CreateTab("Aimbot")
local visualsTab = win:CreateTab("Visuals")
local movementTab = win:CreateTab("Movement")
local miscTab = win:CreateTab("Misc")

-- ====================
-- AIMBOT TAB
-- ====================
local aimMain = aimbotTab:CreateGroupbox("Main Settings")
aimMain:AddToggle("AimEnabled", { Text = "Enable Aimbot", Default = false })
aimMain:AddKeybind("AimKey", { Text = "Aimbot Key", Default = Enum.UserInputType.MouseButton2 })
aimMain:AddDropdown("AimHitbox", { Text = "Target Hitbox", Values = {"Head", "Torso", "Random"}, Default = "Head" })
aimMain:AddToggle("AimVisCheck", { Text = "Visibility Check", Default = true })

local aimParams = aimbotTab:CreateGroupbox("Parameters")
aimParams:AddSlider("AimFOV", { Text = "FOV Radius", Min = 1, Max = 360, Default = 90 })
aimParams:AddSlider("AimSmooth", { Text = "Smoothness", Min = 1, Max = 100, Default = 50 })

-- ====================
-- VISUALS TAB
-- ====================
local espMain = visualsTab:CreateGroupbox("ESP Settings")
espMain:AddToggle("EspEnabled", { Text = "Enable ESP", Default = false })
espMain:AddToggle("EspBoxes", { Text = "Show Boxes", Default = false })
espMain:AddColorPicker("BoxColor", { Text = "Box Color", Default = Color3.fromRGB(255, 255, 255) })
espMain:AddToggle("EspNames", { Text = "Show Names", Default = false })
espMain:AddToggle("EspHealth", { Text = "Show Health Bar", Default = false })

local espChams = visualsTab:CreateGroupbox("Chams")
espChams:AddToggle("ChamsEnabled", { Text = "Enable Chams", Default = false })
espChams:AddColorPicker("ChamsColor", { Text = "Chams Color", Default = Color3.fromRGB(0, 255, 150) })

-- ====================
-- MOVEMENT TAB
-- ====================
local moveMain = movementTab:CreateGroupbox("Movement Helpers")
moveMain:AddToggle("BunnyHop", { Text = "Auto BunnyHop", Default = false })
moveMain:AddToggle("AutoStrafe", { Text = "Auto Strafe", Default = false })
moveMain:AddSlider("WalkSpeed", { Text = "WalkSpeed Override", Min = 16, Max = 200, Default = 16 })
moveMain:AddSlider("JumpPower", { Text = "JumpPower Override", Min = 50, Max = 300, Default = 50 })

-- ====================
-- MISC TAB
-- ====================
local configGb = miscTab:CreateGroupbox("Configuration")
configGb:AddDropdown("ConfigList", { Text = "Select Config", Values = {"Legit", "Rage", "Semi-Rage"}, Default = "Legit" })
configGb:AddButton("Save Config", function()
    Library.SaveManager:Save(Library.Flags["ConfigList"])
end)
configGb:AddButton("Load Config", function()
    Library.SaveManager:Load(Library.Flags["ConfigList"])
end)

Library:Notify({
    Title = "Neverlose injected",
    Content = "Welcome back! Menu fully initialized.",
    Duration = 5
})

return Library
