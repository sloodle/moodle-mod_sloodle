<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Scoreboard';
$sloodleconfig->object_code= 'scoreboard';
$sloodleconfig->modname    = 'scoreboard-1.0';
$sloodleconfig->group      = 'activity';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Scoreboard');
$sloodleconfig->notify     = array('awards_points_change'); // If this happens on the server side, tell me about it.
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
	),
	'general' => array(
		'sloodlegroupid' => new SloodleConfigurationOptionText( 'sloodlegroupid', 'awards:group', '', 0, 4 ),
		'sloodleroundid' => new SloodleConfigurationOptionText( 'sloodleroundid', 'awards:round', '', 1, 4 ),
		'sloodlecurrencyid' => new SloodleConfigurationOptionText( 'sloodlecurrencyid', 'awards:currency', '', 1, 4 ),
                'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
		'sloodleshowallcontrollers' => new SloodleConfigurationOptionYesNo( 'sloodleshowallcontrollers', 'awards:showallcontrollers', 0 ),
	)
);
?>
