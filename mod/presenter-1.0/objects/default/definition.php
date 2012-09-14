<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Presenter (Parcel Media)';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectpresenter';
$sloodleconfig->module_no_choices_message = 'nopresenters'; 
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_PRESENTER); 
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 1.0'); // Deprecated as of SLOODLE 2.0
$sloodleconfig->aliases    = array('SLOODLE Presenter', 'SLOODLE 1.1 Presenter');
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'      => $sloodleconfig->access_level_server_option(),
	),
);
?>
