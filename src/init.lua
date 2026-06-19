local ThemeManager = require(script.ThemeManager)
local Utility = require(script.Utility)

local Elements = script.Elements
local Window = require(Elements.Window)
local Notification = require(Elements.Notification)
local Watermark = require(Elements.Watermark)

local Library = {
    Theme = ThemeManager,
    Util = Utility,
    Flags = {},
    Unloaded = false
}

local SaveManager = require(script.SaveManager)
Library.SaveManager = SaveManager
SaveManager:SetLibrary(Library)

Notification:Init(Library)

function Library:Notify(options)
    Notification:Notify(options)
end

function Library:SetWatermarkVisibility(state)
    Watermark:SetVisibility(state)
end

function Library:SetWatermark(text)
    Watermark:SetText(text)
end

function Library:CreateWindow(options)
    local win = Window.new(options, self)
    self.Window = win
    Watermark:Init(self)
    return win
end

return Library
