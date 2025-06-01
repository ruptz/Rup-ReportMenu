--- @param data table
function generateAndSendTranscript(data)
    local transcript = '=== REPORT TRANSCRIPT ===\n'
    transcript = transcript .. 'Report ID: ' .. data.reportId .. '\n'
    transcript = transcript .. 'Title: ' .. (data.report.title or 'N/A') .. '\n'
    transcript = transcript .. 'Reporter: ' .. (data.report.player_name or 'N/A') .. '\n'
    transcript = transcript .. 'Status: ' .. (data.report.status or 'N/A') .. '\n'
    transcript = transcript .. 'Priority: ' .. (data.report.priority or 'N/A') .. '\n'
    transcript = transcript .. 'Created: ' .. (data.report.created_at or 'N/A') .. '\n'
    transcript = transcript .. 'Deleted by: ' .. data.deletedBy .. '\n'
    transcript = transcript .. 'Deleted at: ' .. os.date('%Y-%m-%d %H:%M:%S UTC') .. '\n\n'
    
    transcript = transcript .. '=== DESCRIPTION ===\n'
    transcript = transcript .. (data.report.description or 'No description') .. '\n\n'
    
    transcript = transcript .. '=== MESSAGES ===\n'
    
    if data.messages and #data.messages > 0 then
        local allMessages = {}

        for _, row in ipairs(data.messages) do
            local messages = json.decode(row.messages)
            for _, msg in ipairs(messages) do
                if not msg.sender_id then msg.sender_id = row.sender_id end
                if not msg.sender_name then msg.sender_name = row.sender_name end
                table.insert(allMessages, msg)
            end
        end
        
        -- Sort by timestamp
        table.sort(allMessages, function(a, b)
            return (a.sent_at or '') < (b.sent_at or '')
        end)
        
        -- Add messages to transcript
        for _, msg in ipairs(allMessages) do
            transcript = transcript .. '[' .. (msg.sent_at or 'Unknown time') .. '] '
            transcript = transcript .. (msg.sender_name or 'Unknown') .. ': '
            transcript = transcript .. (msg.message or 'No message')
            
            transcript = transcript .. '\n'
        end
    else
        transcript = transcript .. 'No messages found.\n'
    end

    -- Grab formatted report and save it to a file, dont worry about the io.open and file:write its not malicous code
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local transcriptDir = resourcePath .. '/transcripts'
    local transcriptPath = transcriptDir .. '/report_' .. data.reportId .. '_transcript.txt'

    local file = io.open(transcriptPath, 'w')
    if file then
        file:write(transcript)
        file:close()
        debugPrint('^2[Rup-ReportMenu]^0 Transcript saved to:', transcriptPath)
    else
        debugPrint('^1[Rup-ReportMenu]^0 Failed to save transcript')
    end

    Wait(1000)
    
    local boundary = '----FormBoundary' .. os.time() .. math.random(1000, 9999)
    local payload = '--' .. boundary .. '\r\n'
    payload = payload .. 'Content-Disposition: form-data; name="files[0]"; filename="report_' .. data.reportId .. '_transcript.txt"\r\n'
    payload = payload .. 'Content-Type: text/plain\r\n\r\n'
    payload = payload .. transcript .. '\r\n'
    payload = payload .. '--' .. boundary .. '--\r\n'
    
    PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers) 
        if err == 204 or err == 200 then
            debugPrint('^2[Rup-ReportMenu]^0 Discord transcript file sent successfully')
        else
            debugPrint('^1[Rup-ReportMenu]^0 Failed to send transcript file. Status:', err)
            debugPrint('^1[Rup-ReportMenu]^0 Response:', text)
        end
    end, 'POST', payload, { 
        ['Content-Type'] = 'multipart/form-data; boundary=' .. boundary 
    })
end

--- @param type string
--- @param data table
function sendDiscordWebhook(type, data)
    debugPrint('^3[Rup-ReportMenu]^0 Sending Discord webhook:', type)
    if not Config.Discord.Enabled then return end

    local embed = {}
    if type == 'createReport' then
        embed = {
            {
                title = '🆕 **New Report Created**',
                description = '**Report ID:** `' .. data.reportId .. '`\n**Title:** ' .. data.title,
                color = Config.Discord.CreateEmebedColor,
                fields = {
                    { name = '👤 **Reporter**', value = data.fields.Player.value, inline = true },
                    { name = '⚠️ **Priority**', value = data.fields.Priority.value:upper(), inline = true },
                    { name = '📊 **Status**', value = data.fields.Status.value:upper(), inline = true },
                    { name = '📝 **Description**', value = '```\n' .. data.description .. '\n```', inline = false }
                },
                footer = {
                    text = 'Rup-ReportMenu • New report created',
                    icon_url = Config.Discord.ImageUrl
                },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }
        }    
    elseif type == 'deleteReport' then
        local embed = {
            embeds = {
                {
                    title = '🗑️ **Report Deleted**',
                    description = '**Report ID:** `' .. data.reportId .. '`\n**Title:** ' .. (data.report.title or 'N/A'),
                    color = Config.Discord.ReportEmbedColor,
                    fields = {
                        { name = '👤 **Original Reporter**', value = data.report.player_name or 'N/A', inline = true },
                        { name = '🛡️ **Deleted By**', value = data.deletedBy, inline = true },
                        { name = '📊 **Final Status**', value = (data.report.status or 'unknown'):upper(), inline = true },                        
                        { name = '📝 **Description**', value = '```\n' .. (data.report.description or 'No description') .. '\n```', inline = false },
                        { name = '💬 **Messages**', value = (data.messages and #data.messages > 0) and 'See transcript below' or 'No messages', inline = false }
                    },
                    footer = {
                        text = 'Rup-ReportMenu • Full transcript attached below',
                        icon_url = Config.Discord.ImageUrl
                    },
                    timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
                }
            }
        }
        
        PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers) 
            if err == 204 or err == 200 then
                debugPrint('^2[Rup-ReportMenu]^0 Discord embed sent successfully')
                generateAndSendTranscript(data)
            else
                debugPrint('^1[Rup-ReportMenu]^0 Failed to send Discord embed. Status:', err)
                debugPrint('^1[Rup-ReportMenu]^0 Response:', text)
            end
        end, 'POST', json.encode(embed), { ['Content-Type'] = 'application/json' })
        
        return
    end
    
    if #embed > 0 then
        PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers) 
            if err == 204 or err == 200 then
                debugPrint('^2[Rup-ReportMenu]^0 Discord webhook sent successfully')
            else
                debugPrint('^1[Rup-ReportMenu]^0 Failed to send Discord webhook. Status:', err)
            end
        end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
    end
end