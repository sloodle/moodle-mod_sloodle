<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Quiz Chair';
$sloodleconfig->module     = 'quiz';
$sloodleconfig->module_choice_message = 'selectquiz';// TODO: There's some extra craziness to make sure we only have sloodle stuff
$sloodleconfig->module_no_choices_message = 'noquizzes';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.2 Quiz Chair', 'SLOODLE 1.1 Quiz Chair');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlerepeat' => new SloodleConfigurationOptionYesNo( 'sloodlerepeat', 'repeatquiz', null, 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlerandomize', 'randomquestionorder', null, 1 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodledialog', 'usedialogs', null, 1 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', null, 0 ),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
        //'awards' => array_merge( $sloodleconfig->awards_require_options(), $sloodleconfig->awards_deposit_options( array( 'answerquestion' => 'awards:answerquestionaward' ) ) )
        'awards' => $sloodleconfig->awards_deposit_options( array( 'answerquestion' => 'awards:answerquestionaward' ) ) 
);
?>
