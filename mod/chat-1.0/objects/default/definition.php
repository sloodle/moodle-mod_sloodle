<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE WebIntercom';
$sloodleconfig->module     = 'chat';
$sloodleconfig->module_choice_message = 'selectchatroom';
$sloodleconfig->module_no_choices_message= 'nochatrooms';
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 WebIntercom');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		'sloodlelistentoobjects' => new SloodleConfigurationOptionYesNo( 'sloodlelistentoobjects', 'listentoobjects', '', 0 ),
		'sloodleautodeactivate'  => new SloodleConfigurationOptionYesNo( 'sloodleautodeactivate', 'allowautodeactivation', '', 1 ),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
	)
//        'awards' => $sloodleconfig->awards_setting_options() // Allows you to award points for taking part in a discussion. Not sure if we want to display this or not...
//        'awards' => $sloodleconfig->awards_pay_options()

);
?>
