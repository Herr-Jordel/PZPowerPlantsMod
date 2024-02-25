local currentPowerMeter = nil  -- Variable to store the current power meter item

local function sendSpawnGeneratorsCommand(player, numGenerators, interval)
    sendClientCommand(player, 'PowerPlantMod', 'connectMeter', { numGenerators, interval, })
end

local function sendDisconnectMeterCommand(player)
    sendClientCommand(player, 'PowerPlantMod', 'disconnectMeter',{})
end

function onUsePowerMeter(worldobjects, player, item)
    if not item then
        print("Invalid item object.")
        return
    end

    local disconnectMode = item:getModData().disconnectMode or false

    if disconnectMode then
        sendDisconnectMeterCommand(player)
    else
        local numGenerators = 5  -- Replace with the actual value
        local interval = 20       -- Replace with the actual value
        sendSpawnGeneratorsCommand(player, numGenerators, interval)
    end

    -- Toggle disconnect mode
    item:getModData().disconnectMode = not disconnectMode
end

Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldobjects, _)
    local powerMeterObject

    -- Find item
    for _, v in ipairs(worldobjects) do
        if instanceof(v, "IsoWorldInventoryObject") then
            currentPowerMeter = v:getItem()  -- Store the current power meter item
            if currentPowerMeter and currentPowerMeter:getType() == "powerMeter" then
                powerMeterObject = v
                break
            end
        end
    end

    -- If no powerMeter is found, exit the function
    if not powerMeterObject then
        return
    end

    local contextMenu = "Use Power Meter"

    -- Update the context menu option based on disconnect mode
    if currentPowerMeter and currentPowerMeter:getModData().disconnectMode then
        contextMenu = "Disconnect Meter"
    end

    -- Add the context menu option
    context:addOption(
        getText(contextMenu),
        worldobjects,
        onUsePowerMeter, 
        getSpecificPlayer(player),
        currentPowerMeter
    )
end)
