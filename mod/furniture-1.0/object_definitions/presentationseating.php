<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'PresentationSeating';
$sloodleconfig->object_code= 'PresentationSeating';
$sloodleconfig->modname    = 'furniture-1.0';
$sloodleconfig->group      = 'misc';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'color' => new SloodleConfigurationOptionText( 'color', 'misc:presentation_seating', '', '<0,0,1>', 40 ) 
 ));
