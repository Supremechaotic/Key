-- LucideIcons.lua
-- Manages Lucide Icons integration

local LucideIcons = {}

-- Base URL for Lucide Icons
local BASE_URL = "https://lucide.dev/icons/"

-- Cache for downloaded icons
local iconCache = {}

-- Function to get icon URL
function LucideIcons:GetIconUrl(iconName)
    return BASE_URL .. iconName .. ".svg"
end

-- Function to convert SVG to Roblox ImageLabel format
function LucideIcons:ConvertSvgToImageLabel(svg)
    -- Remove SVG header and footer
    svg = svg:gsub("^<svg[^>]*>", "")
    svg = svg:gsub("</svg>$", "")
    
    -- Convert SVG attributes to Roblox properties
    local properties = {
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit
    }
    
    -- Create ImageLabel
    local imageLabel = Instance.new("ImageLabel")
    for property, value in pairs(properties) do
        imageLabel[property] = value
    end
    
    -- Set the SVG data
    imageLabel.Image = "data:image/svg+xml;base64," .. game:GetService("HttpService"):Encode(svg)
    
    return imageLabel
end

-- Function to get icon
function LucideIcons:GetIcon(iconName)
    -- Check cache first
    if iconCache[iconName] then
        return iconCache[iconName]
    end
    
    -- Download and convert icon
    local success, result = pcall(function()
        local response = game:GetService("HttpService"):GetAsync(self:GetIconUrl(iconName))
        return self:ConvertSvgToImageLabel(response)
    end)
    
    if success then
        -- Cache the result
        iconCache[iconName] = result
        return result
    end
    
    return nil
end

-- Function to get all available icons
function LucideIcons:GetAvailableIcons()
    -- Return a list of commonly used Lucide icons
    return {
        "Home",
        "Settings",
        "User",
        "Users",
        "Star",
        "Heart",
        "Bell",
        "Search",
        "Menu",
        "X",
        "Plus",
        "Minus",
        "Check",
        "Alert",
        "Info",
        "Warning",
        "Shield",
        "Lock",
        "Unlock",
        "Eye",
        "EyeOff",
        "Camera",
        "Image",
        "Video",
        "Music",
        "File",
        "Folder",
        "Download",
        "Upload",
        "Link",
        "Share",
        "Mail",
        "Phone",
        "Message",
        "Chat",
        "Calendar",
        "Clock",
        "Timer",
        "Map",
        "Navigation",
        "Compass",
        "Globe",
        "World",
        "Flag",
        "Bookmark",
        "Tag",
        "Label",
        "Filter",
        "Sort",
        "Refresh",
        "Rotate",
        "Zoom",
        "Maximize",
        "Minimize",
        "Expand",
        "Contract",
        "Move",
        "Drag",
        "Edit",
        "Trash",
        "Save",
        "Send",
        "Receive",
        "Sync",
        "Cloud",
        "Database",
        "Server",
        "Network",
        "Wifi",
        "Bluetooth",
        "Battery",
        "Power",
        "Zap",
        "Sun",
        "Moon",
        "Planet",
        "Rocket",
        "Plane",
        "Train",
        "Bus",
        "Car",
        "Bike",
        "Walk",
        "Run",
        "Jump",
        "Swim",
        "Game",
        "Controller",
        "Keyboard",
        "Mouse",
        "Monitor",
        "Printer",
        "Scanner",
        "HardDrive",
        "USB",
        "SD",
        "CD",
        "DVD",
        "VHS",
        "Radio",
        "TV",
        "Phone",
        "Tablet",
        "Laptop",
        "Desktop"
    }
end

return LucideIcons 