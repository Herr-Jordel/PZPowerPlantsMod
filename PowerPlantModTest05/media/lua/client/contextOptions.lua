
local function sendSpawnGeneratorsCommand(player, numGenerators, interval)
    sendClientCommand('PowerPlantMod', 'spawnGenerators', { numGenerators, interval, player:getUsername() })
end

function onUsePowerMeter(item, player)
	
    -- trying to trigger the server-side function when using the power meter
	local numGenerators = 5  -- Replace with actual value
	local interval = 20       -- Replace with actual value
	sendSpawnGeneratorsCommand(player, numGenerators, interval)
	

end

Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldobjects, _)
    local powerMeterObject

    -- Find item
    for _, v in ipairs(worldobjects) do
        if instanceof(v, "IsoWorldInventoryObject") then
            local item = v:getItem()  -- Fix variable name to 'v' instead of 'worldObject'
            if item and item:getType() == "powerMeter" then
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

    -- Add the context menu option
    context:addOption(
        getText(contextMenu),
        worldobjects,
        onUsePowerMeter,  -- Call the onUsePowerMeter function
        getSpecificPlayer(player),
        powerMeterObject
    )
end)
