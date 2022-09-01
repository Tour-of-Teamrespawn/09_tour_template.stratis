// This file is run before the initServer.sqf and initLocalPlayer.sqf
// Code in here is run for all machines!!!

// Causes a big header in the RPT which makes the mission easier to find for debugging when checking the RPT file
_d = execVM "scripts\general\debugRPT.sqf";
waitUntil {scriptDone _d};

// Run parameter file for lobby settings and respawn control
_p = execVM "params.sqf";
waitUntil {scriptDone _p};

// Attach the logic module in the editor as a placeholder to pass information for the task system.
_a = TOUR_logic execVM "a2s_multitask.sqf";
waitUntil {scriptDone _a};

enableRadio false;
{
	_x setVariable ["BIS_noCoreConversations",true];
} forEach allUnits;

TOUR_HQ = [WEST, "HQ"];

// Set up lots of helpful functions in the scripts\functions folder.
_fn = execVM "scripts\functions\functions_init.sqf";
waitUntil {scriptDone _fn};

// Change value in meters - larger numbers will affect performance for graphics and AI reactions!!!
// If you are using aircraft, usually 5000+
setViewDistance 2500;

//setup support interface - even if no support is used, you can still use this to radio in to end the mission.

_siAction = if (true) then
{
	"(alive player) && ([player, ""ACRE_PRC148""] call acre_api_fnc_hasKindOfRadio)"
}else
{
	"(alive player) && (""ItemRadio"" in (assignedItems player))"
};

_si = 
[
	TOUR_logic,
	WEST,
	_siAction,
	"(alive player) && (player == leader group player) && (player distance TOUR_Officer < 2.5) && (isNil ""TOUR_mission_ending"")",
	false,
	[
		[
			"artillery",
			"Thunder One",
			[
				["8rnd_82mm_mo_shells", 0],
				["8rnd_82mm_mo_flare_white", 0],
				["8rnd_82mm_mo_smoke_white", 0],
				["8rnd_82mm_mo_guided", 0],
				["8rnd_82mm_mo_lg", 0],
				["32rnd_155mm_mo_shells", 0],
				["6rnd_155mm_mo_smoke", 30],
				["2rnd_155mm_mo_guided", 0],
				["2rnd_155mm_mo_lg", 0],
				["6rnd_155mm_mo_mine", 0],
				["6rnd_155mm_mo_at_mine", 0],
				["2rnd_155mm_mo_cluster", 0]
			]
		],
		[
			"helicopter",
			TOUR_heli_1,
			"Dusty One",
			[
				"Circle",
				"Land",
				"Land (Engine Off)",
				"Move To",
				"Pickup",
				"Return To Base",
				"toggle engine"
			],
			getPosATL TOUR_heli_1
		],
		[
			"helicopter",
			TOUR_heli_2,
			"Dusty Two",
			[
				"Circle",
				"Land",
				"Land (Engine Off)",
				"Move To",
				"Pickup",
				"Return To Base",
				"toggle engine"
			],
			getPosATL TOUR_heli_2
		],
		[
			"helicopter",
			TOUR_heli_3,
			"Dusty Three",
			[
				"CAS", 
				"CAS (Laser Designation)",
				"Move To",
				"Return To Base",
				"toggle engine"
			],
			getPosATL TOUR_heli_3
		]
	],
	"TOUR_fnc_endRadio",
	{true}
] execVM "scripts\TOUR_SI\TOUR_SI_init.sqf";

TOUR_init_completed = true;