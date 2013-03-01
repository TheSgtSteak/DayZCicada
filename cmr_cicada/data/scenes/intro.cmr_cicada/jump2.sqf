_group = _this select 0;
_flz = _this select 1;

if ( (typename _group != "GROUP") or (typename _flz != "OBJECT") ) exitwith {hintSilent "Invalid Parameters parsed to Eject";};

sleep 0.2;

{
  unassignvehicle _x;
  [_x,1000] exec "ca\air2\halo\data\Scripts\Halo_init.sqs";
  sleep 0.2;
} foreach units _group;

exit;