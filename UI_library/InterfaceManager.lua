-- InterfaceManager.lua
-- Handles interface settings like themes

local InterfaceManager = {}
local HttpService = game:GetService("HttpService")

-- Import Emoji Icons
local EmojiIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Supremechaotic/Key/refs/heads/main/UI_library/EmojiIcons.lua"))()

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
                            -- Update tab button background
                            tab.Button.BackgroundColor3 = tab.Index == self.Library.ActiveTab and 
                                themeData.SecondaryElementColor or 
                                themeData.PrimaryElementColor
                            
                            -- Update tab text
                            local tabText = tab.Button:FindFirstChild("Title")
                            if tabText then
                                tabText.TextColor3 = tab.Index == self.Library.ActiveTab and
                                    themeData.AccentColor or
                                    themeData.PrimaryTextColor
                            end
                            
                            -- Update tab icon if exists
                            local icon = tab.Button:FindFirstChild("Icon")
                            if icon then
                                icon.ImageColor3 = tab.Index == self.Library.ActiveTab and
                                    themeData.AccentColor or
                                    themeData.PrimaryTextColor
                            end
                        end
                        
                        -- Update tab content scrollbar
                        if tab.Content then
                            tab.Content.ScrollBarImageColor3 = themeData.ScrollBarColor
                        end
                    end
                end
            end
            
            -- Update all options
            for _, option in pairs(self.Library.Options) do
                if option.Instance then
                    -- Update container background
                    option.Instance.BackgroundColor3 = option.Type == "Button" and
                        themeData.SecondaryElementColor or
                        themeData.PrimaryElementColor
                    
                    -- Update title text
                    local titleLabel = option.Instance:FindFirstChild("Title")
                    if titleLabel then
                        titleLabel.TextColor3 = themeData.PrimaryTextColor
                    end
                    
                    -- Update description text
                    local descriptionLabel = option.Instance:FindFirstChild("Description")
                    if descriptionLabel then
                        descriptionLabel.TextColor3 = themeData.SecondaryTextColor
                    end
                    
                    -- Update content text for paragraphs
                    local contentLabel = option.Instance:FindFirstChild("Content")
                    if contentLabel then
                        contentLabel.TextColor3 = themeData.SecondaryTextColor
                    end
                    
                    -- Update specific option types
                    if option.Type == "Toggle" then
                        local background = option.Instance:FindFirstChild("Background")
                        if background then
                            background.BackgroundColor3 = option.Value and 
                                themeData.AccentColor or 
                                themeData.OtherElementColor
                            
                            local indicator = background:FindFirstChild("Indicator")
                            if indicator then
                                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            end
                        end
                    elseif option.Type == "Button" then
                        option.Instance.BackgroundColor3 = themeData.SecondaryElementColor
                        
                        local hoverFrame = option.Instance:FindFirstChild("HoverFrame")
                        if hoverFrame then
                            hoverFrame.BackgroundColor3 = themeData.AccentColor
                        end
                    elseif option.Type == "Dropdown" then
                        local button = option.Instance:FindFirstChild("Button")
                        if button then
                            button.BackgroundColor3 = themeData.SecondaryElementColor
                            
                            local text = button:FindFirstChild("Text")
                            if text then
                                text.TextColor3 = themeData.SecondaryTextColor
                            end
                            
                            local arrow = button:FindFirstChild("Arrow")
                            if arrow then
                                arrow.ImageColor3 = themeData.SecondaryTextColor
                            end
                            
                            local hoverFrame = button:FindFirstChild("HoverFrame")
                            if hoverFrame then
                                hoverFrame.BackgroundColor3 = themeData.AccentColor
                            end
                        end
                        
                        local list = option.Instance:FindFirstChild("List")
                        if list then
                            list.BackgroundColor3 = themeData.SecondaryElementColor
                            list.ScrollBarImageColor3 = themeData.ScrollBarColor
                            
                            -- Update list items
                            for _, item in ipairs(list:GetChildren()) do
                                if item:IsA("TextButton") then
                                    item.TextColor3 = themeData.SecondaryTextColor
                                    item.BackgroundColor3 = themeData.SecondaryElementColor
                                    
                                    local hoverFrame = item:FindFirstChild("HoverFrame")
                                    if hoverFrame then
                                        hoverFrame.BackgroundColor3 = themeData.AccentColor
                                    end
                                end
                            end
                        end
                    elseif option.Type == "Slider" then
                        local sliderBar = option.Instance:FindFirstChild("SliderBar")
                        if sliderBar then
                            sliderBar.BackgroundColor3 = themeData.OtherElementColor
                            
                            local sliderFill = sliderBar:FindFirstChild("SliderFill")
                            if sliderFill then
                                sliderFill.BackgroundColor3 = themeData.AccentColor
                            end
                        end
                        
                        local valueLabel = option.Instance:FindFirstChild("Value")
                        if valueLabel then
                            valueLabel.TextColor3 = themeData.SecondaryTextColor
                        end
                    elseif option.Type == "ColorPicker" then
                        local colorDisplay = option.Instance:FindFirstChild("ColorDisplay")
                        if colorDisplay then
                            colorDisplay.BackgroundColor3 = option.Value
                            colorDisplay.BorderColor3 = themeData.OtherElementColor
                        end
                    end
                    
                    -- Update hover frames for all types
                    local hoverFrame = option.Instance:FindFirstChild("HoverFrame")
                    if hoverFrame then
                        hoverFrame.BackgroundColor3 = themeData.AccentColor
                    end
                end
            end
            
            -- Update notification container
            local notificationContainer = mainFrame:FindFirstChild("NotificationContainer")
            if notificationContainer then
                notificationContainer.BackgroundColor3 = themeData.NotificationColor
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
            -- Deep copy the theme data to prevent reference issues
            local newTheme = {}
            if self.Library.Themes[value] then
                for k, v in pairs(self.Library.Themes[value]) do
                    if typeof(v) == "Color3" then
                        newTheme[k] = Color3.new(v.R, v.G, v.B)
                    else
                        newTheme[k] = v
                    end
                end
            elseif self.CustomThemes[value] then
                for k, v in pairs(self.CustomThemes[value]) do
                    if typeof(v) == "Color3" then
                        newTheme[k] = Color3.new(v.R, v.G, v.B)
                    else
                        newTheme[k] = v
                    end
                end
            end
            
            -- Apply the theme
            self:ApplyTheme(newTheme)
            
            -- Force refresh all UI elements
            if self.Library.WindowInstance then
                -- Reapply theme to all existing elements
                for _, tab in pairs(self.Library.Tabs) do
                    if tab.Button then
                        tab.Button.BackgroundColor3 = tab.Index == self.Library.ActiveTab and 
                            newTheme.SecondaryElementColor or 
                            newTheme.PrimaryElementColor
                            
                        local tabText = tab.Button:FindFirstChild("Title")
                        if tabText then
                            tabText.TextColor3 = tab.Index == self.Library.ActiveTab and
                                newTheme.AccentColor or
                                newTheme.PrimaryTextColor
                        end
                    end
                end
                
                -- Update all options
                for _, option in pairs(self.Library.Options) do
                    if option.Instance then
                        option.Instance.BackgroundColor3 = newTheme.PrimaryElementColor
                        
                        local titleLabel = option.Instance:FindFirstChild("Title")
                        if titleLabel then
                            titleLabel.TextColor3 = newTheme.PrimaryTextColor
                        end
                        
                        local descriptionLabel = option.Instance:FindFirstChild("Description")
                        if descriptionLabel then
                            descriptionLabel.TextColor3 = newTheme.SecondaryTextColor
                        end
                        
                        if option.Type == "Toggle" then
                            local background = option.Instance:FindFirstChild("Background")
                            if background then
                                background.BackgroundColor3 = option.Value and 
                                    newTheme.AccentColor or 
                                    newTheme.OtherElementColor
                            end
                        end
                    end
                end
            end
        end
    })
    
    -- Create icon dropdown
    local iconDropdown = CreateInstance("Frame", {
        Name = "IconDropdown",
        Parent = settingsFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 30)
    })

    CreateInstance("TextLabel", {
        Name = "Label",
        Parent = iconDropdown,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Icon",
        TextColor3 = Library.CurrentTheme.PrimaryTextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local iconButton = CreateInstance("TextButton", {
        Name = "Button",
        Parent = iconDropdown,
        BackgroundColor3 = Library.CurrentTheme.SecondaryBackgroundColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Library.CurrentTheme.PrimaryTextColor,
        TextSize = 14
    })

    local iconText = CreateInstance("TextLabel", {
        Name = "Text",
        Parent = iconButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Select Icon",
        TextColor3 = Library.CurrentTheme.PrimaryTextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local iconList = CreateInstance("ScrollingFrame", {
        Name = "List",
        Parent = iconDropdown,
        BackgroundColor3 = Library.CurrentTheme.SecondaryBackgroundColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 0, 0),
        ScrollBarThickness = 4,
        Visible = false
    })

    local iconListLayout = CreateInstance("UIListLayout", {
        Parent = iconList,
        Padding = UDim.new(0, 2)
    })

    -- Populate icon list
    local availableIcons = EmojiIcons:GetAvailableIcons()
    for _, iconName in ipairs(availableIcons) do
        local iconOption = CreateInstance("TextButton", {
            Name = iconName,
            Parent = iconList,
            BackgroundColor3 = Library.CurrentTheme.SecondaryBackgroundColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = EmojiIcons:GetIcon(iconName) .. " " .. iconName,
            TextColor3 = Library.CurrentTheme.PrimaryTextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        iconOption.MouseButton1Click:Connect(function()
            selectedIcon = iconName
            iconText.Text = EmojiIcons:GetIcon(iconName) .. " " .. iconName
            iconList.Visible = false
        end)
        
        iconOption.MouseEnter:Connect(function()
            iconOption.BackgroundColor3 = Library.CurrentTheme.AccentColor
        end)
        
        iconOption.MouseLeave:Connect(function()
            iconOption.BackgroundColor3 = Library.CurrentTheme.SecondaryBackgroundColor
        end)
    end

    iconButton.MouseButton1Click:Connect(function()
        iconList.Visible = not iconList.Visible
        iconList.Size = UDim2.new(1, 0, 0, iconList.Visible and math.min(#availableIcons * 32 + (#availableIcons - 1) * 2, 200) or 0)
    end)
    
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
