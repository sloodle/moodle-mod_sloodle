<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Quiz Pile-On';
$sloodleconfig->object_code= 'quiz-pileon';
$sloodleconfig->modname    = 'quiz-1.0';
$sloodleconfig->module     = 'quiz';
$sloodleconfig->module_choice_message = 'selectquiz';// TODO: There's some extra craziness to make sure we only have sloodle stuff
$sloodleconfig->module_no_choices_message = 'noquizzes';
$sloodleconfig->group      = 'activity';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Quiz Pile-On');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlerepeat' => new SloodleConfigurationOptionYesNo( 'sloodlerepeat', 'repeatquiz', 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlerandomize', 'randomquestionorder', 0 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodledialog', 'usedialogs', 0 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', 0 ),
	)
);
?>
