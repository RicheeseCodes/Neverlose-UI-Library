local HttpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "NeverloseConfigs"
SaveManager.Library = nil

function SaveManager:SetLibrary(library)
    self.Library = library
end

function SaveManager:SetFolder(folderName)
    self.Folder = folderName
end

function SaveManager:Save(name)
    local flags = self.Library.Flags
    local saveTable = {}
    
    for key, value in pairs(flags) do
        if typeof(value) == "Color3" then
            saveTable[key] = {Type = "Color3", R = value.R, G = value.G, B = value.B}
        elseif typeof(value) == "EnumItem" then
            saveTable[key] = {Type = "EnumItem", Value = value.Value, Name = value.Name}
        else
            saveTable[key] = value
        end
    end
    
    local json = HttpService:JSONEncode(saveTable)
    
    if writefile then
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
        writefile(self.Folder .. "/" .. name .. ".json", json)
        self.Library:Notify({Title = "Config Saved", Content = "Saved config: " .. name, Duration = 3})
    else
        warn("[SaveManager Fallback] Configuration JSON:\n", json)
        self.Library:Notify({Title = "Config (Studio)", Content = "Saved config to console (writefile unsupported).", Duration = 3})
    end
end

function SaveManager:Load(name)
    if readfile then
        local path = self.Folder .. "/" .. name .. ".json"
        if isfile(path) then
            local json = readfile(path)
            local success, data = pcall(function() return HttpService:JSONDecode(json) end)
            if success and type(data) == "table" then
                for key, value in pairs(data) do
                    if type(value) == "table" and value.Type == "Color3" then
                        self.Library.Flags[key] = Color3.new(value.R, value.G, value.B)
                    else
                        self.Library.Flags[key] = value
                    end
                end
                self.Library:Notify({Title = "Config Loaded", Content = "Loaded config: " .. name, Duration = 3})
            end
        else
            self.Library:Notify({Title = "Config Error", Content = "Config not found: " .. name, Duration = 3})
        end
    else
        self.Library:Notify({Title = "Config Error", Content = "readfile is unsupported in this environment.", Duration = 3})
    end
end

return SaveManager
