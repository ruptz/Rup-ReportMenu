-- Version checking
AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  versionCheck()
end)

MySQL.ready(function()
    -- Create reports table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `reports` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `player_id` VARCHAR(50) NOT NULL,
            `player_name` VARCHAR(255) NOT NULL,
            `reported_id` VARCHAR(50) NULL,
            `reported_name` VARCHAR(255) NULL,
            `title` VARCHAR(255) NOT NULL,
            `description` TEXT NOT NULL,
            `status` ENUM('open', 'in_progress', 'closed') DEFAULT 'open',
            `priority` ENUM('low', 'medium', 'high') DEFAULT 'medium',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Create report messages table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `report_messages` (
           `id` INT AUTO_INCREMENT PRIMARY KEY,
           `report_id` INT NOT NULL,
           `sender_id` VARCHAR(50) NOT NULL,
           `sender_name` VARCHAR(255) NOT NULL,
           `messages` JSON NOT NULL,
           `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
           FOREIGN KEY (`report_id`) REFERENCES `reports`(`id`) ON DELETE CASCADE
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Create user preferences table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `report_user_preferences` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `player_id` VARCHAR(255) NOT NULL,
            `theme` ENUM('light', 'dark') DEFAULT 'light',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY (`player_id`)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    print('[Rup-ReportMenu] Database tables initialized successfully')
end)

-- Events
RegisterNetEvent('rup-reportmenu:sendAdminNotification', function(data)
    local Players = GetPlayers()
    for _, playerId in ipairs(Players) do
        if IsPlayerAceAllowed(playerId, 'reportmenu.admin.view') or 
           IsPlayerAceAllowed(playerId, 'reportmenu.mod.view') then
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = data.title,
                description = data.description,
                icon = data.icon or 'fa-solid fa-bell',
                color = data.color or '#FFFFFF'
            })
        end
    end
end)

-- Callbacks
-- Create a new report
lib.callback.register('rup-reportmenu:createReport', function(source, data)
    local Player = GetPlayerPed(source)
    local PlayerName = data.name or GetPlayerName(source)
    local license = data.license or GetPlayerIdentifier(source, 0)
    if not Player then return { success = false } end

    local params = {
        player_id = license,
        player_name = PlayerName,
        reported_id = data.reported_id,
        reported_name = data.reported_name,
        title = data.title,
        description = data.description,
        status = 'open',
        priority = data.priority or 'medium'
    }
    
    local id = MySQL.insert.await('INSERT INTO reports SET ?', {params})
    if id then
        debugPrint('^2[Rup-ReportMenu]^7 Created new report with ID: ' .. id)
        TriggerClientEvent('rup-reportmenu:client:refreshReports', -1)
        TriggerEvent('rup-reportmenu:sendAdminNotification', {
            title = 'New Report Created',
            description = 'A new report has been created by ' .. GetPlayerName(source),
            icon = 'fa-solid fa-exclamation-triangle',
            color = '#FF0000'
        })        
        -- Webhook
        sendDiscordWebhook('createReport', {
            reportId = id,
            title = data.title,
            description = data.description,
            fields = {
                Player = { value = PlayerName },
                Priority = { value = data.priority or 'medium' },
                Status = { value = 'open' }
            }
        })
        return { success = true, reportId = id }
    else
        debugPrint('^1[Rup-ReportMenu]^7 Failed to create report')
        return { success = false }
    end
end)

-- Get reports for a specific player or all reports for admin
lib.callback.register('rup-reportmenu:getReports', function(source, filter)
    local Player = GetPlayerPed(source)
    local license = GetPlayerIdentifier(source, 0)
    if not Player then return {} end

    local query = ''    if IsPlayerAceAllowed(source, 'reportmenu.admin.view') or IsPlayerAceAllowed(source, 'reportmenu.mod.view') then
        query = 'SELECT * FROM reports ORDER BY updated_at DESC, id DESC'
        local results = MySQL.query.await(query)
        return results or {}
    else        query = 'SELECT * FROM reports WHERE player_id = ? ORDER BY updated_at DESC, id DESC'
        local results = MySQL.query.await(query, {license})
        return results or {}
    end
end)

-- Update report status
lib.callback.register('rup-reportmenu:updateReport', function(source, reportId, updates)
    local Player = GetPlayerPed(source)
    if not Player then return { success = false } end
    if not IsPlayerAceAllowed(source, 'reportmenu.admin.manage') and 
       not IsPlayerAceAllowed(source, 'reportmenu.mod.manage') then
        return { success = false }
    end

    local affectedRows = MySQL.update.await('UPDATE reports SET ? WHERE id = ?', {updates, reportId})
    return { success = affectedRows > 0 }
end)

-- Delete report (Admin only)
lib.callback.register('rup-reportmenu:deleteReport', function(source, data)
    local Player = GetPlayerPed(source)
    if not Player then return { success = false } end

    if not IsPlayerAceAllowed(source, 'reportmenu.admin.delete') then
        return { success = false }
    end

    -- Get details on the report and messages before we delete it for the webhook
    local reportResult = MySQL.single.await('SELECT * FROM reports WHERE id = ?', {data.reportId})
    local messagesResult = MySQL.query.await('SELECT messages, sender_id, sender_name FROM report_messages WHERE report_id = ?', {data.reportId})
    
    -- Delete report!
    local result = MySQL.query.await('DELETE FROM reports WHERE id = ?', {data.reportId})
    if result.affectedRows > 0 then
        TriggerClientEvent('rup-reportmenu:client:refreshReports', -1)
        if Config.FiveManage.DeleteMedia then
            local mediaData = { reportId = data.reportId, messages = messagesResult }
            TriggerClientEvent('rup-reportmenu:client:deleteReportMedia', -1, mediaData)
        end
        
        -- Webhook
        if reportResult then
            sendDiscordWebhook('deleteReport', {
                reportId = data.reportId,
                report = reportResult,
                messages = messagesResult,
                deletedBy = GetPlayerName(source)
            })
        end
        
        return { success = true }
    end
    return { success = false }
end)

-- Add message to report
lib.callback.register('rup-reportmenu:addMessage', function(source, data)
    local Player = GetPlayerPed(source)
    local license = data.license or GetPlayerIdentifier(source, 0)
    local playerName = data.name or GetPlayerName(source)
    if not Player then return { success = false } end    
    
    local reportExists = MySQL.scalar.await('SELECT id FROM reports WHERE id = ?', {data.report_id})
    if not reportExists then
        debugPrint('^1[Rup-ReportMenu]^0 Report ID does not exist:', data.report_id)
        return { success = false, error = 'Report not found' }
    end
    
    local existing = MySQL.single.await('SELECT * FROM report_messages WHERE report_id = ? AND sender_id = ?', {data.report_id, license})
    
    local newMessage = {
        message = data.message or '',
        sender_id = license,
        sender_name = playerName,
        sent_at = os.date('!%Y-%m-%d %H:%M:%S')
    }

    local id
    if existing then
        local messages = json.decode(existing.messages)
        table.insert(messages, newMessage)
        local success = MySQL.update.await('UPDATE report_messages SET messages = ? WHERE report_id = ?', 
            {json.encode(messages), data.report_id})
        if success then
            id = existing.id
        end
    else
        id = MySQL.insert.await([[
            INSERT INTO report_messages (report_id, sender_id, sender_name, messages)
            VALUES (?, ?, ?, ?)
        ]], {
            data.report_id,
            license,
            playerName,
            json.encode({newMessage})
        })
    end

    if id then
        MySQL.update.await('UPDATE reports SET updated_at = CURRENT_TIMESTAMP WHERE id = ?', {data.report_id})        
        local results = MySQL.query.await('SELECT * FROM reports WHERE id = ?', {data.report_id})

        for _, result in ipairs(results) do
            if result.player_id then
                local playerId = GetPlayerByLicense(result.player_id)
                local players = getAllPlayers()

                if playerId ~= 0 and license ~= result.player_id then
                    local menuState = lib.callback.await('rup-reportmenu:client:menuState', source)
                    if not menuState then
                        TriggerClientEvent('ox_lib:notify', playerId, {
                            title = 'New Message in Report ID: ' .. data.report_id,
                            description = 'You have a new message in your report: ' .. result.title,
                            icon = 'fa-solid fa-envelope',
                            color = '#00FF00'
                        })
                        TriggerEvent('rup-reportmenu:sendAdminNotification', {
                            title = 'New Message in Report',
                            description = 'A new message has been added to report ID: ' .. data.report_id,
                            icon = 'fa-solid fa-exclamation-triangle',
                            color = '#FF0000'
                        })
                    end
                end
                if players ~= nil then
                    for _, player in ipairs(players) do
                        if IsPlayerAnAce(player.id) or player.license == result.player_id then
                            TriggerClientEvent('rup-reportmenu:client:refreshReports', player.id)
                            TriggerClientEvent('rup-reportmenu:client:refreshMessages', player.id, data.report_id)
                        end
                    end
                end
            end
        end
        return { success = true, messageId = id }
    end
    return { success = false, messageId = nil }
end)

-- Get messages for a report
lib.callback.register('rup-reportmenu:getReportMessages', function(source, reportId)
    local Player = GetPlayerPed(source)
    local license = GetPlayerIdentifier(source, 0)
    if not Player then return { messages = {} } end

    -- Get all message rows for this report
    local results = MySQL.query.await('SELECT messages, sender_id, sender_name FROM report_messages WHERE report_id = ?', {reportId})
    
    local allMessages = {}
    if results then
        for _, row in ipairs(results) do
            local messages = json.decode(row.messages)
            for _, msg in ipairs(messages) do
                if not msg.sender_id then msg.sender_id = row.sender_id end
                if not msg.sender_name then msg.sender_name = row.sender_name end
                table.insert(allMessages, msg)
            end
        end

        -- Sort messages by sent_at
        table.sort(allMessages, function(a, b)
            return a.sent_at < b.sent_at
        end)
    end

    return { messages = allMessages, currentPlayer = license }
end)

-- Get user permissions
lib.callback.register('rup-reportmenu:getPermissions', function(source)
    local Player = GetPlayerPed(source)
    if not Player then return {} end

    local permissions = {}
    
    -- Basic permission that all players get
    table.insert(permissions, 'reportmenu.player.create')
    -- Check admin permissions
    if IsPlayerAceAllowed(source, 'reportmenu.admin.view') then
        table.insert(permissions, 'reportmenu.admin.view')
    end
    if IsPlayerAceAllowed(source, 'reportmenu.admin.manage') then
        table.insert(permissions, 'reportmenu.admin.manage')
    end
    if IsPlayerAceAllowed(source, 'reportmenu.admin.delete') then
        table.insert(permissions, 'reportmenu.admin.delete')
    end
    
    -- Check mod permissions
    if IsPlayerAceAllowed(source, 'reportmenu.mod.view') then
        table.insert(permissions, 'reportmenu.mod.view')
    end
    if IsPlayerAceAllowed(source, 'reportmenu.mod.manage') then
        table.insert(permissions, 'reportmenu.mod.manage')
    end

    -- Check player permissions
    debugPrint('^3[Rup-ReportMenu]^0 Player Permissions:', json.encode(permissions, {indent = true}))
    
    return permissions
end)

-- Get user preferences
lib.callback.register('rup-reportmenu:getUserPreferences', function(source)
    local license = GetPlayerIdentifier(source, 0)
    if not license then 
        return { theme = 'light' } 
    end

    local results = MySQL.query.await('SELECT theme FROM report_user_preferences WHERE player_id = ?', {
        license
    })
    
    if results and #results > 0 then
        return { theme = results[1].theme }
    else
        -- Create default preferences for new user
        local insertId = MySQL.insert.await('INSERT INTO report_user_preferences (player_id, theme) VALUES (?, ?)', {
            license,
            'light'
        })
        
        if insertId then
            return { theme = 'light' }
        else
            return { theme = 'light', error = 'Failed to create preferences' }
        end
    end
end)

-- Update user preferences
lib.callback.register('rup-reportmenu:updateUserPreferences', function(source, data)
    local license = GetPlayerIdentifier(source, 0)
    if not license then 
        return { success = false } 
    end

    local affectedRows = MySQL.update.await('INSERT INTO report_user_preferences SET ? ON DUPLICATE KEY UPDATE theme = ?', {
        { player_id = license, theme = data.theme },
        data.theme
    })
    return { success = affectedRows > 0 }
end)

-- Get player license by type
lib.callback.register('rup-reportmenu:getPlayerLicenses', function(source, data)
    local playerLicense = data.playerLicense
    local licenseType = data.licenseType
    
    if not playerLicense or not licenseType then
        return { success = false, error = 'Missing parameters' }
    end
    
    local license = GetPlayerLicensesByLicense(playerLicense, licenseType)
    
    if license and license ~= 0 then
        return { success = true, license = license }
    else
        return { success = false, error = 'License not found' }
    end
end)