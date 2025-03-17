-- InterfaceManager.lua
-- Handles interface settings like themes

local InterfaceManager = {}
local HttpService = game:GetService("HttpService")

-- Default settings
InterfaceManager.Folder = "UILibrary"
InterfaceManager.Library = nil
InterfaceManager.CustomThemes = {}

-- Set the library reference
function InterfaceManager:SetLibrary(library)
    self.Library = library
end

-- Set the folder name for saving themes
function InterfaceManager:SetFolder(folder)
    self.Folder = folder
    
    -- Create folder if it doesn't exist
    pcall(function()
        if not isfolder(folder) then
            makefolder(folder)
        end
        
        if not isfolder(folder .. "/Themes") then
            makefolder(folder .. "/Themes")
        end
    end)
    
    -- Load custom themes
    self:LoadCustomThemes()
end

-- Load custom themes from folder
function InterfaceManager:LoadCustomThemes()
    self.CustomThemes = {}
    
    pcall(function()
        if isfolder(self.Folder .. "/Themes") then
            for _, file in pairs(listfiles(self.Folder .. "/Themes")) do
                if file:sub(-5) == ".json" then
                    local themeName = file:match("([^\\^/]+)%.json$")
                    if themeName then
                        local themeData = HttpService:JSONDecode(readfile(file))
                        self.CustomThemes[themeName] = themeData
                    end
                end
            end
        end
    end)
end

-- Create a new theme
function InterfaceManager:CreateTheme(name, theme)
    if not name or type(theme) ~= "table" then return end
    
    -- Create themes folder if it doesn't exist
    pcall(function()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
        
        if not isfolder(self.Folder .. "/Themes") then
            makefolder(self.Folder .. "/Themes")
        end
    end)
    
    -- Save theme to file
    writefile(self.Folder .. "/Themes/" .. name .. ".json", HttpService:JSONEncode(theme))
    
    -- Add to custom themes
    self.CustomThemes[name] = theme
    
    return theme
end

-- Apply a theme
function InterfaceManager:ApplyTheme(theme)
    if not self.Library then return end
    
    -- Get theme data
    local themeData
    
    if type(theme) == "string" then
        -- Check built-in themes
        if self.Library.Themes[theme] then
            themeData = self.Library.Themes[theme]
        -- Check custom themes
        elseif self.CustomThemes[theme] then
            themeData = self.CustomThemes[theme]
        else
            return
        end
    elseif type(theme) == "table" then
        themeData = theme
    else
        return
    end
    
    -- Apply theme to library
    self.Library.CurrentTheme = themeData
    
    -- Update main frame
    if self.Library.WindowInstance and self.Library.WindowInstance.MainFrame then
        self.Library.WindowInstance.MainFrame.BackgroundColor3 = themeData.BackgroundColor
    end
    
    -- Update title bar
    if self.Library.WindowInstance and self.Library.WindowInstance.TitleBar then
        self.Library.WindowInstance.TitleBar.BackgroundColor3 = themeData.SidebarColor
    end
    
    -- Update sidebar
    if self.Library.WindowInstance and self.Library.WindowInstance.Sidebar then
        self.Library.WindowInstance.Sidebar.BackgroundColor3 = themeData.SidebarColor
    end
    
    -- Update tab container
    if self.Library.WindowInstance and self.Library.WindowInstance.TabContainer then
        self.Library.WindowInstance.TabContainer.ScrollBarImageColor3 = themeData.ScrollBarColor
    end
    
    -- Update all tabs
    for _, tab in pairs(self.Library.Tabs) do
        -- Update tab button
        if tab.Button then
            tab.Button.BackgroundColor3 = tab.Index == self.Library.ActiveTab and 
                themeData.SecondaryElementColor or 
                themeData.PrimaryElementColor
        end
        
        -- Update tab content
        if tab.Content then
            tab.Content.ScrollBarImageColor3 = themeData.ScrollBarColor
        end
    end
    
    -- Update all options
    for _, option in pairs(self.Library.Options) do
        if option.Instance then
            -- Update container background
            option.Instance.BackgroundColor3 = themeData.PrimaryElementColor
            
            -- Update title text
            local titleLabel = option.Instance:FindFirstChild("Title")
            if titleLabel then
                titleLabel.TextColor3 = themeData.PrimaryTextColor
            end
            
            -- Update description text if exists
            local descriptionLabel = option.Instance:FindFirstChild("Description")
            if descriptionLabel then
                descriptionLabel.TextColor3 = themeData.SecondaryTextColor
            end
            
            -- Update specific option types
            if option.Type == "Toggle" then
                local background = option.Instance:FindFirstChild("Background")
                if background then
                    background.BackgroundColor3 = option.Value and 
                        themeData.AccentColor or 
                        themeData.OtherElementColor
                end
            elseif option.Type == "Dropdown" then
                local button = option.Instance:FindFirstChild("Button")
                if button then
                    button.BackgroundColor3 = themeData.SecondaryElementColor
                end
                
                local text = button and button:FindFirstChild("Text")
                if text then
                    text.TextColor3 = themeData.SecondaryTextColor
                end
                
                local arrow = button and button:FindFirstChild("Arrow")
                if arrow then
                    arrow.ImageColor3 = themeData.SecondaryTextColor
                end
                
                local list = option.Instance:FindFirstChild("List")
                if list then
                    list.BackgroundColor3 = themeData.SecondaryElementColor
                end
            elseif option.Type == "ColorPicker" then
                local colorDisplay = option.Instance:FindFirstChild("ColorDisplay")
                if colorDisplay then
                    colorDisplay.BackgroundColor3 = option.Value
                end
            end
        end
    end
    
    return themeData
