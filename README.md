# PZPowerPlantsMod
I am currently trying to make a function that spawns arrays of generators at the player position (Server-side) and call that function from a script that will add the contextmenu option (client-side) to activate the generator spawning process.
The issues i'm having are using sendClientCommand to trigger my serverside function. As of now the generator spawning function is only spawning generators at a specified location (10590, 9737, 2) and it triggers every in-game ten minutes so it will trigger regardless of any extra calls.
Also when i try to use sendClientCommand i get this error:
sendClientCommand: can't save key,value=1.0,zombie.characters.IsoPlayer@6b423a75
