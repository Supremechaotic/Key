local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Supremechaotic/Key/refs/heads/main/UI_library/MainLib.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Supremechaotic/Key/refs/heads/main/UI_library/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Supremechaotic/Key/refs/heads/main/UI_library/InterfaceManager.lua"))()

local Window = Library:CreateWindow({
    Title = "My UI Library",
    SubTitle = "by you",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "Srtt" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Add elements to Main tab
Tabs.Main:AddButton({
    Title = "Button",
    Description = "Click me!",
    Callback = function()
        Library:Notify({
            Title = "Button Clicked",
            Content = "You clicked the button!",
            Duration = 5
        })
    end
})

-- Add slider
Tabs.Main:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Description = "Adjust your walk speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

-- Add dropdown
Tabs.Main:AddDropdown("TeleportDropdown", {
    Title = "Teleport",
    Description = "Choose location to teleport",
    Values = {"Spawn", "Shop", "Boss Room"},
    Default = "Spawn",
    Multi = false,
    Callback = function(Value)
        print("Selected:", Value)
    end
})

-- Add multi-select dropdown
Tabs.Main:AddDropdown("SettingsDropdown", {
    Title = "Settings",
    Description = "Choose multiple settings",
    Values = {"Auto Farm", "Auto Sell", "Auto Upgrade"},
    Default = {},
    Multi = true,
    Callback = function(Value)
        print("Selected Settings:", table.concat(Value, ", "))
    end
})

-- Set up SaveManager and InterfaceManager
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("MyScript")
InterfaceManager:SetFolder("MyScript")

-- Build settings UI
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select default tab
Window:SelectTab(1)

-- Load auto-save config
SaveManager:LoadAutoloadConfig()