-- Track spawned generators by powerMeter
local spawnedGenerators = {}

-- Function to spawn a generator at given coordinates
local function spawnGenerator(x, y, z, powerMeter)
    print(string.format("Power Plant: square at %d, %d, %d start adding generator", x, y, z))
    local cell = getCell()
    local square = cell:getOrCreateGridSquare(x, y, z)

    -- Square test
    if square:getChunk() == nil then
        print(string.format("Power Plant: square at %d, %d, %d has no chunk", x, y, z))
        square:discard()
        return
    end

    -- Generator test
    local generator = square:getGenerator()
    if generator == nil then
        print(string.format("Power Plant: square at %d, %d, %d has no generator", x, y, z))
        generator = IsoGenerator.new(nil, cell, square)
        generator:setSprite(nil)
        generator:transmitCompleteItemToClients()
        generator:setCondition(100)
        generator:setFuel(100)
        generator:setConnected(true)
        generator:setActivated(true)

        -- Store the spawned generator with its associated powerMeter
        spawnedGenerators[generator] = powerMeter
    end

    -- Stops generator update
    cell:addToProcessIsoObjectRemove(generator)
    print(string.format("Power Plant: square at %d, %d, %d finished adding generator", x, y, z))
end

-- Function to delete all generators spawned by a specific powerMeter
local function deleteGeneratorsByPowerMeter(powerMeter)
    for generator, associatedPowerMeter in pairs(spawnedGenerators) do
        if associatedPowerMeter == powerMeter then
            -- Delete the generator
            generator:removeFromSquare()
            spawnedGenerators[generator] = nil
            print("Deleted generator associated with powerMeter.")
        end
    end
end

-- Function to spawn generators at the player's position
local function spawnGeneratorsAtPlayerPosition(player, numGenerators, interval)
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

-- Global for file reload support, can be used from the Lua console
_G.spawnGeneratorsAtPlayerPosition = spawnGeneratorsAtPlayerPosition

-- Register the command handler for client commands
Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "PowerPlantMod" then return end
    if command == 'spawnGenerators' then
        local numGenerators = tonumber(args[1]) or 5  -- Default to 5 generators if argument is missing or not a number
        local interval = tonumber(args[2]) or 20  -- Default to 20 if argument is missing or not a number
        spawnGeneratorsAtPlayerPosition(player, numGenerators, interval)
    elseif command == 'deleteGens' then
        deleteGeneratorsByPowerMeter(player:getInventory():getItems():get(0))
    end
end)