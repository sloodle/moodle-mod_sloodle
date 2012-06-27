<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Sofa';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('sofa');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'color' => new SloodleConfigurationOptionText( 'color', 'misc:sofa', '', '<0,1,0>', 40 ) 
	 ));
