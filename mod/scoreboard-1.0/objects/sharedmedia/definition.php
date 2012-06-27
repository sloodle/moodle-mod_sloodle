<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Scoreboard Shared Media';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('SLOODLE 2.0 Deprecated');
$sloodleconfig->aliases    = array('SLOODLE 1.1 Scoreboard');
$sloodleconfig->notify     = array('awards_points_change', 'awards_points_deletion', 'awards_points_round_change'); // If this happens on the server side, tell me about it.
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		//'sloodlegroupid' => new SloodleConfigurationOptionText( 'sloodlegroupid', 'awards:group', '', 0, 4 ), // feature disabled
		//'sloodleshowallcontrollers' => new SloodleConfigurationOptionYesNo( 'sloodleshowallcontrollers', 'awards:showallcontrollers', 0 ), //feature disabled
                'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
		'sloodlecurrencyid' => new SloodleConfigurationOptionCurrencyChoice( 'sloodlecurrencyid', 'awards:currency', '', '', 0), 
                'sloodleobjecttitle' => new SloodleConfigurationOptionText( 'sloodleobjecttitle', 'awards:scoreboardtitle', '', 'Scoreboard', 40 ),
	),
	'accesslevel' => array(
                'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_control_option()
	)
);
?>
