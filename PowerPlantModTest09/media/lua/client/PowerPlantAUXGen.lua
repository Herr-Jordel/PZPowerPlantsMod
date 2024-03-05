local AuxGenObj = nil
local OffMode = false

local Utils = {}

function Utils.isPowerPlantAuxGen(name)
    if not name then return false end
    local id = tonumber(name:match("PowerPlantControls_(%d+)$"))
    return id and id >= 8 and id <= 18				
end

local function sendAuxGenConnectCMD(player)
    sendClientCommand(player, 'PowerPlantMod', 'AuxGenON', {})
end

local function sendauxGenOffCMD(player)
    sendClientCommand(player, 'PowerPlantMod', 'AuxGenOFF', {})
end

function onUseAuxGen(worldobjects, player, item)
    if not item or not AuxGenObj then
        print("Invalid item or AuxGenObject.")
        return
    end

 --   local numGenerators = 5
 --   local interval = 20

    if OffMode then
        sendauxGenOffCMD(player)
    else
		sendAuxGenConnectCMD(player)

    end

    OffMode = not OffMode
end

Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldobjects, _)		
    local foundAuxGen = false

    for _, obj in ipairs(worldobjects) do
        if Utils.isPowerPlantAuxGen(obj:getTextureName()) then
            AuxGenObj = obj
            foundAuxGen = true
            break
        end
    end

    if not foundAuxGen then
        AuxGenObj = nil  -- Reset the AuxGenObj
        return
    end

    local contextMenu = "Start Industrial Generator"

    if OffMode then
        contextMenu = "Shut off Genenrator"
    end
	
    context:addOption(
        getText(contextMenu),
        worldobjects,
        onUseAuxGen, 
        getSpecificPlayer(player),
        AuxGenObj
    )
end)