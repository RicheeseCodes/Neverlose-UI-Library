-- ==========================================
-- MODULAR LIBRARY DEMO
-- ==========================================
local Library = require(script.Parent.src)

local win = Library:CreateWindow({
    Title = "NEVERLOSE MODULAR UI",
    Size = UDim2.new(0, 550, 0, 400)
})

Library:Notify({
    Title = "Welcome",
    Content = "Successfully loaded Neverlose UI demo!",
    Duration = 5
})

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Neverlose UI | {fps} FPS | {ping} ms")

local aimbotTab = win:CreateTab("Aimbot")
local visualsTab = win:CreateTab("Visuals")
local miscTab = win:CreateTab("Misc")

local mainGb = aimbotTab:CreateGroupbox("Main Settings")

mainGb:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(state) 
        print("Aimbot:", state) 
    end
})

mainGb:AddKeybind("AimbotKey", {
    Text = "Aimbot Key",
    Default = Enum.KeyCode.E,
    Callback = function()
        print("Aimbot key pressed!")
    end
})

mainGb:AddDropdown("TargetPart", {
    Text = "Target Part",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(val)
        print("Selected Part:", val)
    end
})

mainGb:AddSlider("AimbotSmoothing", {
    Text = "Smoothing",
    Min = 1,
    Max = 100,
    Default = 50,
    Callback = function(val) 
        print("Smoothing:", val) 
    end
})

local espGb = visualsTab:CreateGroupbox("ESP Settings")

espGb:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = true,
    Callback = function(state) end
})

espGb:AddColorPicker("ESPBoxColor", {
    Text = "Box Color",
    Default = Color3.fromRGB(0, 185, 255),
    Callback = function(color)
        print("Box Color changed:", color)
    end
})

espGb:AddColorPicker("ESPTextColor", {
    Text = "Text Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(color)
        print("Text Color changed:", color)
    end
})

local settingsGb = miscTab:CreateGroupbox("Config")
settingsGb:AddButton("Save Config", function()
    Library.SaveManager:Save("MyDemoConfig")
end)
settingsGb:AddButton("Load Config", function()
    Library.SaveManager:Load("MyDemoConfig")
end)

return Library
