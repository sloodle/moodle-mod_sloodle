<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'PinkMagicPlant';
$sloodleconfig->object_code= 'pinkmagicplant';
$sloodleconfig->modname    = 'interaction-1.0';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
        'awards' => array_merge( 
		$sloodleconfig->awards_deposit_options( array( 'water' => 'awards:interactwithobjectplus' ) ),
		$sloodleconfig->awards_require_options( array( 'water' => 'awards:interactwithobjectrequires' ) ), 
		$sloodleconfig->awards_withdraw_options( array( 'water' => 'awards:interactwithobjectminus' ) ),

		$sloodleconfig->awards_deposit_options( array( 'complete' => 'awards:completeplus' ) ),
		$sloodleconfig->awards_require_options( array( 'complete' => 'awards:completerequires' ) ), 
		$sloodleconfig->awards_withdraw_options( array( 'complete' => 'awards:completeminus' ) ),

        $sloodleconfig->awards_deposit_options( array( 'flower' => 'awards:flowerplus' ) ),
        $sloodleconfig->awards_require_options( array( 'flower' => 'awards:flowerrequires' ) ),
        $sloodleconfig->awards_withdraw_options( array( 'flower' => 'awards:flowerminus' ) )

	 )
        
);
?>
