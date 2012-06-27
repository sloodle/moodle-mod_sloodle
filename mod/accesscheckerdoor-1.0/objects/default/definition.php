<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Access Checker Door';
$sloodleconfig->object_code= 'default';
$sloodleconfig->modname    = 'accesscheckerdoor-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->collections= array('SLOODLE 1.0'); // Not currently included in SLOODLE 2.0, although we may bring it back
$sloodleconfig->aliases    = array('SLOODLE 1.1 Access Checker Door');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
