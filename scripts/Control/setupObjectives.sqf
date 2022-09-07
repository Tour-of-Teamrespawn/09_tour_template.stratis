// setup objectives using ABIS task framework

// create as many objectives as needed here. Each uses 1 lines of code. In the array it defines:
// side to create the task for
// variable name for the task
// description for the task
// title for the task 
// marker for the task location 
// position for the task marker on the map 
// task status 
// priority
// give hint when created 
// task symbol
// for more information read the wiki for the create task function https://community.bistudio.com/wiki/BIS_fnc_taskCreate

// you can see hyperlinks work using the names of markers you have made in the editor. Double click on the editor markers, and see the names that have been given.
// TOUR_objFind for example is the variable name / handle that we give the task, so we can use it now, and later on in other scripts.

[WEST, "TOUR_objFind", [format ["Find and Kill the HVT located somewhere in <marker name=""TOUR_mkr_objFind""> these buildings</marker>", name TOUR_HVT], "Kill HVT", "TOUR_mkr_objFind"], getMarkerPos "TOUR_mkr_objFind", "CREATED", -1, false, "kill"] call BIS_fnc_taskCreate;

[WEST, "TOUR_objTank", ["Destory the <marker name=""TOUR_mkr_objTank"">tank</marker> located on the hill", "Destroy Tank", "TOUR_mkr_objTank"], getMarkerPos "TOUR_mkr_objTank", "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;

[WEST, "TOUR_objTruck", ["Retreive the stolen truck from the <marker name=""TOUR_mkr_objTruck"">FOB</marker>", "Retreive Truck", "TOUR_mkr_objTruck"], getMarkerPos "TOUR_mkr_objTruck", "CREATED", -1, false, "car"] call BIS_fnc_taskCreate;

[WEST, "TOUR_objRadio", ["Destroy the <marker name=""TOUR_mkr_objRadio"">radio tower</marker> located on the hill", "Blow Up Radio Tower", "TOUR_mkr_objRadio"], getMarkerPos "TOUR_mkr_objRadio", "CREATED", -1, false, "radio"] call BIS_fnc_taskCreate;

[WEST, "TOUR_objClear", ["Destroy the <marker name=""TOUR_mkr_objClear"">radio tower</marker> located on the hill", "Clear Area", "TOUR_mkr_objClear"], getMarkerPos "TOUR_mkr_objClear", "CREATED", -1, false, "attack"] call BIS_fnc_taskCreate;

//we need to assign a variable to handle and check the object for the radio tower
TOUR_radioTower = nearestObject [(getMarkerPos "TAG_mkr_objRadio"), "Land_TTowerBig_2_F"];

//place enemy target in random house 
["TOUR_mkr_objFind", 50, TOUR_HVT] call TOUR_fnc_moveInHouse;

//create random enemies within clear area marker - in this instance we need them to be created before we make the trigger below to detect them, otherwise it will detect no enemies present and update the task!
//Hense why we have made it here and not in the setupEnemy.sqf

_ep = 	[
			2,
			4,
			"TOUR_mkr_objClear",
			"UK3CB_TKM_O",
			EAST,
			[
				["infantry", "UK3CB_TKM_O_RIF_Sentry"],
				["infantry", "UK3CB_TKM_O_IED_Sentry"],
				["infantry", "UK3CB_TKM_O_AT_Sentry"],
				["infantry", "UK3CB_TKM_O_AR_Sentry"],
				["infantry", "UK3CB_TKM_O_MG_Sentry"],
				["infantry", "UK3CB_TKM_O_UGL_Sentry"]
			],
			120
		] call TOUR_fnc_areaPatrols;

// create trigger over the marker area to check the area is sufficiently clear of enemies - there must be 3 times as many friendlies as enemies in order to occupy the area.
// alternatively you can just have it 100% clear and use the other marker activation and statements commented out below
TOUR_sieze_trigger = createTrigger["EmptyDetector", getMarkerPos "TOUR_mkr_objClear"]; 
TOUR_sieze_trigger setTriggerArea[getMarkerSize "TOUR_mkr_objClear" select 0, getMarkerSize "TOUR_mkr_objClear" select 1, markerDir "TOUR_mkr_objClear", if (markerShape "TOUR_mkr_objClear" == "RECTANGLE") then {true}else{false}];
TOUR_sieze_trigger setTriggerActivation["ANY","PRESENT",false];
TOUR_sieze_trigger setTriggerStatements["(({(side _x == WEST)&&(_x in thislist)} count allunits)>(({(side _x == EAST)&&(_x in thislist)} count allunits)*3))", "['TOUR_objClear', 'SUCCEEDED', true] call BIS_fnc_taskSetState;", ""];
//TOUR_sieze_trigger setTriggerActivation["EAST","NOT PRESENT",false];
//TOUR_sieze_trigger setTriggerStatements["true", "['TOUR_objClear', 'SUCCEEDED', true] call BIS_fnc_taskSetState;", ""];

// the while loop below checks every 2 seconds that objectives are complete or not - providing all players are alive
// it gets the state of the task, and checks if it is not classed as succeeded. If the check does not return the string "SUECCEEDED", it then looks further...
// if the condition for success is made such as "is the HVT dead" (!alive TOUR_HVT) then it will update the task to succeeded and tell everyone to create a hint on their screen.
// The checks for the tasks conditions are checked against variables. These variable names such as TOUR_HVT or TOUR_tank, are set the editor. You can double click on the unit, and you will see where the variable name is defined.
// TOUR_RC_WEST_DEAD is a variable you can use from respawn control for any side TOUR_RC_EAST_DEAD etc. It does the hard work for you!
// Once this becomes true, it means everyone has no respawn tickets, and is either dead or incapacitated, therefore unable to complete the mission.
// if they are complete, then update the task status
// putting a sleep below, and waitUntil condition, ensures enough time for playableUnits to have synced and joined, so that TOUR_RC_WEST_DEAD will be false.
waitUntil {count (playableUnits + switchableUnits) > 0};
sleep 1;
while {!TOUR_RC_WEST_DEAD} do
{
	if (("TOUR_objFind" call BIS_fnc_taskState) != "SUCCEEDED") then 
	{
		if (!alive TOUR_HVT) then 
		{
			["TOUR_objFind", "SUCCEEDED", true] call BIS_fnc_taskSetState;		
		};
	};

	if (("TOUR_objTank" call BIS_fnc_taskState) != "SUCCEEDED") then 
	{
		if (damage TOUR_tank > 0.7) then 
		{
			["TOUR_objTank", "SUCCEEDED", true] call BIS_fnc_taskSetState;		
		};
	};

	if ((("TOUR_objTruck" call BIS_fnc_taskState) != "SUCCEEDED")&&(("TOUR_objTruck" call BIS_fnc_taskState) != "FAILED")) then 
	{
		if (TOUR_truck distance (getMarkerPos "TOUR_mkr_start") < 100) then 
		{
			["TOUR_objTruck", "SUCCEEDED", true] call BIS_fnc_taskSetState;	
		};

		if (!canMove TOUR_truck) then 
		{
			["TOUR_objTruck", "FAILED", true] call BIS_fnc_taskSetState;			
		};
	};

	if (("TOUR_objRadio" call BIS_fnc_taskState) != "SUCCEEDED") then 
	{
		if (damage TOUR_radioTower > 0.7) then 
		{
			["TOUR_objRadio", "SUCCEEDED", true] call BIS_fnc_taskSetState;		
		};
	};	

	sleep 2;
};

// if the loop above is exited, then everyone must be dead
//everyone dead, end the mission and update tasks
if ("TOUR_objFind" call BIS_fnc_taskState != "SUCCEEDED") then
{
	["TOUR_objFind", "failed", false] call BIS_fnc_taskSetState;
};
if ("TOUR_objTank" call BIS_fnc_taskState != "SUCCEEDED") then
{
	["TOUR_objTank", "failed", false] call BIS_fnc_taskSetState;
};
if ("TOUR_objRadio" call BIS_fnc_taskState != "SUCCEEDED") then
{
	["TOUR_objRadio", "failed", false] call BIS_fnc_taskSetState;
};
if ("TOUR_objtruck" call BIS_fnc_taskState != "SUCCEEDED") then
{
	["TOUR_objtruck", "failed", false] call BIS_fnc_taskSetState;
};
sleep 5;
"kia" remoteExecCall ["BIS_fnc_endMissionServer", 0, true];