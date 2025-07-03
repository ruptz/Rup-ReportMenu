Config = {}

Config.Debug = false
Config.DebugPrint = false

-- Language
Config.Language = { -- en, es
    Default = 'en',
}

-- Permissions
Config.Permissions = {
    -- Admin
    'reportmenu.admin.view',
    'reportmenu.admin.manage',
    'reportmenu.admin.delete',
    -- Mod
    'reportmenu.mod.view',
    'reportmenu.mod.manage',
}

-- Cooldowns
Config.Cooldowns = {
    Chat = 5000,    -- 5 seconds
    Report = 10000, -- 10 seconds
    Theme = 10000   -- 10 seconds
}

-- Discord Webhook
Config.Discord = {
    Enabled = false, -- Set to true to enable Discord integration
    Webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL', -- Replace with your actual webhook URL
    ImageUrl = 'https://i.imgur.com/OZyXBv0.png', 
    ReportEmbedColor = 16711680, -- Red
    CreateEmebedColor = 65280, -- Green
}

-- FiveManage API
Config.FiveManage = {
    ApiKey = "YOUR_API_KEY",  -- Replace with your actual API key (https://fivemanage.com/)
    DeleteMedia = true,       -- Delete media files after report deletion
}