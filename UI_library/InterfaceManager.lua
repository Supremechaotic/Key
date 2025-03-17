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
            themeData = {}
            -- Deep copy the theme data
            for k, v in pairs(self.Library.Themes[theme]) do
                if typeof(v) == "Color3" then
                    themeData[k] = Color3.new(v.R, v.G, v.B)
                else
                    themeData[k] = v
                end
            end
        -- Check custom themes
        elseif self.CustomThemes[theme] then
            themeData = {}
            -- Deep copy the theme data
            for k, v in pairs(self.CustomThemes[theme]) do
                if typeof(v) == "Color3" then
                    themeData[k] = Color3.new(v.R, v.G, v.B)
                else
                    themeData[k] = v
                end
            end
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
    
    -- Update main frame and its children
    if self.Library.WindowInstance then
        local mainFrame = self.Library.WindowInstance.MainFrame
        if mainFrame then
            mainFrame.BackgroundColor3 = themeData.BackgroundColor
            
            -- Update title bar and its children
            local titleBar = mainFrame:FindFirstChild("TitleBar")
            if titleBar then
                titleBar.BackgroundColor3 = themeData.SidebarColor
                
                -- Update title and subtitle
                local title = titleBar:FindFirstChild("Title")
                if title then
                    title.TextColor3 = themeData.PrimaryTextColor
                end
                
                local subtitle = titleBar:FindFirstChild("Subtitle")
                if subtitle then
                    subtitle.TextColor3 = themeData.SecondaryTextColor
                end
                
                -- Update close button
                local closeButton = titleBar:FindFirstChild("CloseButton")
                if closeButton then
                    closeButton.TextColor3 = themeData.PrimaryTextColor
                end
                
                -- Update minimize button
                local minimizeButton = titleBar:FindFirstChild("MinimizeButton")
                if minimizeButton then
                    minimizeButton.TextColor3 = themeData.PrimaryTextColor
                end
            end
            
            -- Update sidebar
            local sidebar = mainFrame:FindFirstChild("Sidebar")
            if sidebar then
                sidebar.BackgroundColor3 = themeData.SidebarColor
                
                -- Update tab container
                local tabContainer = sidebar:FindFirstChild("TabContainer")
                if tabContainer then
                    tabContainer.ScrollBarImageColor3 = themeData.ScrollBarColor
                    
                    -- Update all tab buttons
                    for _, tab in pairs(self.Library.Tabs) do
                        if tab.Button then
                            tab.Button.BackgroundColor3 = tab.Index == self.Library.ActiveTab and 
                                themeData.SecondaryElementColor or 
                                themeData.PrimaryElementColor
                            
                            -- Update tab text
                            local tabText = tab.Button:FindFirstChild("TabText")
                            if tabText then
                                tabText.TextColor3 = themeData.PrimaryTextColor
                            end
                            
                            -- Update tab icon if exists
                            local icon = tab.Button:FindFirstChild("Icon")
                            if icon then
                                icon.ImageColor3 = themeData.PrimaryTextColor
                            end
                        end
                        
                        -- Update tab content
                        if tab.Content then
                            tab.Content.ScrollBarImageColor3 = themeData.ScrollBarColor
                            
                            -- Update all elements in tab content
                            for _, child in pairs(tab.Content:GetDescendants()) do
                                if child:IsA("TextLabel") then
                                    if child.Name == "Title" then
                                        child.TextColor3 = themeData.PrimaryTextColor
                                    elseif child.Name == "Description" or child.Name == "Content" then
                                        child.TextColor3 = themeData.SecondaryTextColor
                                    end
                                elseif child:IsA("TextButton") then
                                    if child.Name == "Button" then
                                        child.BackgroundColor3 = themeData.AccentColor
                                        child.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    end
                                elseif child:IsA("Frame") then
                                    if child.Name == "Background" then
                                        if child.Parent.Name:find("Toggle") then
                                            -- For toggle backgrounds
                                            local isEnabled = child.Parent:FindFirstChild("Indicator") and 
                                                child.Parent.Indicator.Position.X.Scale > 0.1
                                            child.BackgroundColor3 = isEnabled and 
                                                themeData.AccentColor or 
                                                themeData.OtherElementColor
                                        else
                                            child.BackgroundColor3 = themeData.PrimaryElementColor
                                        end
                                    elseif child.Name == "Indicator" then
                                        child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Update content frame
            local contentFrame = mainFrame:FindFirstChild("ContentFrame")
            if contentFrame then
                contentFrame.BackgroundTransparency = 1
                
                -- Update all options
                for _, option in pairs(self.Library.Options) do
                    if option.Instance then
                        option.Instance.BackgroundColor3 = themeData.PrimaryElementColor
                        
                        -- Update specific option types
                        if option.Type == "Toggle" then
                            local background = option.Instance:FindFirstChild("Background")
                            if background then
                                background.BackgroundColor3 = option.Value and 
                                    themeData.AccentColor or 
                                    themeData.OtherElementColor
                            end
                        elseif option.Type == "Button" then
                            local button = option.Instance:FindFirstChild("Button")
                            if button then
                                button.BackgroundColor3 = themeData.AccentColor
                                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end
                        elseif option.Type == "Slider" then
                            local sliderBar = option.Instance:FindFirstChild("SliderBar")
                            if sliderBar then
                                sliderBar.BackgroundColor3 = themeData.OtherElementColor
                                local fill = sliderBar:FindFirstChild("Fill")
                                if fill then
                                    fill.BackgroundColor3 = themeData.AccentColor
                                end
                            end
                        elseif option.Type == "Dropdown" then
                            local button = option.Instance:FindFirstChild("Button")
                            if button then
                                button.BackgroundColor3 = themeData.SecondaryElementColor
                                button.TextColor3 = themeData.SecondaryTextColor
                            end
                        end
                        
                        -- Update text elements
                        for _, descendant in pairs(option.Instance:GetDescendants()) do
                            if descendant:IsA("TextLabel") then
                                if descendant.Name == "Title" then
                                    descendant.TextColor3 = themeData.PrimaryTextColor
                                elseif descendant.Name == "Description" or descendant.Name == "Content" then
                                    descendant.TextColor3 = themeData.SecondaryTextColor
                                end
                            end
                        end
                    end
                end
            end
            
            -- Update notification container
            local notificationContainer = self.Library.WindowInstance.NotificationContainer
            if notificationContainer then
                for _, notification in pairs(notificationContainer:GetChildren()) do
                    if notification:IsA("Frame") then
                        notification.BackgroundColor3 = themeData.NotificationColor
                        
                        -- Update notification text
                        for _, child in pairs(notification:GetDescendants()) do
                            if child:IsA("TextLabel") then
                                if child.Name == "Title" then
                                    child.TextColor3 = themeData.PrimaryTextColor
                                else
                                    child.TextColor3 = themeData.SecondaryTextColor
                                end
                            end
                        end
                    end
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
        Default = self.Library.CurrentTheme == self.Library.Themes.Light and "Light" or "Dark",
        Callback = function(value)
            -- Apply the theme directly using the theme name
            self:ApplyTheme(value)
            
            -- Force refresh all UI elements
            if self.Library.WindowInstance then
                local mainFrame = self.Library.WindowInstance.MainFrame
                if mainFrame then
                    -- Update main frame
                    mainFrame.BackgroundColor3 = self.Library.CurrentTheme.BackgroundColor
                    
                    -- Update title bar
                    local titleBar = mainFrame:FindFirstChild("TitleBar")
                    if titleBar then
                        titleBar.BackgroundColor3 = self.Library.CurrentTheme.SidebarColor
                        
                        -- Update title and subtitle
                        local title = titleBar:FindFirstChild("Title")
                        if title then
                            title.TextColor3 = self.Library.CurrentTheme.PrimaryTextColor
                        end
                        
                        local subtitle = titleBar:FindFirstChild("Subtitle")
                        if subtitle then
                            subtitle.TextColor3 = self.Library.CurrentTheme.SecondaryTextColor
                        end
                        
                        -- Update buttons
                        for _, button in pairs(titleBar:GetChildren()) do
                            if button:IsA("TextButton") then
                                button.TextColor3 = self.Library.CurrentTheme.PrimaryTextColor
                            end
                        end
                    end
                    
                    -- Update sidebar
                    local sidebar = mainFrame:FindFirstChild("Sidebar")
                    if sidebar then
                        sidebar.BackgroundColor3 = self.Library.CurrentTheme.SidebarColor
                        
                        -- Update tab container
                        local tabContainer = sidebar:FindFirstChild("TabContainer")
                        if tabContainer then
                            tabContainer.ScrollBarImageColor3 = self.Library.CurrentTheme.ScrollBarColor
                            
                            -- Update all tab buttons
                            for _, tab in pairs(self.Library.Tabs) do
                                if tab.Button then
                                    tab.Button.BackgroundColor3 = tab.Index == self.Library.ActiveTab and 
                                        self.Library.CurrentTheme.SecondaryElementColor or 
                                        self.Library.CurrentTheme.PrimaryElementColor
                                    
                                    -- Update tab text
                                    local tabText = tab.Button:FindFirstChild("TabText")
                                    if tabText then
                                        tabText.TextColor3 = tab.Index == self.Library.ActiveTab and
                                            self.Library.CurrentTheme.AccentColor or
                                            self.Library.CurrentTheme.PrimaryTextColor
                                    end
                                    
                                    -- Update tab icon if exists
                                    local icon = tab.Button:FindFirstChild("Icon")
                                    if icon then
                                        icon.ImageColor3 = self.Library.CurrentTheme.PrimaryTextColor
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Update content frame
                    local contentFrame = mainFrame:FindFirstChild("ContentFrame")
                    if contentFrame then
                        -- Update all options
                        for _, option in pairs(self.Library.Options) do
                            if option.Instance then
                                option.Instance.BackgroundColor3 = self.Library.CurrentTheme.PrimaryElementColor
                                
                                -- Update text elements
                                for _, descendant in pairs(option.Instance:GetDescendants()) do
                                    if descendant:IsA("TextLabel") then
                                        if descendant.Name == "Title" then
                                            descendant.TextColor3 = self.Library.CurrentTheme.PrimaryTextColor
                                        elseif descendant.Name == "Description" or descendant.Name == "Content" then
                                            descendant.TextColor3 = self.Library.CurrentTheme.SecondaryTextColor
                                        end
                                    elseif descendant:IsA("TextButton") then
                                        if descendant.Name == "Button" then
                                            descendant.BackgroundColor3 = self.Library.CurrentTheme.AccentColor
                                            descendant.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        end
                                    elseif descendant:IsA("Frame") then
                                        if descendant.Name == "Background" then
                                            if descendant.Parent.Name:find("Toggle") then
                                                local isEnabled = descendant.Parent:FindFirstChild("Indicator") and 
                                                    descendant.Parent.Indicator.Position.X.Scale > 0.1
                                                descendant.BackgroundColor3 = isEnabled and 
                                                    self.Library.CurrentTheme.AccentColor or 
                                                    self.Library.CurrentTheme.OtherElementColor
                                            else
                                                descendant.BackgroundColor3 = self.Library.CurrentTheme.PrimaryElementColor
                                            end
                                        elseif descendant.Name == "Indicator" then
                                            descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        end
                                    end
                                end
                                
                                -- Update specific option types
                                if option.Type == "Toggle" then
                                    local background = option.Instance:FindFirstChild("Background")
                                    if background then
                                        background.BackgroundColor3 = option.Value and 
                                            self.Library.CurrentTheme.AccentColor or 
                                            self.Library.CurrentTheme.OtherElementColor
                                    end
                                elseif option.Type == "Button" then
                                    local button = option.Instance:FindFirstChild("Button")
                                    if button then
                                        button.BackgroundColor3 = self.Library.CurrentTheme.AccentColor
                                        button.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    end
                                elseif option.Type == "Slider" then
                                    local sliderBar = option.Instance:FindFirstChild("SliderBar")
                                    if sliderBar then
                                        sliderBar.BackgroundColor3 = self.Library.CurrentTheme.OtherElementColor
                                        local fill = sliderBar:FindFirstChild("Fill")
                                        if fill then
                                            fill.BackgroundColor3 = self.Library.CurrentTheme.AccentColor
                                        end
                                    end
                                elseif option.Type == "Dropdown" then
                                    local button = option.Instance:FindFirstChild("Button")
                                    if button then
                                        button.BackgroundColor3 = self.Library.CurrentTheme.SecondaryElementColor
                                        button.TextColor3 = self.Library.CurrentTheme.SecondaryTextColor
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Update notification container
                    local notificationContainer = self.Library.WindowInstance.NotificationContainer
                    if notificationContainer then
                        for _, notification in pairs(notificationContainer:GetChildren()) do
                            if notification:IsA("Frame") then
                                notification.BackgroundColor3 = self.Library.CurrentTheme.NotificationColor
                                
                                -- Update notification text
                                for _, child in pairs(notification:GetDescendants()) do
                                    if child:IsA("TextLabel") then
                                        if child.Name == "Title" then
                                            child.TextColor3 = self.Library.CurrentTheme.PrimaryTextColor
                                        else
                                            child.TextColor3 = self.Library.CurrentTheme.SecondaryTextColor
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
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
