if isClient() then return end

---spawn generator at coords
---@param x number
---@param y number
---@param z number
local function spawnGenerator(x, y, z)
    print(string.format("Power Plant: square at %d, %d, %d start adding generator",x,y,z))
    local cell = getCell()
    local square = cell:getOrCreateGridSquare(x,y,z)
    ---square test
    if square:getChunk() == nil then
        print(string.format("Power Plant: square at %d, %d, %d has no chunk",x,y,z))
        square:discard()
        return
    end
    ---generator test
    ---should also check if sprite is nil and loop all objects
    local generator = square:getGenerator()
    if generator == nil then
        print(string.format("Power Plant: square at %d, %d, %d has no generator",x,y,z))
        generator = IsoGenerator.new(nil, cell, square)
        generator:setSprite(nil)
        generator:transmitCompleteItemToClients()
        generator:setCondition(100)
        generator:setFuel(100)
        generator:setConnected(true)
        generator:setActivated(true)
    end
    ---stops generator update
    cell:addToProcessIsoObjectRemove(generator)
    print(string.format("Power Plant: square at %d, %d, %d finished adding generator",x,y,z))
end

---try spawn all generators
---@param startX number
---@param startY number
---@param startZ number
---@param numGenerators number
---@param interval number
local function spawnGeneratorsAtIntervals(startX, startY, startZ, numGenerators, interval)
    for i = 1, numGenerators do
        local x = startX + (i - 1) * interval
        local y = startY
        local z = startZ
        spawnGenerator(x, y, z)
    end
end

---global for file reload support, can be used from lua console
_G.spawnGeneratorTest = spawnGeneratorsAtIntervals

Events.EveryTenMinutes.Add(function ()
	--TEST--
	--if mainsConnected then
	--TEST--
    ---replace local or call global
    spawnGeneratorsAtIntervals = _G.spawnGeneratorTest

    local startX, startY, startZ = 10590, 9737, 2
    local numGenerators = 5
    local interval = 20

    spawnGeneratorsAtIntervals(startX, startY, startZ, numGenerators, interval)
end)

-- Register the command handler for client commands
Events.OnClientCommand.Add(function(command, player, args)
    if command == 'spawnGenerators' then
        spawnGeneratorsAtIntervals(player, unpack(args))
    end
end)