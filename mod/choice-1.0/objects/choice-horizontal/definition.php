<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Choice (Horizontal)';
$sloodleconfig->module     = 'choice';
$sloodleconfig->module_choice_message = 'selectchoice';
$sloodleconfig->module_no_choices_message= 'nochoices';
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 1.0'); // No longer displayed in SLOODLE 2.0 - settled on a single vertical one
$sloodleconfig->aliases    = array('SLOODLE 1.1 Choice (Horizontal)');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
		'sloodlerelative' => new SloodleConfigurationOptionYesNo( 'sloodlerelative', 'relativeresults', ''  ),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	)
);
?>
