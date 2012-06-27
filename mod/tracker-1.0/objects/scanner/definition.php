<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Tracker - Scanner';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selecttracker';
$sloodleconfig->module_no_choices_message = 'notrackers';
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_TRACKER);
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 Tracker - Scanner', 'SLOODLE 1.2 Tracker - Scanner');
$sloodleconfig->field_sets = array( 
        'generalconfiguration' => array(
                'sloodlelistentoobjects' => new SloodleConfigurationOptionYesNo( 'sloodlelistentoobjects', 'listentoobjects', '', 0 ),
                'sloodleautodeactivate'  => new SloodleConfigurationOptionYesNo( 'sloodleautodeactivate', 'allowautodeactivation', '', 1 ),
        ),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	)
);
?>
