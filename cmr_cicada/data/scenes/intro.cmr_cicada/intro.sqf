// Map Intro Script by Tupolov Copyright 2011
// Inspired by Grizzle's Director Add-on
// v1.0 - Feb 2011

// INSTRUCTIONS =========================================
// Create a basic intro mission for your map, include at least a player unit, a vehicle and an infantry unit. Give the vehicle(s) and unit(s) a few waypoints.
// Place the Preload Manager Module on the map and set it's initialization to "sqf = this execVM "initintro.sqf""
// Ensure this script is in the mission folder
// Edit the settings below as appropriate
// Preview the intro
// =========================================================

// EDIT THESE SETTINGS ==================================

// Set Music
// Use the next line for music (make sure you add any custom music to your description.ext)

private ["_subjects","_infantry","_relpos","_cam","_tracks","_credits","_creditmsg","_creditindex","_cameraTarget","_fov","_dist","_alt","_stopScene","_startTime","_stopTime","_newTarget","_istep","_groupTarget","_iterator","_switchDir","_angle","_targetPos","_sceneChoice","_subChoice","_sideMask","_author","_map","_version","_creditscount","_startangle","_authormsg","_mapmsg"];
_tracks = ["EP1_Track01","Track13_Sharping_Knives","Track10_Logistics","Track03_First_To_Fight","Track02_Insertion","Ambient07_Manhattan","Ambient07_Manhattan","Track13_Sharping_Knives"]; 

// Credits
_credits = [];

// Set Side to show
_sideMask = WEST;

// Author & Map details
_author = "Commander";
_map = "Cicada";
_version = "v1.2";

// DO NOT EDIT BELOW =======================================

_creditscount = count _credits;
_creditindex = 0;

// Set date and time (between 7am and 4pm)
setdate [2012,ceil random 12,ceil random 28,7 + round(random 9),0];

// Get List of vehicle subjects from Mission
_subjects = [];
{ if ((side _x == _sideMask) && (_x != player)) then 
	{
	_subjects = _subjects + [_x];
	};
} foreach vehicles;

// Get List of Man units from Mission
_infantry =[];
{ if ((side _x == _sideMask) && (_x != player) && (_x isKindOf "MAN")) then 
	{
		_infantry = _infantry + [_x];
	};
} foreach allUnits;


// Set up visual effects
0 setOvercast random 0.85;

"colorCorrections" ppEffectAdjust [1, 1, -0.004, [0.0, 0.0, 0.0, 0.0], [1, 0.8, 0.6, 0.5],  [0.199, 0.587, 0.114, 0.0]];  
"colorCorrections" ppEffectCommit 0;  
"colorCorrections" ppEffectEnable true ;
"filmGrain" ppEffectEnable true;
"filmGrain" ppEffectAdjust [0.04, 1, 1, 0.1, 1, false];
"filmGrain" ppEffectCommit 0;
	
"radialBlur" ppEffectEnable false;
"wetDistortion" ppEffectEnable false;
"chromAberration" ppEffectEnable false;
"dynamicBlur" ppEffectEnable false;

// Set Music
playmusic (_tracks select (floor(random count _tracks)));

0 fadeSound 0.02;
0.5 fadeMusic 1;
enableRadio false;

// Introductory Scenes =======================================================

titleCut ["", "BLACK FADED", 0];

// Close up of subject
_cameraTarget = (_subjects select (floor(random count _subjects)));

_cam = "camera" camCreate (position _cameraTarget);
_cam cameraEffect ["INTERNAL", "BACK"];
showCinemaBorder true;
cameraEffectEnableHUD false;
showHUD false;

waituntil {(preloadcamera (position _cameraTarget)) || time > 5};
setacctime 0;
waituntil {!isnil "BIS_WeatherPostprocess_init"};
setacctime 1;

_cam attachTo [_cameraTarget,[2,15,1]];
_cam camPrepareTarget _cameraTarget;
_cam camPrepareFOV 0.6;
_cam camCommitPrepared 0;
waituntil {camcommitted _cam};

// Author details
titleCut ["", "BLACK IN", 5];

//0 cutRsc ["Picture2", "PLAIN"]; // Insert Custom Pic

_authormsg = format ["%1 presents...", _author]; // Create a message
1 cutText [_authormsg, "PLAIN DOWN"]; // Place in middle of screen

//[str (author),  str("presents...")] spawn BIS_fnc_infoText; // BIS OA Text
sleep 8;

//Close up of subject
_cameraTarget = (_subjects select (floor(random count _subjects)));
waituntil {(preloadcamera (position _cameraTarget)) || time > 5};
_cam attachTo [_cameraTarget,[-2,15,-1]];
_cam camPrepareTarget _cameraTarget;
_cam camPrepareFOV 0.6;
_cam camCommitPrepared 0;
waituntil {camcommitted _cam};

// Map Details
titleCut ["", "BLACK IN", 5];

//0 cutRsc ["Picture1", "PLAIN"]; // Insert Custom Pic

_mapmsg = format ["%1 - version %2", _map, _version];
1 cutText [_mapmsg, "PLAIN DOWN"];

sleep 8;

_cam cameraEffect ["terminate","back"];
camDestroy _cam;

titleCut ["", "BLACK FADED", 0];

//  End Introductory Scenes =======================================================
		
