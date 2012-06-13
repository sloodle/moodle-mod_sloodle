<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Game Buzzer';
$sloodleconfig->object_code= 'gamebuzzer';//right now, should be same as object definition filename
$sloodleconfig->modname    = 'gaming-1.0';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('GameBuzzer');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'time' => new SloodleConfigurationOptionText( 'time', 'misc:gamebuzzer_time', '', '00:00:00', 15 )
 ));
