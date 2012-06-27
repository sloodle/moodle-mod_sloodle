<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Locked Door';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
        'awards' => array_merge( 
		$sloodleconfig->awards_deposit_options( array( 'knockknock' => 'awards:interactwithobjectplus' ) ),
		$sloodleconfig->awards_require_options( array( 'knockknock' => 'awards:interactwithobjectrequires' ) ), 
		$sloodleconfig->awards_withdraw_options( array( 'knockknock' => 'awards:interactwithobjectminus' ) )

	 )
        
);
