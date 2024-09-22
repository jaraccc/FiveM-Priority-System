-- Encapsulating the priority system in a table for better modularity and readability
local prioritySystem = {
    status = "~w~Priority Status: ~g~Inactive",
    players = {},
    isCooldown = false,
    isActive = false,
    cooldownTime = 60000 -- 1 minute in milliseconds
}

-- Constants
local PRIORITY_INACTIVE = "~w~Priority Status: ~g~Inactive"
local PRIORITY_ACTIVE = "~w~Priority Status: ~r~Active"
local PRIORITY_COOLDOWN = "~w~Priority Status: ~r~Cooldown ~c~"
local ERROR_NO_PERMISSION = "You don't have permission to use this command."
local ERROR_PRIORITY_ACTIVE = "There's already an active priority."
local ERROR_NO_ACTIVE_PRIORITY = "There's no active priority to stop."

-- Configuration for webhook
local config = {
    webhook = "https://discord.com/api/webhooks/"
}

-- Helper Functions

-- Concatenate a table with a separator
local function tableConcat(tbl, sep)
    return table.concat(tbl, sep)
end

-- Count the number of elements in a table
local function tableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Check if a player has the necessary permission
local function hasPermission(player, permission)
    return IsPlayerAceAllowed(player, permission)
end

-- Trigger cooldown for priority system
function prioritySystem.priorityCooldown(time)
    prioritySystem.isActive = false
    prioritySystem.isCooldown = true
    for cooldown = time, 1, -1 do
        prioritySystem.status = PRIORITY_COOLDOWN .. "(" .. cooldown .. " " .. (cooldown == 1 and "min" or "mins") .. ")"
        TriggerClientEvent("JaRacc:Client:returnPriority", -1, prioritySystem.status)
        Citizen.Wait(prioritySystem.cooldownTime)
    end
    prioritySystem.status = PRIORITY_INACTIVE
    TriggerClientEvent("JaRacc:Client:returnPriority", -1, prioritySystem.status)
    prioritySystem.isCooldown = false
end

-- Log event to Discord via webhook
RegisterServerEvent('startPrioLog')
AddEventHandler('startPrioLog', function(source, name, message)
    local postalCode = getPostal(source)
    local webhook = config.webhook
    local date = os.date('%m/%d/%Y')
    local time = os.date('%H:%M')
    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "Priority Event",
            ["description"] = name .. " " .. message .. " at postal " .. postalCode .. " on **" .. date .. "** **" .. time .. "**",
            ["footer"] = {
                ["text"] = "JaRacc"
            }
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Priority Alerts", embeds = embed}), { ['Content-Type'] = 'application/json' })
end)

-- Command Implementations

-- Start a priority
RegisterCommand("stprio", function(source)
    local player = source
    if prioritySystem.isCooldown then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Cannot start priority due to cooldown."}
        })
        return
    end
    if prioritySystem.isActive then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", ERROR_PRIORITY_ACTIVE}
        })
        return
    end
    prioritySystem.isActive = true
    prioritySystem.players[player] = GetPlayerName(player) .. " #" .. player
    prioritySystem.status = PRIORITY_ACTIVE .. " (" .. tableConcat(prioritySystem.players, ", ") .. ")"
    TriggerClientEvent("JaRacc:Client:returnPriority", -1, prioritySystem.status)
    TriggerEvent('startPrioLog', player, GetPlayerName(player), "has started a priority.")
end, false)

-- Stop the priority
RegisterCommand("sprio", function(source)
    local player = source
    if not prioritySystem.isActive then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", ERROR_NO_ACTIVE_PRIORITY}
        })
        return
    end
    TriggerEvent('startPrioLog', player, GetPlayerName(player), "has stopped the priority.")
    prioritySystem.players = {}
    prioritySystem.priorityCooldown(config.cooldownAfterPriorityStops)
end, false)

-- Priority cooldown
RegisterCommand("cdprio", function(source, args)
    local player = source
    local time = tonumber(args[1])

    if not time or time <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Invalid cooldown time."}
        })
        return
    end

    if not hasPermission(player, "Priority.Admin") then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", ERROR_NO_PERMISSION}
        })
        return
    end

    prioritySystem.priorityCooldown(time)
    TriggerEvent('startPrioLog', player, GetPlayerName(player), "has started a priority cooldown.")
end, false)

-- Join priority
RegisterCommand("jprio", function(source)
    local player = source
    if not prioritySystem.isActive then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "There's no active priority to join."}
        })
        return
    end
    if prioritySystem.players[player] then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "You're already in this priority."}
        })
        return
    end
    prioritySystem.players[player] = GetPlayerName(player) .. " #" .. player
    prioritySystem.status = PRIORITY_ACTIVE .. " (" .. tableConcat(prioritySystem.players, ", ") .. ")"
    TriggerClientEvent("JaRacc:Client:returnPriority", -1, prioritySystem.status)
    TriggerEvent('startPrioLog', player, GetPlayerName(player), "has joined the priority.")
end, false)

-- Leave priority
RegisterCommand("lprio", function(source)
    local player = source
    if not prioritySystem.isActive then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "There's no active priority to leave."}
        })
        return
    end
    if tableCount(prioritySystem.players) == 1 and prioritySystem.players[player] == (GetPlayerName(player) .. " #" .. player) then
        prioritySystem.players = {}
        prioritySystem.status = PRIORITY_INACTIVE
        prioritySystem.isActive = false
    else
        prioritySystem.players[player] = nil
        prioritySystem.status = PRIORITY_ACTIVE .. " (" .. tableConcat(prioritySystem.players, ", ") .. ")"
    end
    TriggerClientEvent("JaRacc:Client:returnPriority", -1, prioritySystem.status)
    TriggerEvent('startPrioLog', player, GetPlayerName(player), "has left the priority.")
end, false)