<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Enemy Rezzer';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
$sloodleconfig->aliases    = array();

$sloodleconfig->field_sets = array( 
	 'generalconfiguration'=> array(
		//'configVarThatGetsSentBack'=>new SloodleConfigurationOptionYesNo( fieldname, title, description, 0 ),
        'brownzombie' => new SloodleConfigurationOptionYesNo( 'brownzombie', 'brownzombie', null, 0 ),
		'jellyfishenemy' => new SloodleConfigurationOptionYesNo( 'jellyfishenemy', 'jellyfishenemy', null, 0 )
		
   ),
	

	 
        
);
?>
