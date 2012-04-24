<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE ZZText Scoreboard';
$sloodleconfig->object_code= 'zztext';
$sloodleconfig->modname    = 'scoreboard-1.0';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array();

 // If this happens on the server side, tell me about it.
$sloodleconfig->notify     = array('awards_points_change', 'awards_points_deletion', 'awards_points_round_change'); // If this happens on the server side, tell me about it.

// The original scoreboard sends a simple message per score change
// ...but we want a complete page full of scores, so we define a callback that knows how to send it.
$sloodleconfig->notify_callbacks = array(
        'awards_points_change'=>'SloodleModuleAwards::PageScoreMessage', 
        'awards_points_deletion'=>'SloodleModuleAwards::PageScoreMessage', 
        'awards_points_round_change'=>'SloodleModuleAwards::PageScoreMessage'
);
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		//'sloodlegroupid' => new SloodleConfigurationOptionText( 'sloodlegroupid', 'awards:group', '', 0, 4 ), // feature disabled
		//'sloodleshowallcontrollers' => new SloodleConfigurationOptionYesNo( 'sloodleshowallcontrollers', 'awards:showallcontrollers', 0 ), //feature disabled
                'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
                'sloodlecurrencyid' => new SloodleConfigurationOptionCurrencyChoice( 'sloodlecurrencyid', 'awards:currency', '', '', 0), 
                'sloodleobjecttitle' => new SloodleConfigurationOptionText( 'sloodleobjecttitle', 'awards:scoreboardtitle', '', 'Scoreboard', 40 ),
                'sloodleactivepage' => new SloodleConfigurationOptionText( 'sloodleactivepage', 'activepage', '', 1, 2 ),
	),
	'accesslevel' => array(
                'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_control_option()
	)
);
// The following array is for parameters that aren't supposed to be configured by the end user
// ...but depend on the object definition.
// In this case the code in our callback, SloodleModuleAwards::PageScoreMessage, needs to know this stuff.
$sloodleconfig->fixed_parameters = array(
    //'maxlinesperpage' => 15, // How many lines are shown if we have more than one page full of scores
    'linesperpage' => 2, // How many lines are shown if we have more than one page full of scores
    'charactersperline' => 40, // How many lines are shown if we have more than one page full of scores
);
?>
