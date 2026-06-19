import os
import re

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

bundle = []
bundle.append("-- NEVERLOSE UI LIBRARY")
bundle.append("local __modules = {}")
bundle.append("local function __require(name)")
bundle.append("    if type(__modules[name]) == 'function' then")
bundle.append("        __modules[name] = __modules[name]()")
bundle.append("    end")
bundle.append("    return __modules[name]")
bundle.append("end\n")

def add_module(name, path):
    content = read_file(path)
    content = re.sub(r'require\(script\.Parent\.(\w+)\)', r'__require("\1")', content)
    content = re.sub(r'require\(script\.(\w+)\)', r'__require("\1")', content)
    content = re.sub(r'require\(Elements\.(\w+)\)', r'__require("\1")', content)
    
    bundle.append(f'__modules["{name}"] = function()')
    for line in content.split('\n'):
        bundle.append('    ' + line)
    bundle.append("end\n")

add_module("ThemeManager", "src/ThemeManager.lua")
add_module("Utility", "src/Utility.lua")
add_module("Toggle", "src/Elements/Toggle.lua")
add_module("Slider", "src/Elements/Slider.lua")
add_module("Button", "src/Elements/Button.lua")
add_module("Dropdown", "src/Elements/Dropdown.lua")
add_module("ColorPicker", "src/Elements/ColorPicker.lua")
add_module("Keybind", "src/Elements/Keybind.lua")
add_module("Groupbox", "src/Elements/Groupbox.lua")
add_module("Tab", "src/Elements/Tab.lua")
add_module("Window", "src/Elements/Window.lua")
add_module("Notification", "src/Elements/Notification.lua")
add_module("Watermark", "src/Elements/Watermark.lua")
add_module("SaveManager", "src/SaveManager.lua")
add_module("init", "src/init.lua")

bundle.append("return __require('init')")

with open("NeverloseUI.lua", "w") as f:
    f.write('\n'.join(bundle))
print("Library bundled successfully to NeverloseUI.lua!")
