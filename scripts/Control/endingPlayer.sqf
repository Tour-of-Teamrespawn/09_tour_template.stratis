_player = _this select 0;
_officer = _this select 1;
_action = _this select 2;

if (!isDedicated) then
{
	TOUR_officer removeAction _action;
};

_player directSay "TOUR_reportingback";
sleep 5;
_officer directSay "TOUR_welcomeback";
sleep 5;

_success = if 
				(
					("TOUR_objFind" call BIS_fnc_taskState == "SUCCEEDED")
					&&
					("TOUR_objTank" call BIS_fnc_taskState == "SUCCEEDED")
					&&
					("TOUR_objRadio" call BIS_fnc_taskState == "SUCCEEDED")
					&&
					("TOUR_objtruck" call BIS_fnc_taskState == "SUCCEEDED")
					&&
					("TOUR_objClear" call BIS_fnc_taskState == "SUCCEEDED")
				) 
				then {true} else {false};

if (isServer) then
{
	[]spawn
	{
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
		if ("TOUR_objClear" call BIS_fnc_taskState != "SUCCEEDED") then
		{
			["TOUR_objClear", "failed", false] call BIS_fnc_taskSetState;
		};
	};	
};

if (!_success) then
{
	_player directSay "TOUR_playernotgood";
	sleep 5;
	_officer directSay "TOUR_officernotgood";
}else
{
	_player directSay "TOUR_playergood";
	sleep 5;
	_officer directSay "TOUR_officergood";
};

sleep 3;

if (_success) then
{
	"complete" remoteExecCall ["BIS_fnc_endMissionServer", 0, true];
}else
{
	"aborted" remoteExecCall ["BIS_fnc_endMissionServer", 0, true];
};
