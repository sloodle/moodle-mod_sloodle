<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Teleporter';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration'=> array(
        'destination' => new SloodleConfigurationOptionText( 'destination', 'teleporter:destination', '', '<100,100,100>', 50 )
   ),
        'awards' => array_merge( 
		$sloodleconfig->awards_deposit_options( array( 'accessteleporter' => 'awards:interactwithobjectplus' ) ),
		$sloodleconfig->awards_require_options( array( 'accessteleporter' => 'awards:interactwithobjectrequires' ) ), 
		$sloodleconfig->awards_withdraw_options( array( 'accessteleporter' => 'awards:interactwithobjectminus' ) )

	 )
        
);

