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
        'ossl_message' => new SloodleConfigurationOptionText( 'ossl_message', 'ossl_message:ossl_message', '', '', 50 ),
   )

        
);

