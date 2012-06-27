<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Circle Seating';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('CircleSeating');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'color' => new SloodleConfigurationOptionText( 'color', 'misc:presentation_seating', '', '<0,0,1>', 40 ) 
 ));
