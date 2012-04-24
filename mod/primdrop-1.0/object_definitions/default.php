<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE PrimDrop';
$sloodleconfig->object_code= 'default';
$sloodleconfig->modname    = 'primdrop-1.0';
$sloodleconfig->module     = 'assignment';
$sloodleconfig->module_choice_message = 'selectassignment';
$sloodleconfig->module_no_choices_message = 'noassignments'; 
$sloodleconfig->module_filters = array( 'assignmenttype' => 'sloodleobject');
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 PrimDrop');
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
);
?>
