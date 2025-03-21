-- EmojiIcons.lua
-- Manages emoji icons for the UI library

local EmojiIcons = {}

-- Emoji mapping
EmojiIcons.Icons = {
    Home = "🏠",
    Settings = "⚙️",
    User = "👤",
    Users = "👥",
    Star = "⭐",
    Heart = "❤️",
    Bell = "🔔",
    Search = "🔍",
    Menu = "☰",
    X = "❌",
    Plus = "➕",
    Minus = "➖",
    Check = "✅",
    Alert = "⚠️",
    Info = "ℹ️",
    Warning = "⚠️",
    Shield = "🛡️",
    Lock = "🔒",
    Unlock = "🔓",
    Eye = "👁️",
    EyeOff = "👁️‍🗨️",
    Camera = "📸",
    Image = "🖼️",
    Video = "🎥",
    Music = "🎵",
    File = "📄",
    Folder = "📁",
    Download = "⬇️",
    Upload = "⬆️",
    Link = "🔗",
    Share = "↗️",
    Mail = "📧",
    Phone = "📱",
    Message = "💬",
    Chat = "💭",
    Calendar = "📅",
    Clock = "🕒",
    Timer = "⏱️",
    Map = "🗺️",
    Navigation = "🧭",
    Compass = "🧭",
    Globe = "🌍",
    World = "🌎",
    Flag = "🚩",
    Bookmark = "🔖",
    Tag = "🏷️",
    Label = "🏷️",
    Filter = "🔍",
    Sort = "↕️",
    Refresh = "🔄",
    Rotate = "🔄",
    Zoom = "🔍",
    Maximize = "⛶",
    Minimize = "⛶",
    Expand = "⤴️",
    Contract = "⤵️",
    Move = "↕️",
    Drag = "↕️",
    Edit = "✏️",
    Trash = "🗑️",
    Save = "💾",
    Send = "📤",
    Receive = "📥",
    Sync = "🔄",
    Cloud = "☁️",
    Database = "🗄️",
    Server = "🖥️",
    Network = "🌐",
    Wifi = "📶",
    Bluetooth = "📶",
    Battery = "🔋",
    Power = "⚡",
    Zap = "⚡",
    Sun = "☀️",
    Moon = "🌙",
    Planet = "🌍",
    Rocket = "🚀",
    Plane = "✈️",
    Train = "🚂",
    Bus = "🚌",
    Car = "🚗",
    Bike = "🚲",
    Walk = "🚶",
    Run = "🏃",
    Jump = "🦘",
    Swim = "🏊",
    Game = "🎮",
    Controller = "🎮",
    Keyboard = "⌨️",
    Mouse = "🖱️",
    Monitor = "💻",
    Printer = "🖨️",
    Scanner = "📠",
    HardDrive = "💾",
    USB = "💾",
    SD = "💾",
    CD = "💿",
    DVD = "💿",
    VHS = "📼",
    Radio = "📻",
    TV = "📺",
    Phone = "📱",
    Tablet = "📱",
    Laptop = "💻",
    Desktop = "🖥️"
}

-- Function to get icon
function EmojiIcons:GetIcon(iconName)
    return self.Icons[iconName] or "📄" -- Default to document emoji if not found
end

-- Function to get all available icons
function EmojiIcons:GetAvailableIcons()
    local icons = {}
    for name, _ in pairs(self.Icons) do
        table.insert(icons, name)
    end
    return icons
end

return EmojiIcons 