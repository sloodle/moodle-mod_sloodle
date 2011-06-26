<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE WebIntercom';
$sloodleconfig->object_code= 'webintercom';
$sloodleconfig->modname    = 'chat-1.0';
$sloodleconfig->module     = 'chat';
$sloodleconfig->module_choice_message = 'selectchatroom';
$sloodleconfig->module_no_choices_message= 'nochatrooms';
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 WebIntercom');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlelistentoobjects' => new SloodleConfigurationOptionYesNo( 'sloodlelistentoobjects', 'listentoobjects', '', 0 ),
		'sloodleautodeactivate'  => new SloodleConfigurationOptionYesNo( 'sloodleautodeactivate', 'allowautodeactivation', '', 1 ),
		'sloodlerefreshtime'     => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
	),
);
?>
