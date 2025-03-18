-- MainLib.lua
-- A clean UI library for Roblox

local Library = {
    Version = "1.0.0",
    Options = {},
    Unloaded = false,
    Tabs = {},
    TabCount = 0,
    ActiveTab = nil,
    WindowInstance = nil
}

-- Utility functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function ApplyTheme(instance, theme, property)
    if theme and property and instance then
        instance[property] = theme
    end
end

-- Theme configurations
Library.Themes = {
    Dark = {
        BackgroundColor = Color3.fromRGB(28, 28, 30),
        SidebarColor = Color3.fromRGB(30, 30, 32),
        PrimaryTextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(180, 180, 180),
        UIStrokeColor = Color3.fromRGB(45, 45, 47),
        PrimaryElementColor = Color3.fromRGB(35, 35, 37),
        SecondaryElementColor = Color3.fromRGB(40, 40, 42),
        OtherElementColor = Color3.fromRGB(45, 45, 47),
        ScrollBarColor = Color3.fromRGB(40, 40, 42),
        PromptColor = Color3.fromRGB(35, 35, 37),
        NotificationColor = Color3.fromRGB(28, 28, 30),
        AccentColor = Color3.fromRGB(0, 122, 255)
    },
    Light = {
        BackgroundColor = Color3.fromRGB(242, 242, 245),        -- Opposite of 28,28,30
        SidebarColor = Color3.fromRGB(235, 235, 238),          -- Opposite of 30,30,32
        PrimaryTextColor = Color3.fromRGB(0, 0, 0),            -- Opposite of 255,255,255
        SecondaryTextColor = Color3.fromRGB(75, 75, 75),       -- Darker than dark theme's secondary
        UIStrokeColor = Color3.fromRGB(210, 210, 213),         -- Opposite of 45,45,47
        PrimaryElementColor = Color3.fromRGB(220, 220, 223),    -- Opposite of 35,35,37
        SecondaryElementColor = Color3.fromRGB(215, 215, 218),  -- Opposite of 40,40,42
        OtherElementColor = Color3.fromRGB(210, 210, 213),     -- Opposite of 45,45,47
        ScrollBarColor = Color3.fromRGB(215, 215, 218),        -- Opposite of 40,40,42
        PromptColor = Color3.fromRGB(220, 220, 223),           -- Opposite of 35,35,37
        NotificationColor = Color3.fromRGB(242, 242, 245),     -- Opposite of 28,28,30
        AccentColor = Color3.fromRGB(0, 122, 255)              -- Keep same accent for consistency
    }
}

-- Current theme
Library.CurrentTheme = Library.Themes.Dark

