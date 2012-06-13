<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Game Buzzer';
$sloodleconfig->object_code= 'GameBuzzer';
$sloodleconfig->modname    = 'furniture-1.0';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('GameBuzzer');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'time' => new SloodleConfigurationOptionText( 'time', 'misc:gamebuzzer_time', '', '00:00:00', 15 )
 ));
