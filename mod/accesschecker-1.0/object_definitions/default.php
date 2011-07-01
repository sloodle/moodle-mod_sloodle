<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Access Checker';
$sloodleconfig->object_code= 'access-checker';
$sloodleconfig->modname    = 'accesschecker-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = false;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Access Checker');
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
?>
