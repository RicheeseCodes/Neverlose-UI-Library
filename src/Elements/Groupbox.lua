local Toggle = require(script.Parent.Toggle)
local Slider = require(script.Parent.Slider)
local Button = require(script.Parent.Button)
local Dropdown = require(script.Parent.Dropdown)
local ColorPicker = require(script.Parent.ColorPicker)
local Keybind = require(script.Parent.Keybind)

local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox.new(name, tab)
    local self = setmetatable({}, Groupbox)
    self.Name = name
    self.Tab = tab
    self.Library = tab.Library
    self.Elements = {}
    
    local theme = self.Library.Theme
    
    local gb = Instance.new("Frame")
    gb.Size = UDim2.new(1, -10, 0, 20)
    gb.BackgroundColor3 = theme:GetColor("Groupbox")
    gb.BorderColor3 = theme:GetColor("Outline")
    gb.Parent = self.Tab.Content
    self.Container = gb
    
    local title = Instance.new("TextLabel")
    title.Text = " " .. self.Name .. " "
    title.Size = UDim2.new(0, 0, 0, 10)
    title.Position = UDim2.new(0, 10, 0, -5)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.BackgroundColor3 = theme:GetColor("Main")
    title.BorderSizePixel = 0
    title.TextColor3 = theme:GetColor("Text")
    title.TextSize = theme:GetFont("SmallSize")
    title.Font = theme:GetFont("Main")
    title.Parent = gb
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = gb
    self.Layout = layout
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = gb
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gb.Size = UDim2.new(1, -10, 0, layout.AbsoluteContentSize.Y + 22)
        self.Tab.Content.CanvasSize = UDim2.new(0, 0, 0, self.Tab.Layout.AbsoluteContentSize.Y + 10)
    end)
    
    return self
end

function Groupbox:AddToggle(idx, options)
    options = options or {}
    options.Flag = idx
    options.Text = options.Text or idx
    local toggle = Toggle.new(options, self)
    table.insert(self.Elements, toggle)
    return toggle
end

function Groupbox:AddSlider(idx, options)
    options = options or {}
    options.Flag = idx
    options.Text = options.Text or idx
    local slider = Slider.new(options, self)
    table.insert(self.Elements, slider)
    return slider
end

function Groupbox:AddButton(text, callback)
    local button = Button.new(text, callback, self)
    table.insert(self.Elements, button)
    return button
end

function Groupbox:AddDropdown(idx, options)
    options = options or {}
    options.Flag = idx
    options.Text = options.Text or idx
    local dropdown = Dropdown.new(options, self)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Groupbox:AddColorPicker(idx, options)
    options = options or {}
    options.Flag = idx
    options.Text = options.Text or idx
    local picker = ColorPicker.new(options, self)
    table.insert(self.Elements, picker)
    return picker
end

function Groupbox:AddKeybind(idx, options)
    options = options or {}
    options.Flag = idx
    options.Text = options.Text or idx
    local keybind = Keybind.new(options, self)
    table.insert(self.Elements, keybind)
    return keybind
end

return Groupbox
