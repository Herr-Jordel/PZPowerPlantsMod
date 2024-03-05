local spawnedGenerators = {}														--important Vars
local powerPlantConnected = false
local AuxGeneratorON = false

local function spawnGenerator(x, y, z, powerMeter)									-- Function to spawn a generator at given coordinates
    print(string.format("Power Plant: square at %d, %d, %d start adding generator", x, y, z))
    local cell = getCell()
    local square = cell:getOrCreateGridSquare(x, y, z)

    if square:getChunk() == nil then    											-- Square test
        print(string.format("Power Plant: square at %d, %d, %d has no chunk", x, y, z))
        square:discard()
        return
    end

    local generator = square:getGenerator()						    				-- Generator test
    if generator == nil then
        print(string.format("Power Plant: square at %d, %d, %d has no generator", x, y, z))
        generator = IsoGenerator.new(nil, cell, square)
        generator:setSprite(nil)
        generator:transmitCompleteItemToClients()
        generator:setCondition(100)
        generator:setFuel(100)
        generator:setConnected(true)
        generator:setActivated(true)

        spawnedGenerators[generator] = powerMeter      								-- Store the spawned generator with its associated powerMeter
    end

    cell:addToProcessIsoObjectRemove(generator) 									-- Stops generator update
    print(string.format("Power Plant: square at %d, %d, %d finished adding generator", x, y, z))
end


local function deleteGeneratorsByPowerMeter(powerMeter)								-- Function to delete all generators spawned by a specific powerMeter
    for generator, associatedPowerMeter in pairs(spawnedGenerators) do
        if associatedPowerMeter == powerMeter then
            generator:removeFromSquare()            								-- Delete the generator
            spawnedGenerators[generator] = nil
            print("Deleted generator associated with powerMeter.")
        end
    end
end


local function spawnGeneratorsAtPlayerPosition(player, numGenerators, interval)		-- Function to supply energy by spawning generators at the player's position
    if player then
        local x, y, z = player:getX(), player:getY(), player:getZ()
        for i = 1, numGenerators do
            local offsetX = (i - 1) * interval
            spawnGenerator(x + offsetX, y, z, player:getInventory():getItems():get(0))
        end
    else
        print("Unable to get player character.")
    end
end


local function powerPlantOff()														-- Function to handle the power plant turning off
    if powerPlantConnected then
        powerPlantConnected = false
        print("Power Plant is now OFF!")


        for generator, associatedPowerMeter in pairs(spawnedGenerators) do        	-- Delete all generators associated with the power plant
            generator:removeFromSquare()											-- Delete the generator
            spawnedGenerators[generator] = nil
            print("Deleted generator associated with powerMeter.")
        end
    end
end


Events.OnClientCommand.Add(function(module, command, player, args)					-- command handler for client commands
    if module ~= "PowerPlantMod" then return end

    if command == 'connectMeter' and powerPlantConnected then
        local numGenerators = tonumber(args[1]) or 5
        local interval = tonumber(args[2]) or 20
        spawnGeneratorsAtPlayerPosition(player, numGenerators, interval)
    elseif command == 'disconnectMeter' then
        deleteGeneratorsByPowerMeter(player:getInventory():getItems():get(0))
    elseif command == 'powerPlantOn' and AuxGeneratorON then						-- check aux generator is on before you can turn the power plant on
        powerPlantConnected = true
        print("Power Plant is now ON!")
    elseif command == 'powerPlantOff' then
        powerPlantOff()
	    elseif command == 'AuxGenON' then
        AuxGeneratorON = true
		        print("Auxiliary Generator is now ON")
	elseif command == "AuxGenOFF" then 
		AuxGeneratorON = false
				print("Auxiliary Generator is now OFF")
    end
end)
