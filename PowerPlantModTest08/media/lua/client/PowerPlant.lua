local powerPlantControlsObject = nil

local Utils = {}

function Utils.isPowerPlantControls(name)
    if not name then return false end
    local id = tonumber(name:match("PowerPlantControls_(%d+)$"))
    return id and id >= 0 and id <= 7
end

local function sendPowerplantConnectCMD(player, numGenerators, interval)
    sendClientCommand(player, 'PowerPlantMod', 'powerPlantOn', { numGenerators, interval })
end

local function sendPowerplantOffCMD(player, numGenerators, interval)
    sendClientCommand(player, 'PowerPlantMod', 'powerPlantOff', { numGenerators, interval })
end

function onUsePoerPlant(worldobjects, player, item)
    if not item or not powerPlantControlsObject then
        print("Invalid item or powerPlantControlsObject.")
        return
    end

    local OffMode = powerPlantControlsObject:getModData().OffMode or false

    if OffMode then
        sendPowerplantConnectCMD(player)
    else
        sendPowerplantOffCMD(player)
    end

    powerPlantControlsObject:getModData().OffMode = not OffMode
end

Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldobjects, _)		
    local foundPowerPlantControls = false

    for _, obj in ipairs(worldobjects) do
        if Utils.isPowerPlantControls(obj:getTextureName()) then
            powerPlantControlsObject = obj
            foundPowerPlantControls = true
            break
        end
    end

    if not foundPowerPlantControls then
        powerPlantControlsObject = nil  -- Reset the powerPlantControlsObject
        return
    end

    local contextMenu = "Start turbine"

    if powerPlantControlsObject:getModData().OffMode then
        contextMenu = "Shut off Power Plant"
    end
	
    context:addOption(
        getText(contextMenu),
        worldobjects,
        onUsePowerPlant, 
        getSpecificPlayer(player),
        powerPlantControlsObject
    )
end)
