<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Access Checker';
$sloodleconfig->group      = 'registration';
$sloodleconfig->collections= array('SLOODLE 1.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 Access Checker');
$sloodleconfig->field_sets = array( 
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
?>