-- Create the main window
function Library:CreateWindow(options)
    options = options or {}
    
    -- Default options
    local title = options.Title or "UI Library"
    local subtitle = options.SubTitle or ""
    local tabWidth = options.TabWidth or 160
    local size = options.Size or UDim2.fromOffset(580, 460)
    local acrylic = options.Acrylic == nil and true or options.Acrylic
    local theme = options.Theme or "Dark"
    local minimizeKey = options.MinimizeKey or Enum.KeyCode.LeftControl
    
    -- Set theme
    self.CurrentTheme = {}
    local selectedTheme = self.Themes[theme] or self.Themes.Dark
    -- Deep copy the theme data
    for k, v in pairs(selectedTheme) do
        if typeof(v) == "Color3" then
            self.CurrentTheme[k] = Color3.new(v.R, v.G, v.B)
        else
            self.CurrentTheme[k] = v
        end
    end
    
    -- Create ScreenGui
    local screenGui = CreateInstance("ScreenGui", {
        Name = "LibraryUI",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Create main frame
    local mainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        Size = size,
        ClipsDescendants = true
    })
    
    -- Apply blur if acrylic is enabled
    if acrylic then
        local blur = CreateInstance("BlurEffect", {
            Name = "Acrylic",
            Parent = mainFrame,
            Size = 10
        })
    end
    
    -- Create rounded corners
    local uiCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = mainFrame
    })
    
    -- Create title bar
    local titleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = self.CurrentTheme.SidebarColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })
    
    -- Add corner radius to title bar
    local titleBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = titleBar
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(0.5, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.CurrentTheme.PrimaryTextColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local subtitleLabel = CreateInstance("TextLabel", {
        Name = "Subtitle",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 28),
        Size = UDim2.new(0.5, 0, 0, 15),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = self.CurrentTheme.SecondaryTextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create close button
    local closeButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -45, 0, 0),
        Size = UDim2.new(0, 45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.CurrentTheme.PrimaryTextColor,
        TextSize = 22
    })
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        self.Unloaded = true
    end)
    
    -- Create minimize button
    local minimizeButton = CreateInstance("TextButton", {
        Name = "MinimizeButton",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0, 0),
        Size = UDim2.new(0, 45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = self.CurrentTheme.PrimaryTextColor,
        TextSize = 22
    })
    
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, size.X.Offset, 0, 40), "Out", "Quad", 0.3, true)
        else
            mainFrame:TweenSize(size, "Out", "Quad", 0.3, true)
        end
    end)
    
    -- Create sidebar
    local sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Parent = mainFrame,
        BackgroundColor3 = self.CurrentTheme.SidebarColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, tabWidth, 1, -40)
    })
    
    -- Add corner radius to sidebar
    local sidebarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = sidebar
    })
    
    local tabContainer = CreateInstance("ScrollingFrame", {
        Name = "TabContainer",
        Parent = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10), -- Added 10 pixels padding from top
        Size = UDim2.new(1, 0, 1, -10), -- Adjusted size to account for padding
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.CurrentTheme.ScrollBarColor,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    -- Add padding to tab container
    local tabPadding = CreateInstance("UIPadding", {
        Parent = tabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    local tabListLayout = CreateInstance("UIListLayout", {
        Parent = tabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center  -- Center the tabs horizontally
    })
    
    -- Create content area
    local contentFrame = CreateInstance("Frame", {
        Name = "ContentFrame",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, tabWidth, 0, 40),
        Size = UDim2.new(1, -tabWidth - 10, 1, -40),
        ClipsDescendants = false  -- Changed to false
    })
    
    -- Create notification container
    local notificationContainer = CreateInstance("Frame", {
        Name = "NotificationContainer",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -330, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        ClipsDescendants = false
    })
    
    local notificationListLayout = CreateInstance("UIListLayout", {
        Parent = notificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    -- Store window data
    self.WindowInstance = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TitleBar = titleBar,
        Sidebar = sidebar,
        TabContainer = tabContainer,
        ContentFrame = contentFrame,
        NotificationContainer = notificationContainer
    }
    
    -- Set up minimize keybind
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == minimizeKey then
            minimized = not minimized
            if minimized then
                mainFrame:TweenSize(UDim2.new(0, size.X.Offset, 0, 40), "Out", "Quad", 0.3, true)
            else
                mainFrame:TweenSize(size, "Out", "Quad", 0.3, true)
            end
        end
    end)
    
    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Function to handle dragging
    local function updateDrag(input)
        if dragging and input then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    -- Set up dragging for the title bar only
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Connect to UserInputService for smooth dragging
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
    
    -- Return window object with methods
    local window = {}
    
    -- Add tab method
    function window:AddTab(options)
        options = options or {}
        local tabTitle = options.Title or "Tab"
        local tabIcon = options.Icon or ""
        
        -- Increment tab count
        Library.TabCount = Library.TabCount + 1
        local tabIndex = Library.TabCount
        
        -- Create tab button
        local tabButton = CreateInstance("TextButton", {
            Name = "Tab_" .. tabTitle,
            Parent = tabContainer,
            BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),  -- Fill the full width
            Position = UDim2.new(0, 0, 0, (tabIndex - 1) * 42),
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = Library.CurrentTheme.PrimaryTextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })

        -- Add corner radius to tab button
        local tabCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = tabButton
        })

        -- Create icon if provided
        if tabIcon and tabIcon ~= "" then
            -- Create icon image with debug print
            print("Creating icon with image:", tabIcon)
            
            local iconImage = CreateInstance("ImageLabel", {
                Name = "Icon",
                Parent = tabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0.5, -8),  -- Adjusted X from 10 to 16 for better padding
                Size = UDim2.new(0, 16, 0, 16),
                Image = tabIcon,
                ImageColor3 = Library.CurrentTheme.PrimaryTextColor,
                ZIndex = 3
            })
            
            -- Create text label for the tab name
            local textLabel = CreateInstance("TextLabel", {
                Name = "TabText",
                Parent = tabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 42, 0, 0),  -- Adjusted X from 36 to 42 for better padding
                Size = UDim2.new(1, -46, 1, 0),  -- Adjusted to account for new padding
                Font = Enum.Font.Gotham,
                Text = tabTitle,
                TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
        else
            -- If no icon, just set the button text directly with padding
            tabButton.Text = "      " .. tabTitle  -- Added more padding
            tabButton.TextXAlignment = Enum.TextXAlignment.Left
        end

            
            -- Create tab content frame
            local tabContent = CreateInstance("ScrollingFrame", {
                Name = "Content_" .. tabTitle,
                Parent = contentFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.CurrentTheme.ScrollBarColor,
                Visible = false,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ClipsDescendants = false  -- Changed to false
            })
            
            -- Add padding to tab content
            local contentPadding = CreateInstance("UIPadding", {
                Parent = tabContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            
            -- Add list layout to tab content
            local contentListLayout = CreateInstance("UIListLayout", {
                Parent = tabContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
            
            -- Update canvas size when elements are added
            contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 20)
            end)
            
            -- Tab button click handler
            tabButton.MouseButton1Click:Connect(function()
                -- Hide all tab contents
                for _, tab in pairs(Library.Tabs) do
                    tab.Content.Visible = false
                    tab.Button.BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor
                end
                
                -- Show this tab content
                tabContent.Visible = true
                tabButton.BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor
                Library.ActiveTab = tabIndex
            end)
            
            -- Store tab data
            local tab = {
                Button = tabButton,
                Content = tabContent,
                Index = tabIndex
            }
            
            Library.Tabs[tabIndex] = tab
            
            -- If this is the first tab, select it
            if tabIndex == 1 then
                tabContent.Visible = true
                tabButton.BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor
                Library.ActiveTab = tabIndex
            end
            
            -- Tab methods
            local tabMethods = {}
            
            -- Add paragraph
            function tabMethods:AddParagraph(options)
                options = options or {}
                local title = options.Title or "Paragraph"
                local content = options.Content or ""
                
                -- Create paragraph container
                local paragraphContainer = CreateInstance("Frame", {
                    Name = "Paragraph_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 60) -- Will be adjusted based on content
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = paragraphContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = paragraphContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                
                -- Create content label
                local contentLabel = CreateInstance("TextLabel", {
                    Name = "Content",
                    Parent = paragraphContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = content,
                    TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true
                })
                
                -- Adjust container height based on content
                local textSize = game:GetService("TextService"):GetTextSize(
                    content,
                    14,
                    Enum.Font.Gotham,
                    Vector2.new(paragraphContainer.AbsoluteSize.X - 20, math.huge)
                )
                
                contentLabel.Size = UDim2.new(1, -20, 0, textSize.Y)
                paragraphContainer.Size = UDim2.new(1, 0, 0, textSize.Y + 40)
                
                return paragraphContainer
            end
            
            -- Add button
            function tabMethods:AddButton(options)
                options = options or {}
                local title = options.Title or "Button"
                local description = options.Description or ""
                local callback = options.Callback or function() end
                
                -- Create button container
                local buttonContainer = CreateInstance("Frame", {
                    Name = "Button_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, description ~= "" and 70 or 40)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = buttonContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = buttonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, description ~= "" and 8 or 0),
                    Size = UDim2.new(1, -20, 0, description ~= "" and 20 or 40),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create description label if provided
                if description ~= "" then
                    local descriptionLabel = CreateInstance("TextLabel", {
                        Name = "Description",
                        Parent = buttonContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = description,
                        TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end
                
                -- Create button
                local button = CreateInstance("TextButton", {
                    Name = "Button",
                    Parent = buttonContainer,
                    BackgroundColor3 = Library.CurrentTheme.AccentColor,
                    Position = UDim2.new(1, -100, 0.5, -15),
                    Size = UDim2.new(0, 90, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = "Execute",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                -- Add corner radius to button
                local buttonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = button
                })
                
                -- Button click handler
                button.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                -- Button hover effect
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = Library.CurrentTheme.AccentColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = Library.CurrentTheme.AccentColor
                end)
                
                return buttonContainer
            end
            
            -- Add toggle
            function tabMethods:AddToggle(id, options)
                options = options or {}
                local title = options.Title or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                -- Create toggle container
                local toggleContainer = CreateInstance("Frame", {
                    Name = "Toggle_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = toggleContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = toggleContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create toggle background
                local toggleBackground = CreateInstance("Frame", {
                    Name = "Background",
                    Parent = toggleContainer,
                    BackgroundColor3 = default and Library.CurrentTheme.AccentColor or Library.CurrentTheme.OtherElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                
                -- Add corner radius to toggle background
                local backgroundCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleBackground
                })
                
                -- Create toggle indicator
                local toggleIndicator = CreateInstance("Frame", {
                    Name = "Indicator",
                    Parent = toggleBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(default and 0.5 or 0, default and 0 or 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                
                -- Add corner radius to toggle indicator
                local indicatorCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleIndicator
                })
                
                -- Toggle state
                local enabled = default
                
                -- Toggle click handler
                toggleBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        enabled = not enabled
                        
                        -- Update toggle appearance
                        toggleBackground.BackgroundColor3 = enabled and Library.CurrentTheme.AccentColor or Library.CurrentTheme.OtherElementColor
                        toggleIndicator:TweenPosition(
                            UDim2.new(enabled and 0.5 or 0, enabled and 0 or 2, 0.5, -8),
                            "Out",
                            "Quad",
                            0.2,
                            true
                        )
                        
                        -- Update option value
                        Library.Options[id] = {
                            Value = enabled,
                            Type = "Toggle",
                            ChangedCallback = nil
                        }
                        
                        -- Call callback
                        callback(enabled)
                        
                        -- Call changed callback if exists
                        if Library.Options[id].ChangedCallback then
                            Library.Options[id].ChangedCallback(enabled)
                        end
                    end
                end)
                
                -- Store toggle data
                Library.Options[id] = {
                    Value = enabled,
                    Type = "Toggle",
                    Instance = toggleContainer,
                    SetValue = function(self, value)
                        enabled = value
                        toggleBackground.BackgroundColor3 = enabled and Library.CurrentTheme.AccentColor or Library.CurrentTheme.OtherElementColor
                        toggleIndicator.Position = UDim2.new(enabled and 0.5 or 0, enabled and 0 or 2, 0.5, -8)
                        callback(enabled)
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(enabled)
                        end
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                -- Toggle methods
                local toggleMethods = {}
                
                function toggleMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function toggleMethods:SetValue(value)
                    Library.Options[id]:SetValue(value)
                end
                
                return toggleMethods
            end

            -- Add slider
            function tabMethods:AddSlider(id, options)
                options = options or {}
                local title = options.Title or "Slider"
                local description = options.Description or ""
                local default = options.Default or 50
                local min = options.Min or 0
                local max = options.Max or 100
                local rounding = options.Rounding or 0
                local callback = options.Callback or function() end
                
                -- Create slider container with adjusted height for description
                local sliderContainer = CreateInstance("Frame", {
                    Name = "Slider_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    -- Increase the height when description is provided
                    Size = UDim2.new(1, 0, 0, description ~= "" and 90 or 50)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = sliderContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = sliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create value label
                local valueLabel = CreateInstance("TextLabel", {
                    Name = "Value",
                    Parent = sliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                -- Create description label if provided with adjusted position
                if description ~= "" then
                    local descriptionLabel = CreateInstance("TextLabel", {
                        Name = "Description",
                        Parent = sliderContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 25), -- Position right below the title
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = description,
                        TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end
                
                -- Create slider background with adjusted position
                local sliderBackground = CreateInstance("Frame", {
                    Name = "Background",
                    Parent = sliderContainer,
                    BackgroundColor3 = Library.CurrentTheme.OtherElementColor,
                    BorderSizePixel = 0,
                    -- Move the slider down when description is provided
                    Position = UDim2.new(0, 10, 1, description ~= "" and -40 or -25),
                    Size = UDim2.new(1, -20, 0, 6)
                })
                
                -- Rest of the slider code remains the same...

                
                -- Add corner radius to slider background
                local backgroundCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderBackground
                })
                
                -- Create slider fill
                local sliderFill = CreateInstance("Frame", {
                    Name = "Fill",
                    Parent = sliderBackground,
                    BackgroundColor3 = Library.CurrentTheme.AccentColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                
                -- Add corner radius to slider fill
                local fillCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderFill
                })
                
                -- Create slider knob
                local sliderKnob = CreateInstance("Frame", {
                    Name = "Knob",
                    Parent = sliderFill,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                
                -- Add corner radius to slider knob
                local knobCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderKnob
                })
                
                -- Slider functionality
                local value = default
                local dragging = false
                
                local function updateSlider(input)
                    local sizeX = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                    sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                    
                    value = min + ((max - min) * sizeX)
                    if rounding > 0 then
                        value = math.floor(value * (10 ^ rounding)) / (10 ^ rounding)
                    else
                        value = math.floor(value)
                    end
                    
                    valueLabel.Text = tostring(value)
                    callback(value)
                    
                    -- Call changed callback if exists
                    if Library.Options[id].ChangedCallback then
                        Library.Options[id].ChangedCallback(value)
                    end
                end
                
                sliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                sliderBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                -- Store slider data
                Library.Options[id] = {
                    Value = value,
                    Type = "Slider",
                    Instance = sliderContainer,
                    SetValue = function(self, val)
                        val = math.clamp(val, min, max)
                        if rounding > 0 then
                            val = math.floor(val * (10 ^ rounding)) / (10 ^ rounding)
                        else
                            val = math.floor(val)
                        end
                        
                        value = val
                        valueLabel.Text = tostring(val)
                        sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                        callback(val)
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(val)
                        end
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                -- Slider methods
                local sliderMethods = {}
                
                function sliderMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function sliderMethods:SetValue(val)
                    Library.Options[id]:SetValue(val)
                end
                
                return sliderMethods
            end
            
            -- Add dropdown
            function tabMethods:AddDropdown(id, options)
                options = options or {}
                local title = options.Title or "Dropdown"
                local description = options.Description or ""
                local values = options.Values or {}
                local multi = options.Multi or false
                local default = options.Default or (multi and {} or 1)
                local callback = options.Callback or function() end
                
                -- Calculate total height based on whether description exists
                local containerHeight = (description ~= "" and 80 or 60)
                
                -- Create dropdown container with proper height
                local dropdownContainer = CreateInstance("Frame", {
                    Name = "Dropdown_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, containerHeight)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdownContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = dropdownContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create description label if provided
                if description ~= "" then
                    local descriptionLabel = CreateInstance("TextLabel", {
                        Name = "Description",
                        Parent = dropdownContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = description,
                        TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end
                
                -- Create dropdown button
                local dropdownButton = CreateInstance("TextButton", {
                    Name = "Button",
                    Parent = dropdownContainer,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, description ~= "" and 55 or 35), -- Changed to absolute Y position
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 2 -- Added a base Z-index
                })
                
                -- Add corner radius to dropdown button
                local buttonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = dropdownButton
                })
                
                -- Create dropdown text
                local dropdownText = CreateInstance("TextLabel", {
                    Name = "Text",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = multi and "(Select Items)" or values[default] or "Select...",
                    TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2
                })
                
                -- Create dropdown arrow
                local dropdownArrow = CreateInstance("ImageLabel", {
                    Name = "Arrow",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = Library.CurrentTheme.SecondaryTextColor,
                    ZIndex = 2
                })
                
                -- Create dropdown list
                local dropdownList = CreateInstance("ScrollingFrame", {
                    Name = "List",
                    Parent = Library.WindowInstance.ScreenGui,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, dropdownContainer.AbsoluteSize.X - 20, 0, 0),
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = Library.CurrentTheme.ScrollBarColor,
                    Visible = false,
                    ClipsDescendants = false,  -- Changed to false
                    ZIndex = 999999
                })
                
                -- Add corner radius to list
                local listCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = dropdownList
                })
                
                -- Create list container with higher ZIndex
                local listContainer = CreateInstance("Frame", {
                    Name = "Container",
                    Parent = dropdownList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = false,  -- Changed to false
                    ZIndex = 1000000
                })
                
                -- Add padding to list container
                local listPadding = CreateInstance("UIPadding", {
                    Parent = listContainer,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                })
                
                -- Add list layout to list container
                local listLayout = CreateInstance("UIListLayout", {
                    Parent = listContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5)
                })
                
                -- Dropdown state
                local open = false
                local selected = multi and (type(default) == "table" and default or {}) or (values[default] or nil)

                -- Function to toggle dropdown
                local function toggleDropdown()
                    open = not open
                    
                    if open then
                        -- Calculate position relative to screen, accounting for scroll offset
                        local containerPos = dropdownContainer.AbsolutePosition
                        local containerSize = dropdownContainer.AbsoluteSize
                        local scrollOffset = tabContent.CanvasPosition.Y
                        
                        -- Position the list below the container, adjusting for scroll
                        dropdownList.Position = UDim2.new(0, containerPos.X + 10, 0, containerPos.Y + containerSize.Y - 5 - scrollOffset)
                        dropdownList.Size = UDim2.new(0, containerSize.X - 20, 0, 0)
                        dropdownList.Visible = true
                        dropdownList:TweenSize(
                            UDim2.new(0, containerSize.X - 20, 0, math.min(#values * 25 + 10, 150)),
                            "Out",
                            "Quad",
                            0.2,
                            true
                        )
                        dropdownArrow.Rotation = 180
                    else
                        dropdownList:TweenSize(
                            UDim2.new(0, dropdownList.AbsoluteSize.X, 0, 0),
                            "Out",
                            "Quad",
                            0.2,
                            true,
                            function()
                                dropdownList.Visible = false
                            end
                        )
                        dropdownArrow.Rotation = 0
                    end
                end

                -- Function to update dropdown text
                local function updateText()
                    if multi then
                        local items = {}
                        for item, state in pairs(selected) do
                            if state then
                                table.insert(items, item)
                            end
                        end
                        
                        if #items == 0 then
                            dropdownText.Text = "(None)"
                        else
                            dropdownText.Text = table.concat(items, ", ")
                        end
                    else
                        dropdownText.Text = selected or "Select..."
                    end
                end

                -- Create dropdown items with high ZIndex
                for i, value in ipairs(values) do
                    local item = CreateInstance("TextButton", {
                        Name = "Item_" .. value,
                        Parent = listContainer,
                        BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -10, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = value,
                        TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 1000001
                    })
                    
                    -- Add corner radius to item
                    local itemCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = item
                    })

                    -- Create checkbox for multi-select
                    if multi then
                        local checkbox = CreateInstance("Frame", {
                            Name = "Checkbox",
                            Parent = item,
                            BackgroundColor3 = Library.CurrentTheme.OtherElementColor,
                            BorderSizePixel = 0,
                            Position = UDim2.new(1, -20, 0.5, -7),
                            Size = UDim2.new(0, 14, 0, 14),
                            ZIndex = 1000001
                        })
                        
                        -- Add corner radius to checkbox
                        local checkboxCorner = CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = checkbox
                        })
                        
                        -- Create checkbox indicator
                        local indicator = CreateInstance("Frame", {
                            Name = "Indicator",
                            Parent = checkbox,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Library.CurrentTheme.AccentColor,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0, 0, 0, 0),
                            ZIndex = 1000001
                        })
                        
                        -- Add corner radius to indicator
                        local indicatorCorner = CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = indicator
                        })
                        
                        -- Update checkbox if item is selected
                        if selected[value] then
                            indicator.Size = UDim2.new(1, -4, 1, -4)
                        end
                    end
                    
                    -- Item hover effect
                    item.MouseEnter:Connect(function()
                        item.BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor
                    end)
                    
                    item.MouseLeave:Connect(function()
                        item.BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor
                    end)
                    
                    -- Item click handler
                    item.MouseButton1Click:Connect(function()
                        if multi then
                            selected[value] = not selected[value]
                            
                            -- Update checkbox
                            local checkbox = item:FindFirstChild("Checkbox")
                            if checkbox then
                                local indicator = checkbox:FindFirstChild("Indicator")
                                if indicator then
                                    if selected[value] then
                                        indicator:TweenSize(UDim2.new(1, -4, 1, -4), "Out", "Quad", 0.2, true)
                                    else
                                        indicator:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, true)
                                    end
                                end
                            end
                            
                            updateText()
                        else
                            selected = value
                            updateText()
                            toggleDropdown()
                        end
                        
                        -- Update option value
                        Library.Options[id].Value = selected
                        
                        -- Call callback
                        callback(selected)
                        
                        -- Call changed callback if exists
                        if Library.Options[id].ChangedCallback then
                            Library.Options[id].ChangedCallback(selected)
                        end
                    end)
                end
                
                -- Dropdown state
                local open = false
                local selected = multi and (type(default) == "table" and default or {}) or (values[default] or nil)
                
                -- Dropdown button click handler
                dropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                -- Close dropdown when clicking outside
                game:GetService("UserInputService").InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local dropdownPos = dropdownList.AbsolutePosition
                        local dropdownSize = dropdownList.AbsoluteSize
                        local buttonPos = dropdownButton.AbsolutePosition
                        local buttonSize = dropdownButton.AbsoluteSize
                        
                        -- Check if click is outside both the dropdown list and button
                        if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                               mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) and
                           not (mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                               mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y) then
                            toggleDropdown()
                        end
                    end
                end)
                
                -- Store dropdown data
                Library.Options[id] = {
                    Value = multi and selected or values[default] or nil,
                    Type = "Dropdown",
                    Multi = multi,
                    Instance = dropdownContainer,
                    SetValue = function(self, val)
                        if multi then
                            -- For multi-select, val should be a table of {value = true/false}
                            selected = val
                            
                            -- Update checkboxes
                            for _, item in ipairs(listContainer:GetChildren()) do
                                if item:IsA("TextButton") then
                                    local value = item:FindFirstChild("Text").Text
                                    local checkbox = item:FindFirstChild("Checkbox")
                                    if checkbox then
                                        local indicator = checkbox:FindFirstChild("Indicator")
                                        if indicator then
                                            if selected[value] then
                                                indicator.Size = UDim2.new(1, -4, 1, -4)
                                            else
                                                indicator.Size = UDim2.new(0, 0, 0, 0)
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            -- For single-select, val should be the selected value
                            selected = val
                        end
                        
                        updateText()
                        callback(selected)
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(selected)
                        end
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                -- Initialize dropdown
                updateText()
                
                -- Dropdown methods
                local dropdownMethods = {}
                
                function dropdownMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function dropdownMethods:SetValue(val)
                    Library.Options[id]:SetValue(val)
                end
                
                return dropdownMethods
            end
            
            -- Add colorpicker
            function tabMethods:AddColorpicker(id, options)
                options = options or {}
                local title = options.Title or "Colorpicker"
                local description = options.Description or ""
                local default = options.Default or Color3.fromRGB(255, 255, 255)
                local transparency = options.Transparency or nil
                local callback = options.Callback or function() end
                
                -- Create colorpicker container
                local colorpickerContainer = CreateInstance("Frame", {
                    Name = "Colorpicker_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, description ~= "" and 70 or 50)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorpickerContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = colorpickerContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, description ~= "" and 8 or 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create description label if provided
                if description ~= "" then
                    local descriptionLabel = CreateInstance("TextLabel", {
                        Name = "Description",
                        Parent = colorpickerContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = description,
                        TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end
                
                -- Create color display
                local colorDisplay = CreateInstance("TextButton", {
                    Name = "ColorDisplay",
                    Parent = colorpickerContainer,
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -60, 0, description ~= "" and 10 or 10),
                    Size = UDim2.new(0, 50, 0, 30),
                    Text = "",
                    AutoButtonColor = false
                })
                
                -- Add corner radius to color display
                local displayCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorDisplay
                })
                
                -- Create color picker UI
                local pickerFrame = CreateInstance("Frame", {
                    Name = "PickerFrame",
                    Parent = Library.WindowInstance.ScreenGui,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 250, 0, transparency and 240 or 200),
                    Visible = false,
                    ZIndex = 10
                })
                
                -- Add corner radius to picker frame
                local pickerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = pickerFramexs
                })
                
                -- Create colorß saturation picker
                local saturationPicker = CreateInstance("ImageButton", {
                    Name = "SaturationPicker",
                    Parent = pickerFrame,
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(0, 150, 0, 150),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 11
                })
                
                -- Add corner radius to saturation picker
                local saturationCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = saturationPicker
                })
                
                -- Create saturation picker indicator
                local saturationIndicator = CreateInstance("Frame", {
                    Name = "Indicator",
                    Parent = saturationPicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 6, 0, 6),
                    ZIndex = 12
                })
                
                -- Add corner radius to saturation indicator
                local saturationIndicatorCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = saturationIndicator
                })
                
                -- Create hue picker
                local huePicker = CreateInstance("ImageButton", {
                    Name = "HuePicker",
                    Parent = pickerFrame,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 170, 0, 10),
                    Size = UDim2.new(0, 20, 0, 150),
                    Image = "rbxassetid://3641079629",
                    ZIndex = 11
                })
                
                -- Add corner radius to hue picker
                local hueCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = huePicker
                })
                
                -- Create hue picker indicator
                local hueIndicator = CreateInstance("Frame", {
                    Name = "Indicator",
                    Parent = huePicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 3),
                    ZIndex = 12
                })
                
                -- Add corner radius to hue indicator
                local hueIndicatorCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = hueIndicator
                })
                
                -- Create transparency picker if enabled
                local transparencyPicker
                local transparencyIndicator
                
                if transparency ~= nil then
                    transparencyPicker = CreateInstance("ImageButton", {
                        Name = "TransparencyPicker",
                        Parent = pickerFrame,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 200, 0, 10),
                        Size = UDim2.new(0, 20, 0, 150),
                        Image = "rbxassetid://3887014957",
                        ZIndex = 11
                    })
                    
                    -- Add corner radius to transparency picker
                    local transparencyCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = transparencyPicker
                    })
                    
                    -- Create transparency picker indicator
                    transparencyIndicator = CreateInstance("Frame", {
                        Name = "Indicator",
                        Parent = transparencyPicker,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 3),
                        ZIndex = 12
                    })
                    
                    -- Add corner radius to transparency indicator
                    local transparencyIndicatorCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = transparencyIndicator
                    })
                end
                
                -- Create RGB input fields
                local rgbFrame = CreateInstance("Frame", {
                    Name = "RGBFrame",
                    Parent = pickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 170),
                    Size = UDim2.new(0, 230, 0, 20),
                    ZIndex = 11
                })
                
                local rInput = CreateInstance("TextBox", {
                    Name = "RInput",
                    Parent = rgbFrame,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 50, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "R",
                    Text = tostring(math.floor(default.R * 255)),
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    ZIndex = 11
                })
                
                    local rCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = rInput
                })
                
                local gInput = CreateInstance("TextBox", {
                    Name = "GInput",
                    Parent = rgbFrame,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 60, 0, 0),
                    Size = UDim2.new(0, 50, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "G",
                    Text = tostring(math.floor(default.G * 255)),
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    ZIndex = 11
                })
                
                local gCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = gInput
                })
                
                local bInput = CreateInstance("TextBox", {
                    Name = "BInput",
                    Parent = rgbFrame,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 120, 0, 0),
                    Size = UDim2.new(0, 50, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "B",
                    Text = tostring(math.floor(default.B * 255)),
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    ZIndex = 11
                })
                
                local bCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = bInput
                })
                
                -- Create transparency input if enabled
                local tInput
                
                if transparency ~= nil then
                    tInput = CreateInstance("TextBox", {
                        Name = "TInput",
                        Parent = rgbFrame,
                        BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 180, 0, 0),
                        Size = UDim2.new(0, 50, 1, 0),
                        Font = Enum.Font.Gotham,
                        PlaceholderText = "A",
                        Text = tostring(math.floor((1 - transparency) * 100)) .. "%",
                        TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                        TextSize = 14,
                        ZIndex = 11
                    })
                    
                    local tCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = tInput
                    })
                end
                
                -- Create color picker state
                local color = default
                local hue, sat, val = 0, 0, 1
                local alpha = transparency or 0
                
                -- Function to update color from HSV
                local function updateColor()
                    -- Convert HSV to RGB
                    local h, s, v = hue, sat, val
                    local r, g, b
                    
                    local i = math.floor(h * 6)
                    local f = h * 6 - i
                    local p = v * (1 - s)
                    local q = v * (1 - f * s)
                    local t = v * (1 - (1 - f) * s)
                    
                    i = i % 6
                    
                    if i == 0 then r, g, b = v, t, p
                    elseif i == 1 then r, g, b = q, v, p
                    elseif i == 2 then r, g, b = p, v, t
                    elseif i == 3 then r, g, b = p, q, v
                    elseif i == 4 then r, g, b = t, p, v
                    elseif i == 5 then r, g, b = v, p, q
                    end
                    
                    color = Color3.fromRGB(r * 255, g * 255, b * 255)
                    
                    -- Update color display
                    colorDisplay.BackgroundColor3 = color
                    saturationPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    -- Update RGB inputs
                    rInput.Text = tostring(math.floor(color.R * 255))
                    gInput.Text = tostring(math.floor(color.G * 255))
                    bInput.Text = tostring(math.floor(color.B * 255))
                    
                    if tInput then
                        tInput.Text = tostring(math.floor((1 - alpha) * 100)) .. "%"
                    end
                    
                    -- Call callback
                    callback(color)
                    
                    -- Call changed callback if exists
                    if Library.Options[id].ChangedCallback then
                        Library.Options[id].ChangedCallback(color)
                    end
                    
                    -- Update option value
                    Library.Options[id].Value = color
                    if transparency ~= nil then
                        Library.Options[id].Transparency = alpha
                    end
                end
                
                -- Function to update from RGB inputs
                local function updateFromRGB()
                    local r = tonumber(rInput.Text) or 0
                    local g = tonumber(gInput.Text) or 0
                    local b = tonumber(bInput.Text) or 0
                    
                    r = math.clamp(r, 0, 255) / 255
                    g = math.clamp(g, 0, 255) / 255
                    b = math.clamp(b, 0, 255) / 255
                    
                    color = Color3.new(r, g, b)
                    
                    -- Convert RGB to HSV
                    local max, min = math.max(r, g, b), math.min(r, g, b)
                    hue, sat, val = 0, 0, max
                    
                    if max ~= min then
                        local d = max - min
                        sat = d / max
                        
                        if max == r then
                            hue = (g - b) / d + (g < b and 6 or 0)
                        elseif max == g then
                            hue = (b - r) / d + 2
                        else
                            hue = (r - g) / d + 4
                        end
                        
                        hue = hue / 6
                    end
                    
                    -- Update saturation picker background
                    saturationPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    -- Update indicators
                    saturationIndicator.Position = UDim2.new(sat, -3, 1 - val, -3)
                    hueIndicator.Position = UDim2.new(0, 0, hue, -1.5)
                    
                    -- Update color display
                    colorDisplay.BackgroundColor3 = color
                    
                    -- Call callback
                    callback(color)
                    
                    -- Call changed callback if exists
                    if Library.Options[id].ChangedCallback then
                        Library.Options[id].ChangedCallback(color)
                    end
                    
                    -- Update option value
                    Library.Options[id].Value = color
                end
                
                -- Function to update from transparency input
                local function updateFromTransparency()
                    if not tInput then return end
                    
                    local t = tonumber(string.match(tInput.Text, "%d+")) or 0
                    t = math.clamp(t, 0, 100)
                    alpha = 1 - (t / 100)
                    
                    -- Update transparency indicator
                    if transparencyIndicator then
                        transparencyIndicator.Position = UDim2.new(0, 0, alpha, -1.5)
                    end
                    
                    -- Call callback
                    callback(color)
                    
                    -- Call changed callback if exists
                    if Library.Options[id].ChangedCallback then
                        Library.Options[id].ChangedCallback(color)
                    end
                    
                    -- Update option value
                    if transparency ~= nil then
                        Library.Options[id].Transparency = alpha
                    end
                end
                
                -- Initialize color picker
                local function initColorPicker()
                    -- Convert RGB to HSV
                    local r, g, b = color.R, color.G, color.B
                    local max, min = math.max(r, g, b), math.min(r, g, b)
                    hue, sat, val = 0, 0, max
                    
                    if max ~= min then
                        local d = max - min
                        sat = d / max
                        
                        if max == r then
                            hue = (g - b) / d + (g < b and 6 or 0)
                        elseif max == g then
                            hue = (b - r) / d + 2
                        else
                            hue = (r - g) / d + 4
                        end
                        
                        hue = hue / 6
                    end
                    
                    -- Update saturation picker background
                    saturationPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    -- Update indicators
                    saturationIndicator.Position = UDim2.new(sat, -3, 1 - val, -3)
                    hueIndicator.Position = UDim2.new(0, 0, hue, -1.5)
                    
                    if transparencyIndicator then
                        transparencyIndicator.Position = UDim2.new(0, 0, alpha, -1.5)
                    end
                end
                
                -- Initialize color picker
                initColorPicker()
                
                -- Saturation picker functionality
                local saturationDragging = false
                
                saturationPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        saturationDragging = true
                        
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local framePos = saturationPicker.AbsolutePosition
                        local frameSize = saturationPicker.AbsoluteSize
                        
                        local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                        local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                        
                        sat = relativeX
                        val = 1 - relativeY
                        
                        saturationIndicator.Position = UDim2.new(relativeX, -3, relativeY, -3)
                        
                        updateColor()
                    end
                end)
                
                saturationPicker.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        saturationDragging = false
                    end
                end)
                
                -- Hue picker functionality
                local hueDragging = false
                
                huePicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local framePos = huePicker.AbsolutePosition
                        local frameSize = huePicker.AbsoluteSize
                        
                        local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                        
                        hue = relativeY
                        hueIndicator.Position = UDim2.new(0, 0, relativeY, -1.5)
                        
                        updateColor()
                    end
                end)
                
                huePicker.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                -- Transparency picker functionality
                local transparencyDragging = false
                
                if transparencyPicker then
                    transparencyPicker.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            transparencyDragging = true
                            
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local framePos = transparencyPicker.AbsolutePosition
                            local frameSize = transparencyPicker.AbsoluteSize
                            
                            local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                            
                            alpha = relativeY
                            transparencyIndicator.Position = UDim2.new(0, 0, relativeY, -1.5)
                            
                            updateColor()
                        end
                    end)
                    
                    transparencyPicker.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            transparencyDragging = false
                        end
                    end)
                end
                
                -- Mouse movement handler
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if saturationDragging then
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local framePos = saturationPicker.AbsolutePosition
                            local frameSize = saturationPicker.AbsoluteSize
                            
                            local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                            local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                            
                            sat = relativeX
                            val = 1 - relativeY
                            
                            saturationIndicator.Position = UDim2.new(relativeX, -3, relativeY, -3)
                            
                            updateColor()
                        elseif hueDragging then
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local framePos = huePicker.AbsolutePosition
                            local frameSize = huePicker.AbsoluteSize
                            
                            local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                            
                            hue = relativeY
                            hueIndicator.Position = UDim2.new(0, 0, relativeY, -1.5)
                            
                            updateColor()
                        elseif transparencyDragging then
                            if transparencyPicker then
                                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                                local framePos = transparencyPicker.AbsolutePosition
                                local frameSize = transparencyPicker.AbsoluteSize
                                
                                local relativeY = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
                                
                                alpha = relativeY
                                transparencyIndicator.Position = UDim2.new(0, 0, relativeY, -1.5)
                                
                                updateColor()
                            end
                        end
                    end
                end)
                
                -- RGB input handlers
                rInput.FocusLost:Connect(function()
                    updateFromRGB()
                end)
                
                gInput.FocusLost:Connect(function()
                    updateFromRGB()
                end)
                
                bInput.FocusLost:Connect(function()
                    updateFromRGB()
                end)
                
                -- Transparency input handler
                if tInput then
                    tInput.FocusLost:Connect(function()
                        updateFromTransparency()
                    end)
                end
                
                -- Toggle color picker
                local pickerOpen = false
                
                colorDisplay.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    
                    if pickerOpen then
                        -- Position picker near the color display
                        local displayPos = colorDisplay.AbsolutePosition
                        local displaySize = colorDisplay.AbsoluteSize
                        
                        pickerFrame.Position = UDim2.new(
                            0, 
                            math.clamp(displayPos.X + displaySize.X + 10, 0, game:GetService("Workspace").CurrentCamera.ViewportSize.X - pickerFrame.AbsoluteSize.X),
                            0,
                            math.clamp(displayPos.Y, 0, game:GetService("Workspace").CurrentCamera.ViewportSize.Y - pickerFrame.AbsoluteSize.Y)
                        )
                        
                        pickerFrame.Visible = true
                    else
                        pickerFrame.Visible = false
                    end
                end)
                
                -- Close picker when clicking outside
                game:GetService("UserInputService").InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen then
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local pickerPos = pickerFrame.AbsolutePosition
                        local pickerSize = pickerFrame.AbsoluteSize
                        
                        if mousePos.X < pickerPos.X or mousePos.X > pickerPos.X + pickerSize.X or
                           mousePos.Y < pickerPos.Y or mousePos.Y > pickerPos.Y + pickerSize.Y then
                            if not (mousePos.X >= colorDisplay.AbsolutePosition.X and
                                    mousePos.X <= colorDisplay.AbsolutePosition.X + colorDisplay.AbsoluteSize.X and
                                    mousePos.Y >= colorDisplay.AbsolutePosition.Y and
                                    mousePos.Y <= colorDisplay.AbsolutePosition.Y + colorDisplay.AbsoluteSize.Y) then
                                pickerOpen = false
                                pickerFrame.Visible = false
                            end
                        end
                    end
                end)
                
                -- Store colorpicker data
                Library.Options[id] = {
                    Value = color,
                    Type = "ColorPicker",
                    Instance = colorpickerContainer,
                    SetValue = function(self, col)
                        color = col
                        colorDisplay.BackgroundColor3 = color
                        
                        -- Convert RGB to HSV
                        local r, g, b = color.R, color.G, color.B
                        local max, min = math.max(r, g, b), math.min(r, g, b)
                        hue, sat, val = 0, 0, max
                        
                        if max ~= min then
                            local d = max - min
                            sat = d / max
                            
                            if max == r then
                                hue = (g - b) / d + (g < b and 6 or 0)
                            elseif max == g then
                                hue = (b - r) / d + 2
                            else
                                hue = (r - g) / d + 4
                            end
                            
                            hue = hue / 6
                        end
                        
                        -- Update RGB inputs
                        rInput.Text = tostring(math.floor(color.R * 255))
                        gInput.Text = tostring(math.floor(color.G * 255))
                        bInput.Text = tostring(math.floor(color.B * 255))
                        
                        -- Update saturation picker background
                        saturationPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        
                        -- Update indicators
                        saturationIndicator.Position = UDim2.new(sat, -3, 1 - val, -3)
                        hueIndicator.Position = UDim2.new(0, 0, hue, -1.5)
                        
                        callback(color)
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(color)
                        end
                    end,
                    SetValueRGB = function(self, r, g, b)
                        self:SetValue(Color3.fromRGB(r, g, b))
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                if transparency ~= nil then
                    Library.Options[id].Transparency = alpha
                end
                
                -- Colorpicker methods
                local colorpickerMethods = {}
                
                function colorpickerMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function colorpickerMethods:SetValue(col)
                    Library.Options[id]:SetValue(col)
                end
                
                function colorpickerMethods:SetValueRGB(r, g, b)
                    Library.Options[id]:SetValueRGB(r, g, b)
                end
                
                return colorpickerMethods
            end
            
            -- Add keybind
            function tabMethods:AddKeybind(id, options)
                options = options or {}
                local title = options.Title or "Keybind"
                local default = options.Default or "None"
                local mode = options.Mode or "Toggle" -- Toggle, Hold, Always
                local callback = options.Callback or function() end
                local changedCallback = options.ChangedCallback or function() end
                
                -- Create keybind container
                local keybindContainer = CreateInstance("Frame", {
                    Name = "Keybind_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = keybindContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = keybindContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -120, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create keybind button
                local keybindButton = CreateInstance("TextButton", {
                    Name = "KeybindButton",
                    Parent = keybindContainer,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -110, 0.5, -15),
                    Size = UDim2.new(0, 100, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                -- Add corner radius to keybind button
                local buttonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybindButton
                })
                
                -- Keybind state
                local currentKey = default
                local keyPressed = false
                local listening = false
                local keyReleased = true
                
                -- Convert string key to enum
                local function stringToEnum(str)
                    if str == "MB1" then
                        return Enum.UserInputType.MouseButton1
                    elseif str == "MB2" then
                        return Enum.UserInputType.MouseButton2
                    else
                        for _, enum in pairs(Enum.KeyCode:GetEnumItems()) do
                            if enum.Name == str then
                                return enum
                            end
                        end
                    end
                    return nil
                end
                
                -- Convert enum to string
                local function enumToString(enum)
                    if enum == Enum.UserInputType.MouseButton1 then
                        return "MB1"
                    elseif enum == Enum.UserInputType.MouseButton2 then
                        return "MB2"
                    else
                        return enum.Name
                    end
                end
                
                -- Update keybind text
                local function updateKeybind()
                    keybindButton.Text = currentKey
                end
                
                -- Keybind button click handler
                keybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    keybindButton.Text = "..."
                    keybindButton.TextColor3 = Library.CurrentTheme.AccentColor
                end)
                
                -- Input handlers
                game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed then
                        -- Get key string
                        local keyString
                        
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keyString = input.KeyCode.Name
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            keyString = "MB1"
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            keyString = "MB2"
                        end
                        
                        if keyString then
                            currentKey = keyString
                            updateKeybind()
                            listening = false
                            keybindButton.TextColor3 = Library.CurrentTheme.SecondaryTextColor
                            
                            -- Call changed callback
                            changedCallback(stringToEnum(currentKey))
                            
                            -- Update option value
                            Library.Options[id].Value = currentKey
                            
                            -- Call changed callback if exists
                            if Library.Options[id].ChangedCallback then
                                Library.Options[id].ChangedCallback(currentKey)
                            end
                        end
                    elseif not gameProcessed and not listening then
                        local keyEnum = stringToEnum(currentKey)
                        
                        if keyEnum and ((input.KeyCode == keyEnum) or (input.UserInputType == keyEnum)) then
                            keyPressed = true
                            keyReleased = false
                            
                            if mode == "Toggle" then
                                callback(true)
                                
                                -- Call click callback if exists
                                if Library.Options[id].ClickCallback then
                                    Library.Options[id].ClickCallback()
                                end
                            elseif mode == "Hold" then
                                -- Start hold loop
                                spawn(function()
                                    while keyPressed do
                                        callback(true)
                                        wait()
                                    end
                                    callback(false)
                                end)
                            end
                        end
                    end
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                    if not gameProcessed then
                        local keyEnum = stringToEnum(currentKey)
                        
                        if keyEnum and ((input.KeyCode == keyEnum) or (input.UserInputType == keyEnum)) then
                            keyPressed = false
                            keyReleased = true
                            
                            if mode == "Toggle" then
                                callback(false)
                            end
                        end
                    end
                end)
                
                -- Store keybind data
                Library.Options[id] = {
                    Value = currentKey,
                    Type = "Keybind",
                    Mode = mode,
                    Instance = keybindContainer,
                    SetValue = function(self, key, newMode)
                        currentKey = key
                        if newMode then
                            mode = newMode
                        end
                        updateKeybind()
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(currentKey)
                        end
                    end,
                    GetState = function()
                        if mode == "Always" then
                            return true
                        elseif mode == "Hold" then
                            return keyPressed
                        elseif mode == "Toggle" then
                            return keyPressed
                        end
                        return false
                    end,
                    OnClick = function(self, func)
                        self.ClickCallback = func
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                -- Keybind methods
                local keybindMethods = {}
                
                function keybindMethods:OnClick(func)
                    Library.Options[id].ClickCallback = func
                end
                
                function keybindMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function keybindMethods:SetValue(key, newMode)
                    Library.Options[id]:SetValue(key, newMode)
                end
                
                function keybindMethods:GetState()
                    return Library.Options[id]:GetState()
                end
                
                return keybindMethods
            end
            
            -- Add input field
            function tabMethods:AddInput(id, options)
                options = options or {}
                local title = options.Title or "Input"
                local default = options.Default or ""
                local placeholder = options.Placeholder or ""
                local numeric = options.Numeric or false
                local finished = options.Finished or false
                local callback = options.Callback or function() end
                
                -- Create input container
                local inputContainer = CreateInstance("Frame", {
                    Name = "Input_" .. title,
                    Parent = tabContent,
                    BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                -- Add corner radius
                local containerCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = inputContainer
                })
                
                -- Create title label
                local titleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = inputContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, -10, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Create input field
                local inputField = CreateInstance("TextBox", {
                    Name = "InputField",
                    Parent = inputContainer,
                    BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, -15),
                    Size = UDim2.new(0.5, -10, 0, 30),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    Text = default,
                    TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    ClearTextOnFocus = false
                })
                
                -- Add corner radius to input field
                local fieldCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = inputField
                })
                
                -- Input state
                local value = default
                
                -- Input field handlers
                inputField.FocusLost:Connect(function(enterPressed)
                    if numeric then
                        local num = tonumber(inputField.Text)
                        if num then
                            value = num
                            inputField.Text = tostring(num)
                        else
                            inputField.Text = tostring(value)
                        end
                    else
                        value = inputField.Text
                    end
                    
                    -- Update option value
                    Library.Options[id].Value = value
                    
                    -- Call callback if finished is false or enter was pressed
                    if not finished or enterPressed then
                        callback(value)
                        
                        -- Call changed callback if exists
                        if Library.Options[id].ChangedCallback then
                            Library.Options[id].ChangedCallback(value)
                        end
                    end
                end)
                
                if not finished then
                    inputField:GetPropertyChangedSignal("Text"):Connect(function()
                        if numeric then
                            local num = tonumber(inputField.Text)
                            if num then
                                value = num
                            end
                        else
                            value = inputField.Text
                        end
                        
                        -- Update option value
                        Library.Options[id].Value = value
                        
                        -- Call changed callback if exists
                        if Library.Options[id].ChangedCallback then
                            Library.Options[id].ChangedCallback(value)
                        end
                    end)
                end
                
                -- Store input data
                Library.Options[id] = {
                    Value = value,
                    Type = "Input",
                    Instance = inputContainer,
                    SetValue = function(self, val)
                        value = val
                        inputField.Text = tostring(val)
                        
                        callback(value)
                        
                        if self.ChangedCallback then
                            self.ChangedCallback(value)
                        end
                    end,
                    OnChanged = function(self, func)
                        self.ChangedCallback = func
                    end
                }
                
                -- Input methods
                local inputMethods = {}
                
                function inputMethods:OnChanged(func)
                    Library.Options[id].ChangedCallback = func
                end
                
                function inputMethods:SetValue(val)
                    Library.Options[id]:SetValue(val)
                end
                
                return inputMethods
            end
            
            -- Update dropdown list position when scrolling
            tabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if open then
                    local containerPos = dropdownContainer.AbsolutePosition
                    local containerSize = dropdownContainer.AbsoluteSize
                    local scrollOffset = tabContent.CanvasPosition.Y
                    
                    dropdownList.Position = UDim2.new(0, containerPos.X + 10, 0, containerPos.Y + containerSize.Y - 5 - scrollOffset)
                end
            end)
            
            -- Dropdown button click handler
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            return tabMethods
        end
        
        -- Select tab by index
        function window:SelectTab(index)
            for _, tab in pairs(Library.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor
            end
            
            if Library.Tabs[index] then
                Library.Tabs[index].Content.Visible = true
                Library.Tabs[index].Button.BackgroundColor3 = Library.CurrentTheme.SecondaryElementColor
                Library.ActiveTab = index
            end
        end
        
        -- Create dialog
        function window:Dialog(options)
            options = options or {}
            local title = options.Title or "Dialog"
            local content = options.Content or ""
            local buttons = options.Buttons or {}
            
            -- Create dialog background
            local dialogBackground = CreateInstance("Frame", {
                Name = "DialogBackground",
                Parent = Library.WindowInstance.ScreenGui,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 100
            })
            
            -- Create dialog frame
            local dialogFrame = CreateInstance("Frame", {
                Name = "DialogFrame",
                Parent = dialogBackground,
                BackgroundColor3 = Library.CurrentTheme.PrimaryElementColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, -150, 0.5, -100),
                Size = UDim2.new(0, 300, 0, 200),
                ZIndex = 101
            })
            
            -- Add corner radius to dialog frame
            local frameCorner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dialogFrame
            })
            
            -- Create title label
            local titleLabel = CreateInstance("TextLabel", {
                Name = "Title",
                Parent = dialogFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = Library.CurrentTheme.PrimaryTextColor,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 102
            })
            
            -- Create content label
            local contentLabel = CreateInstance("TextLabel", {
                Name = "Content",
                Parent = dialogFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 50),
                Size = UDim2.new(1, -20, 0, 80),
                Font = Enum.Font.Gotham,
                Text = content,
                TextColor3 = Library.CurrentTheme.SecondaryTextColor,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 102
            })
            
            -- Create buttons
            local buttonCount = #buttons
            local buttonWidth = (280 - (10 * (buttonCount - 1))) / buttonCount
            
            for i, buttonInfo in ipairs(buttons) do
                local button = CreateInstance("TextButton", {
                    Name = "Button_" .. (buttonInfo.Title or "Button"),
                    Parent = dialogFrame,
                    BackgroundColor3 = i == 1 and Library.CurrentTheme.AccentColor or Library.CurrentTheme.SecondaryElementColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10 + (i - 1) * (buttonWidth + 10), 0, 150),
                    Size = UDim2.new(0, buttonWidth, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = buttonInfo.Title or "Button",
                    TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Library.CurrentTheme.PrimaryTextColor,
                    TextSize = 14,
                    AutoButtonColor = false,
                    ZIndex = 102
                })
                
                -- Add corner radius to button
                local buttonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = button
                })
                
                -- Button click handler
                button.MouseButton1Click:Connect(function()
                    if buttonInfo.Callback then
                        buttonInfo.Callback()
                    end
                    
                    dialogBackground:Destroy()
                end)
                
                -- Button hover effect
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = i == 1 and 
                        Library.CurrentTheme.AccentColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2) or 
                        Library.CurrentTheme.SecondaryElementColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = i == 1 and Library.CurrentTheme.AccentColor or Library.CurrentTheme.SecondaryElementColor
                end)
            end
            
            -- Close dialog when clicking outside
            dialogBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local framePos = dialogFrame.AbsolutePosition
                    local frameSize = dialogFrame.AbsoluteSize
                    
                    if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                       mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                        dialogBackground:Destroy()
                    end
                end
            end)
        end
        
        return window
    end
    
    -- Create notification
    function Library:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local content = options.Content or ""
        local subContent = options.SubContent or nil
        local duration = options.Duration or 5
        
        -- Create notification frame
        local notificationFrame = CreateInstance("Frame", {
            Name = "Notification",
            Parent = self.WindowInstance and self.WindowInstance.NotificationContainer or nil,
            BackgroundColor3 = self.CurrentTheme.NotificationColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, subContent and 80 or 60),
            ZIndex = 100
        })
        
        -- Add corner radius to notification frame
        local frameCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = notificationFrame
        })
        
        -- Add drop shadow
        local dropShadow = CreateInstance("ImageLabel", {
            Name = "DropShadow",
            Parent = notificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -15, 0, -15),
            Size = UDim2.new(1, 30, 1, 30),
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = 99
        })
        
        -- Create title label
        local titleLabel = CreateInstance("TextLabel", {
            Name = "Title",
            Parent = notificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = self.CurrentTheme.PrimaryTextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101
        })
        
        -- Create content label
        local contentLabel = CreateInstance("TextLabel", {
            Name = "Content",
            Parent = notificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = self.CurrentTheme.SecondaryTextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101
        })
        
        -- Create subcontent label if provided
        if subContent then
            local subContentLabel = CreateInstance("TextLabel", {
                Name = "SubContent",
                Parent = notificationFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 55),
                Size = UDim2.new(1, -30, 0, 20),
                Font = Enum.Font.Gotham,
                Text = subContent,
                TextColor3 = self.CurrentTheme.SecondaryTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.2,
                ZIndex = 101
            })
        end
        
        -- Create progress bar
        local progressBar = CreateInstance("Frame", {
            Name = "ProgressBar",
            Parent = notificationFrame,
            BackgroundColor3 = self.CurrentTheme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 101
        })
        
        -- Animate notification
        notificationFrame.Position = UDim2.new(1, 20, 0, 0)
        notificationFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)
        
        -- Auto-close notification after duration
        if duration then
            -- Animate progress bar
            progressBar:TweenSize(UDim2.new(0, 0, 0, 2), "InOut", "Linear", duration, true)
            
            -- Close notification after duration
            spawn(function()
                wait(duration)
                notificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), "Out", "Quad", 0.3, true, function()
                    notificationFrame:Destroy()
                end)
            end)
        end
        
        return notificationFrame
    end
    
    -- Return the library
    return Library



