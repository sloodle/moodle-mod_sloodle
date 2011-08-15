<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Quiz Pile-On';
$sloodleconfig->object_code= 'default';
$sloodleconfig->modname    = 'quiz_pile_on-1.0';
$sloodleconfig->module     = 'quiz';
$sloodleconfig->module_choice_message = 'selectquiz';// TODO: There's some extra craziness to make sure we only have sloodle stuff
$sloodleconfig->module_no_choices_message = 'noquizzes';
$sloodleconfig->group      = 'activity';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Quiz Pile-On');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlerepeat' => new SloodleConfigurationOptionYesNo( 'sloodlerepeat', 'repeatquiz', null, 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlerandomize', 'randomquestionorder', null, 1 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', null, 0 ),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option()
	)

);
?>
