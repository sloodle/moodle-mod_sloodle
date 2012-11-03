<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'OSSL Teleporter';
$sloodleconfig->group      = 'activity';
$sloodleconfig->required_grid_features= array('ossl');
$sloodleconfig->collections= array('Development Fire A');//This is just a group of things I am working on right now.  Later we will move this to a release collection
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration'=> array(
        'region' => new SloodleConfigurationOptionText( 'region', 'ossl_teleporter:region', '', '', 50 ),
        'landing_point' => new SloodleConfigurationOptionText( 'landing_point', 'ossl_teleporter:landing_point', '<100,100,100>', '', 50 ),
        'look_at' => new SloodleConfigurationOptionText( 'look_at', 'teleporter:look_at', '', '<1,1,1>', 50 )
   ),
        'awards' => array_merge( 
		$sloodleconfig->awards_deposit_options( array( 'accessteleporter' => 'awards:interactwithobjectplus' ) ),
		$sloodleconfig->awards_require_options( array( 'accessteleporter' => 'awards:interactwithobjectrequires' ) ), 
		$sloodleconfig->awards_withdraw_options( array( 'accessteleporter' => 'awards:interactwithobjectminus' ) )

	 )
        
);

