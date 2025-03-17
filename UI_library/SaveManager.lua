-- SaveManager.lua
-- Handles saving and loading configurations

local SaveManager = {}
local HttpService = game:GetService("HttpService")

-- Default settings
SaveManager.Folder = "UILibrary"
SaveManager.Library = nil
SaveManager.IgnoredIndexes = {}

-- Set the library reference
function SaveManager:SetLibrary(library)
    self.Library = library
end

-- Set the folder name for saving configs
function SaveManager:SetFolder(folder)
    self.Folder = folder
    
    -- Create folder if it doesn't exist
    pcall(function()
        if not isfolder(folder) then
            makefolder(folder)
        end
    end)
end

-- Ignore specific indexes when saving
function SaveManager:SetIgnoreIndexes(indexes)
    self.IgnoredIndexes = indexes
end

-- Ignore theme settings
function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({ "CurrentTheme", "ThemeManager" })
end

-- Load configuration
function SaveManager:Load(name)
    local success, result = pcall(function()
        if not name then return end
        
        -- Check if file exists
        local path = self.Folder .. "/" .. name .. ".json"
        if not isfile(path) then
            return false, "File does not exist"
        end
        
        -- Read and parse file
        local configData = HttpService:JSONDecode(readfile(path))
        
        -- Load each option
        for index, value in pairs(configData) do
            -- Skip ignored indexes
            if not table.find(self.IgnoredIndexes, index) then
                local option = self.Library.Options[index]
                
                if option then
                    if option.Type == "Dropdown" then
                        option:SetValue(value)
                    elseif option.Type == "ColorPicker" then
                        option:SetValue(Color3.fromRGB(value.R, value.G, value.B))
                        if option.Transparency ~= nil and value.T ~= nil then
                            option.Transparency = value.T
                        end
                    else
                        option:SetValue(value)
                    end
                end
            end
        end
        
        return true
    end)
    
    return success and result or false
end

-- Save configuration
function SaveManager:Save(name)
    if not name then return end
    
    local configData = {}
    
    -- Save each option
    for index, option in pairs(self.Library.Options) do
        -- Skip ignored indexes
        if not table.find(self.IgnoredIndexes, index) then
            if option.Type == "ColorPicker" then
                -- Save color as RGB values
                configData[index] = {
                    R = math.floor(option.Value.R * 255),
                    G = math.floor(option.Value.G * 255),
                    B = math.floor(option.Value.B * 255)
                }
                
                -- Save transparency if available
                if option.Transparency ~= nil then
                    configData[index].T = option.Transparency
                end
            else
                -- Save value directly
                configData[index] = option.Value
            end
        end
    end
    
    -- Create folder if it doesn't exist
    pcall(function()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end)
    
    -- Write config to file
    writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(configData))
    return true
end

-- Build config section in UI
function SaveManager:BuildConfigSection(tab)
    assert(self.Library, "Library has not been set!")
    
    local section = {}
    
    -- Create config list
    local configList = {}
    
    -- Function to refresh config list
    local function refreshConfigs()
        configList = {}
        
        pcall(function()
            if isfolder(self.Folder) then
                for _, file in pairs(listfiles(self.Folder)) do
                    if file:sub(-5) == ".json" then
                        local configName = file:match("([^\\^/]+)%.json$")
                        if configName then
                            table.insert(configList, configName)
                        end
                    end
                end
            end
        end)
        
        return configList
    end
    
    -- Initial refresh
    refreshConfigs()
    
    -- Config name input
    local configInput = tab:AddInput("ConfigInput", {
        Title = "Configuration",
        Default = "",
        Placeholder = "Config name",
        Callback = function(value) end
    })
    
    -- Config dropdown
    local configDropdown = tab:AddDropdown("ConfigDropdown", {
        Title = "Saved Configs",
        Values = refreshConfigs(),
        Callback = function(value)
            configInput:SetValue(value)
        end
    })
    
    -- Create save button
    tab:AddButton({
        Title = "Save Config",
        Description = "Saves your current settings",
        Callback = function()
            local configName = configInput.Value
            
            if configName:gsub(" ", "") == "" then
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Please enter a config name!",
                    Duration = 5
                })
                return
            end
            
            self:Save(configName)
            
            self.Library:Notify({
                Title = "Save Manager",
                Content = "Configuration saved!",
                Duration = 5
            })
            
            -- Refresh dropdown
            configDropdown:SetValue(refreshConfigs())
        end
    })
    
    -- Create load button
    tab:AddButton({
        Title = "Load Config",
        Description = "Loads selected configuration",
        Callback = function()
            local configName = configInput.Value
            
            if configName:gsub(" ", "") == "" then
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Please enter a config name!",
                    Duration = 5
                })
                return
            end
            
            local success = self:Load(configName)
            
            if success then
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Configuration loaded!",
                    Duration = 5
                })
            else
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Failed to load configuration!",
                    Duration = 5
                })
            end
        end
    })
    
    -- Create delete button
    tab:AddButton({
        Title = "Delete Config",
        Description = "Deletes selected configuration",
        Callback = function()
            local configName = configInput.Value
            
            if configName:gsub(" ", "") == "" then
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Please enter a config name!",
                    Duration = 5
                })
                return
            end
            
            pcall(function()
                if isfile(self.Folder .. "/" .. configName .. ".json") then
                    delfile(self.Folder .. "/" .. configName .. ".json")
                    
                    self.Library:Notify({
                        Title = "Save Manager",
                        Content = "Configuration deleted!",
                        Duration = 5
                    })
                    
                    -- Refresh dropdown
                    configDropdown:SetValue(refreshConfigs())
                else
                    self.Library:Notify({
                        Title = "Save Manager",
                        Content = "Configuration does not exist!",
                        Duration = 5
                    })
                end
            end)
        end
    })
    
    -- Create refresh button
    tab:AddButton({
        Title = "Refresh Configs",
        Description = "Refreshes the config list",
        Callback = function()
            configDropdown:SetValue(refreshConfigs())
            
            self.Library:Notify({
                Title = "Save Manager",
                Content = "Refreshed configuration list!",
                Duration = 5
            })
        end
    })
    
    -- Create autoload toggle
    local autoLoadToggle = tab:AddToggle("AutoLoadConfig", {
        Title = "Auto Load",
        Description = "Automatically loads this config on startup",
        Default = false,
        Callback = function(value)
            if value and configInput.Value:gsub(" ", "") ~= "" then
                -- Save autoload config name
                pcall(function()
                    writefile(self.Folder .. "/autoload.txt", configInput.Value)
                end)
            else
                -- Remove autoload config
                pcall(function()
                    if isfile(self.Folder .. "/autoload.txt") then
                        delfile(self.Folder .. "/autoload.txt")
                    end
                end)
            end
        end
    })
    
    -- Load autoload config
    function self:LoadAutoloadConfig()
        pcall(function()
            if isfile(self.Folder .. "/autoload.txt") then
                local configName = readfile(self.Folder .. "/autoload.txt")
                self:Load(configName)
            end
        end)
    end
    
    return section
end

return SaveManager