end

-- Build interface section in UI
function InterfaceManager:BuildInterfaceSection(tab)
    assert(self.Library, "Library has not been set!")
    
    local section = {}
    
    -- Get all themes   
    local themes = {}
    
    -- Add built-in themes
    for name, _ in pairs(self.Library.Themes) do
        table.insert(themes, name)
    end
    
    -- Add custom themes
    for name, _ in pairs(self.CustomThemes) do
        table.insert(themes, name)
    end
    
    -- Theme dropdown
    local themeDropdown = tab:AddDropdown("ThemeManager_ThemeDropdown", {
        Title = "Theme",
        Description = "Changes the UI's theme",
        Values = themes,
        Default = "Dark",
        Callback = function(value)
            self:ApplyTheme(value)
        end
    })
    
    -- Theme name input
    local themeNameInput = tab:AddInput("ThemeManager_ThemeName", {
        Title = "Theme Name",
        Default = "",
        Placeholder = "Custom theme name",
        Callback = function(value) end
    })
    
    -- Create save theme button
    tab:AddButton({
        Title = "Save Theme",
        Description = "Saves current theme settings",
        Callback = function()
            local themeName = themeNameInput.Value
            
            if themeName:gsub(" ", "") == "" then
                self.Library:Notify({
                    Title = "Interface Manager",
                    Content = "Please enter a theme name!",
                    Duration = 5
                })
                return
            end
            
            -- Create new theme from current settings
            local newTheme = {}
            for key, value in pairs(self.Library.CurrentTheme) do
                newTheme[key] = value
            end
            
            -- Save theme
            self:CreateTheme(themeName, newTheme)
            
            self.Library:Notify({
                Title = "Interface Manager",
                Content = "Theme saved!",
                Duration = 5
            })
            
            -- Refresh dropdown
            self:LoadCustomThemes()
            
            -- Update themes list
            local updatedThemes = {}
            for name, _ in pairs(self.Library.Themes) do
                table.insert(updatedThemes, name)
            end
            for name, _ in pairs(self.CustomThemes) do
                table.insert(updatedThemes, name)
            end
            
            themeDropdown:SetValue(updatedThemes)
        end
    })
    
    -- Create delete theme button
    tab:AddButton({
        Title = "Delete Theme",
        Description = "Deletes selected custom theme",
        Callback = function()
            local themeName = themeNameInput.Value
            
            if themeName:gsub(" ", "") == "" then
                self.Library:Notify({
                    Title = "Interface Manager",
                    Content = "Please enter a theme name!",
                    Duration = 5
                })
                return
            end
            
            -- Check if theme exists and is custom
            if not self.CustomThemes[themeName] then
                self.Library:Notify({
                    Title = "Interface Manager",
                    Content = "Theme does not exist or is built-in!",
                    Duration = 5
                })
                return
            end
            
            -- Delete theme file
            pcall(function()
                if isfile(self.Folder .. "/Themes/" .. themeName .. ".json") then
                    delfile(self.Folder .. "/Themes/" .. themeName .. ".json")
                    
                    -- Remove from custom themes
                    self.CustomThemes[themeName] = nil
                    
                    self.Library:Notify({
                        Title = "Interface Manager",
                        Content = "Theme deleted!",
                        Duration = 5
                    })
                    
                    -- Update themes list
                    local updatedThemes = {}
                    for name, _ in pairs(self.Library.Themes) do
                        table.insert(updatedThemes, name)
                    end
                    for name, _ in pairs(self.CustomThemes) do
                        table.insert(updatedThemes, name)
                    end
                    
                    themeDropdown:SetValue(updatedThemes)
                else
                    self.Library:Notify({
                        Title = "Interface Manager",
                        Content = "Theme file does not exist!",
                        Duration = 5
                    })
                end
            end)
        end
    })
    
    return section
end

return InterfaceManager
