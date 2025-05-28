function versionCheck()
    lib.versionCheck('ruptz/Rup-ReportMenu')
end

--- @param ... string
function debugPrint(...)
    if Config.DebugPrint then
        print(...)
    end
end

--- @param lastActionTime integer
--- @param cooldownDuration integer
--- @return boolean
function isCooldownActive(lastActionTime, cooldownDuration)
    local currentTime = GetGameTimer()
    return (currentTime - lastActionTime) < cooldownDuration
end

--- @param value string
--- @return boolean
function copyToClipboard(value)
    if value == nil or value == '' then
        lib.notify({ title = 'Error', description = 'Failed to copy text', type = 'error'})
        return false
    end

    lib.notify({ title = 'Success', description = 'Copied to clipboard', type = 'success'})
    lib.setClipboard(value)
    return true
end

--- @return table
function getAllPlayers()
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local playerName = GetPlayerName(playerId)
        local playerLicense = GetPlayerIdentifier(playerId, 0)
        table.insert(players, { id = tonumber(playerId), license = playerLicense, name = playerName })
    end
    return players
end

--- @param license Identifier
--- @return source
function GetPlayerByLicense(license)
    for _, playerId in ipairs(GetPlayers()) do
        local identifiers = GetPlayerIdentifiers(playerId)
        for _, id in ipairs(identifiers) do
            if id == license then
                return playerId
            end
        end
    end
    return 0
end

--- @param player source
--- @return boolean
function IsPlayerAnAce(player)
    if player == nil then
        debugPrint("^1[Rup-ReportMenu]^0 Invalid player (nil)")
        return false
    end

    debugPrint("^3[Rup-ReportMenu]^0 Checking ACE permissions for player:", player)

    for _, perm in ipairs(Config.Permissions) do
        if IsPlayerAceAllowed(player, perm) then
            debugPrint(string.format("^3[Rup-ReportMenu]^0 Player %s has permission: %s", player, perm))
            return true
        end
    end

    debugPrint(string.format("^1[Rup-ReportMenu]^0 Player %s has no matching ACE permissions", player))
    return false
end