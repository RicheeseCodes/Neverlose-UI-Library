local ThemeManager = {
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(0, 185, 255),
        Outline = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(130, 130, 140),
        Groupbox = Color3.fromRGB(18, 18, 24),
        TabDark = Color3.fromRGB(20, 20, 25),
        ElementBackground = Color3.fromRGB(15, 15, 20),
    },
    Font = {
        Main = Enum.Font.Gotham,
        Bold = Enum.Font.GothamBold,
        Size = 12,
        SmallSize = 11
    }
}

function ThemeManager:GetColor(name)
    return self.Theme[name] or Color3.new(1, 1, 1)
end

function ThemeManager:GetFont(name)
    return self.Font[name] or Enum.Font.Gotham
end

return ThemeManager
