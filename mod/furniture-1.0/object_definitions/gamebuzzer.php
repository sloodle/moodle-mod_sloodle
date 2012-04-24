<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'GameBuzzer';
$sloodleconfig->object_code= 'GameBuzzer';
$sloodleconfig->modname    = 'furniture-1.0';
$sloodleconfig->group      = 'misc';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'time' => new SloodleConfigurationOptionText( 'time', 'misc:gamebuzzer_time', '', '00:00:00', 15 ),
 'facilitator' => new SloodleConfigurationOptionText( 'facilitator', 'misc:facilitator', '', '', 15 ),
 'facilitator' => new SloodleConfigurationOptionText( 'facilitator', 'misc:facilitator', '', '', 15 ), 
 'facilitator' => new SloodleConfigurationOptionText( 'facilitator', 'misc:facilitator', '', '', 15 ),
 'facilitator' => new SloodleConfigurationOptionText( 'facilitator', 'misc:facilitator', '', '', 15 )
 
 ));
