local priorityText = ""
local hidden = false

-- Improved drawText function with color and shadow options
function drawText(text, x, y, scale, font, color, shadow)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    
    if color then
        SetTextColour(color[1], color[2], color[3], color[4])
    else
        SetTextColour(255, 255, 255, 255)
    end

    if shadow then
        SetTextDropShadow(0, 0, 0, 0, 255)
    end

    SetTextOutline()
    SetTextJustification(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Consolidated chat suggestions
local chatSuggestions = {
    {command = "/stprio", description = "Start a priority."},
    {command = "/sprio", description = "Stop an active priority."},
    {command = "/cdprio", description = "Start a cooldown on priorities.", params = {{name = "Time", help = "Time in minutes to start a cooldown"}}},
    {command = "/jprio", description = "Join the current priority."},
    {command = "/lprio", description = "Leave the current priority."}
}

for _, suggestion in ipairs(chatSuggestions) do
    TriggerEvent("chat:addSuggestion", suggestion.command, suggestion.description, suggestion.params or {})
end

-- Handle the return of priority status from the server
RegisterNetEvent("JaRacc:Client:returnPriority")
AddEventHandler("JaRacc:Client:returnPriority", function(priority)
    if priority then
        priorityText = priority
    else
        print("Error: Priority event returned no data")
    end
end)

-- Reusable function for requesting priority status from the server
function requestPriorityStatus()
    TriggerServerEvent("JaRacc:Client:getPriority")
end

AddEventHandler("playerSpawned", function()
    requestPriorityStatus()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(3000)
        requestPriorityStatus()
    end
end)

-- Render the priority text if it's not hidden and is available
CreateThread(function()
    while true do
        Wait(500) -- Reduced to avoid constant CPU usage
        if not hidden and priorityText ~= "" then
            drawText(priorityText, 0.210, 0.950, 0.40, 4)
        end
    end
end)