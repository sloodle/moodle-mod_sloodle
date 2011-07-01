<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE PrimDrop';
$sloodleconfig->object_code= 'primdrop';
$sloodleconfig->modname    = 'primdrop-1.0';
$sloodleconfig->module     = 'assignment';
$sloodleconfig->module_choice_message = 'selectassignment';
$sloodleconfig->module_no_choices_message = 'noassignments'; 
$sloodleconfig->module_filters = array( 'assignmenttype' => 'sloodleobject');
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 PrimDrop');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
);
?>
