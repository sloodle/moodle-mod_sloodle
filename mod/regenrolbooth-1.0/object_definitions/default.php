<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE RegEnrol Booth';
$sloodleconfig->object_code= 'regenrolbooth';
$sloodleconfig->modname    = 'regenrolbooth-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 RegEnrol Booth');
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
	),
);
?>
