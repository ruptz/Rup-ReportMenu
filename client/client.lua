local isMenuOpen = false
local lastThemeUpdate = 0
local lastReportCreated = 0
local lastChatSent = 0
local Cooldowns = Config.Cooldowns

-- Callback to handle menu open/close
lib.callback.register('rup-reportmenu:client:menuState', function()
    return isMenuOpen
end)

-- Function to toggle UI
local function ToggleReportMenu(show)
    if show == isMenuOpen then return end
    isMenuOpen = show
    SetNuiFocus(show, show)
    if show then
        SendNUIMessage({
            action = "openReportMenu"
        })
    end
end

-- Commands
RegisterCommand('reports', function()
    ToggleReportMenu(not isMenuOpen)
end, false)

if Config.Debug then
    RegisterCommand('sendmessage', function()
        data = {
            report_id = 2,
            message = "This is a test message!!!!???????",
            license = "license:1234567890abcdef",
            name = "Test Player",
        }

        local result = lib.callback.await('rup-reportmenu:addMessage', false, data)
        if result then
            debugPrint('^3[Rup-ReportMenu]^0 Message sent successfully:', json.encode(result))
        else
            debugPrint('^1[Rup-ReportMenu]^0 Failed to send message')
        end
        debugPrint('^3[Rup-ReportMenu]^0 Adding message to report:', json.encode(data))
    end, false)

    RegisterCommand('createReport', function()
        data = {
            license = "license:1234567890abcdef",
            name = "Jean Paul",
            reported_id = null,
            reported_name = "John Pork",
            title = "Test Report",
            description = "This is a test report",
            priority = "medium",
        }

        local result = lib.callback.await('rup-reportmenu:createReport', false, data)
        if result then
            debugPrint('^3[Rup-ReportMenu]^0 Report created successfully:', json.encode(result))
        else
            debugPrint('^1[Rup-ReportMenu]^0 Failed to create report')
        end
    end, false)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    if isMenuOpen then
        ToggleReportMenu(false)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('createReport', function(data, cb)
    if isCooldownActive(lastReportCreated, Cooldowns.Report) then
        debugPrint('^1[Rup-ReportMenu]^0 Create Report Blocked: Cooldown active')
        cb({ success = false, error = 'Please wait before creating another report' })
        return
    end

    lastReportCreated = GetGameTimer()   
    local result = lib.callback.await('rup-reportmenu:createReport', false, data)
    cb({ success = result.success, reportId = result.reportId })
    debugPrint('^3[Rup-ReportMenu]^0 Creating report with data:', json.encode(data)) 
end)

RegisterNUICallback('copyToClipboard', function(data, cb)    
    local success = copyToClipboard(data.text)
    cb(success)
end)

RegisterNUICallback('getReports', function(data, cb)    
    local reports = lib.callback.await('rup-reportmenu:getReports', false, data.filter)
    cb(reports)
end)

RegisterNUICallback('updateReport', function(data, cb)    
    local success = lib.callback.await('rup-reportmenu:updateReport', false, data.reportId, data.updates)
    cb({ success = success })
end)

RegisterNUICallback('deleteReport', function(data, cb)
    debugPrint('^3[Rup-ReportMenu]^0 Deleting report:', data.reportId)
    local success = lib.callback.await('rup-reportmenu:deleteReport', false, data)
    cb({ success = success })
end)

RegisterNUICallback('addMessage', function(data, cb)
    if isCooldownActive(lastChatSent, Cooldowns.Chat) then
        debugPrint('^1[Rup-ReportMenu]^0 Add Message Blocked: Cooldown active')
        lib.notify({ title = 'Error', description = 'Cooldown Active', type = 'error'})
        cb({ success = false, error = 'Please wait before adding another message' })
        return
    end

    lastChatSent = GetGameTimer()
    local result = lib.callback.await('rup-reportmenu:addMessage', false, data)
    if result then
        debugPrint('^3[Rup-ReportMenu]^0 Message added successfully:', json.encode(result))
        cb({ success = result.success, messageId = result.messageId })
    else
        debugPrint('^1[Rup-ReportMenu]^0 Failed to add message:', json.encode(data))
        cb({ success = false, error = 'Failed to add message' })
    end
    debugPrint('^3[Rup-ReportMenu]^0 Adding message to report:', json.encode(data))
end)

RegisterNUICallback('getPermissions', function(data, cb)
    local permissions = lib.callback.await('rup-reportmenu:getPermissions', false)
    cb(permissions)
end)

RegisterNUICallback('getUserPreferences', function(data, cb)
    local preferences = lib.callback.await('rup-reportmenu:getUserPreferences', false)
    cb(preferences)
end)

RegisterNUICallback('updateUserPreferences', function(data, cb)
    if isCooldownActive(lastThemeUpdate, Cooldowns.Theme) then
        debugPrint('^1[Rup-ReportMenu]^0 Theme update blocked: Cooldown active')
        cb({ success = false, error = 'Please wait before changing theme again' })
        return
    end
    
    lastThemeUpdate = GetGameTimer()
    debugPrint('^3[Rup-ReportMenu]^0 Updating user preferences:', json.encode(data))    
    local result = lib.callback.await('rup-reportmenu:updateUserPreferences', false, data)
    cb(result)
end)

RegisterNUICallback('getReportMessages', function(data, cb)
    debugPrint('^3[Rup-ReportMenu]^0 Getting messages for report:', data.reportId)
    local messages = lib.callback.await('rup-reportmenu:getReportMessages', false, data.reportId)
    cb(messages or {})
end)

-- Events to handle reports
RegisterNetEvent('rup-reportmenu:client:refreshReports')
AddEventHandler('rup-reportmenu:client:refreshReports', function()    
    local reports = lib.callback.await('rup-reportmenu:getReports', false)
    debugPrint('^3[Rup-ReportMenu]^0 Refreshing reports')
    SendNUIMessage({
        type = "updateReports",
        reports = reports
    })
end)

RegisterNetEvent('rup-reportmenu:client:refreshMessages')
AddEventHandler('rup-reportmenu:client:refreshMessages', function(reportId)  
    local response = lib.callback.await('rup-reportmenu:getReportMessages', false, reportId)  
    debugPrint('^3[Rup-ReportMenu]^0 Refreshing messages for report:', reportId)
    SendNUIMessage({
        type = "updateMessages",
        id = reportId
    })
end)