-- LucideIcons.lua
-- Manages Lucide Icons integration

local LucideIcons = {}

-- Base URL for Lucide Icons
local BASE_URL = "https://raw.githubusercontent.com/lucide-icons/lucide/master/icons/"

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
    local success, result = pcall(function()
        local response = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/lucide-icons/lucide/master/icons.json")
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    
    if success then
        local icons = {}
        for name, _ in pairs(result) do
            table.insert(icons, name)
        end
        return icons
    end
    
    return {}
end

return LucideIcons 