// Loop through series of scenes
while { ((count _subjects) > 0) } do {

	// Display Credits
	if (_creditindex < _creditscount) then {
		_creditmsg = format ["%1", (_credits select _creditindex)];
		1 cutText [_creditmsg,"PLAIN DOWN"];
		sleep 0.001;
		_creditindex = _creditindex + 1;
	};
	
	//Choose a subject
	_subChoice = (round(random 1));
	if (_subChoice == 0) then {
		_cameraTarget = (_subjects select (floor(random count _subjects)));
	} else {
		_cameraTarget = (_infantry select (floor(random count _infantry)));
	};
	
	// If the subject is a Man and he is in a vehicle, make the vehicle the subject
	if (vehicle _cameraTarget != _cameraTarget) then {
		_cameraTarget = vehicle _cameraTarget;
	};
	
	// Make sure the subject is not dead or fatally wounded
	if ((alive _cameraTarget) || ((damage _cameraTarget) < 0.4)) then {
		
		// Destroy last camera
		_cam cameraEffect ["terminate","back"];
		camDestroy _cam;
		
		// Create new camera
		_cam = "camera" camCreate (position _cameraTarget);
		showCinemaBorder true;
		cameraEffectEnableHUD false;
		showHUD false;
		
		// Randomly set a Field of View
		_fov = 0.2+(random 0.5);
	
		// Randomly pick a number (0-5 Flyby, 6-7 First Person, 8-10 Follow, 11 Pan)
		_sceneChoice = (round(random 11)); 
		
		// Set up scene and Fade into the shot
		_cam camPrepareTarget _cameraTarget;
		_cam camPrepareFOV _fov;
		titleCut ["", "BLACK IN", 4];

		// Fly By
		if (_sceneChoice < 7) then {
			if (_cameraTarget iskindof "MAN") then {
				x = 10-(round(random 20));
				y = 10-(round(random 20));
				z = 1+(round(random 2));			
			} else {
				x = (round(random 120));
				y = (round(random 120));
				z = 60-(round(random 120));
			};
			_relpos = [x * cos(random 180), y * sin(random 180), z];
			_cam camPrepareRelPos _relpos;
			_cam camSetTarget _cameraTarget;
			_cam camSetRelPos _relpos;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			sleep 4;
		};
		
		// First Person
		if ((_sceneChoice > 6) && (_sceneChoice < 8)) then {
			_cam camPrepareRelPos (position _cameraTarget);
			_cam cameraEffect ["terminate","back"];
			camDestroy _cam;
			_cameraTarget switchCamera "INTERNAL";
			sleep 4;
		};
		
		// Follow
		if ((_sceneChoice >7) && (_sceneChoice < 9)) then {
			// Check to see if it is a Man, if so get closer
			if (_cameraTarget iskindof "MAN") then {
				x = (2-(round(random 4))) * cos(random 180);
				y = (2+(round(random 8)));
				z = (1+(round(random 1)));				
			} else {
				_fov = _fov + 0.3;
				x = (5-(round(random 10))) * cos(random 180);
				y = (12+(round(random 8)));
				z = (5-(round(random 10))) * sin(random 180);
			};

			_relpos = [x , y, z];
			_cam attachTo [_cameraTarget,_relpos];
			_cam camSetTarget _cameraTarget;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			sleep 4;
		};
		
		// Pan
		if (_sceneChoice > 8) then {
			// If the target is a person, get closer
			if (_cameraTarget iskindof "MAN") then {
				_dist = 1+(random 4);
				_alt = 1+(random 2);
			} else {
				_dist = (sizeOf (typeOf _cameraTarget)) + (random 10);
                _alt = ((random _dist)/3) + 2; 
			};
			
			_stopScene = false;
			_startTime = time;
			_stopTime = _startTime + 4;
			_newTarget = objNull;
			_istep = 0.22 + (random 3) * (0.001 * 1);
			_groupTarget = createGroup sideLogic;
			_newTarget = _groupTarget createUnit ["Logic", (position _cameraTarget), [], 0, "NONE"];
			_iterator = 0;
			_switchDir = (round(random 1));
			_angle = 0;
			_targetPos = [];
			x = (position _cameraTarget select 0) + _dist;
			y = (position _cameraTarget select 1) + _dist;
			z = (position _cameraTarget select 2) + _alt;
			_relpos = [x , y, z];
			_cam camSetTarget _newTarget;
			_cam camSetPos _relpos;
			_cam camSetFOV _fov;
			_cam cameraEffect ["INTERNAL", "BACK"];
			_cam camCommit 0;
			_startangle = [_cam,_cameraTarget] call BIS_fnc_relativeDirTo;
			_startangle = _startangle % 360;
				
			while {!_stopScene} do {
				_iterator = _iterator + 1;
				_angle = _startangle + (_iterator * _istep);
				if (_switchDir == 0) then {
					_targetPos = [x + _dist * cos(_angle), y + _dist * sin(_angle), z];
				} else {
					_targetPos = [x + _dist * cos(_angle), y - _dist * sin(_angle), z];
				};
				_newTarget setPos _targetPos;
				sleep 0.001;
				if (time > _stopTime) then {_stopScene = true};
			};
			deleteVehicle _newTarget;
			deleteGroup _groupTarget;
		};
	};
};

//exit
_cam cameraEffect ["terminate","back"];
camDestroy _cam;
exit;

