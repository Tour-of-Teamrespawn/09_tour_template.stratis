enableItemsDropping = 0;
disabledAI = 1;
allowProfileGlasses = 1;


// leave this code as is. It is default settings that Respawn Control will take over from
respawn = 3;
respawnDelay = 30;
respawnDialog = 1;
respawnTemplates[] = {"tickets"};
respawnVehicleDelay = 30;

onLoadMissionTime = true;
overviewPicture = "";

// Vanilla Radio Channels
disableChannels[] = {
	{0, false, true}, // Disable Global voice chat
	{1, false, true}, // Disable Side voice chat
	{2, false, true}, // Disable Command voice chat
	{3, false, true}, // Disable Group voice chat
	{4, false, true}, // Disable Vehicle voice chat
	{5, false, true}  // Disable Direct voice chat
};

// Add own steam ID if required for debug during play purposes
enableDebugConsole[] = {};