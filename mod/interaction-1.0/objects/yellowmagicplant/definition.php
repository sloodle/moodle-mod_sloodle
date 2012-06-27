<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Magic Plant (Yellow)';
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
        //'awards' => $sloodleconfig->awards_deposit_options( array( 'touch' => 'awards:answerquestionaward' ) ) 
        //'awards' => $sloodleconfig->awards_setting_options() // Allows you to award points for taking part in a discussion. Not sure if we want to display this or not...
//        'awards' => $sloodleconfig->awards_pay_options()


);
?>
