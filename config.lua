Config = {}

Config.Debug = false
Config.DebugPrint = false

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