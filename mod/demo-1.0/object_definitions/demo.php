<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Demo Object';
$sloodleconfig->object_code= 'demo';
$sloodleconfig->modname    = 'demo-1.0';
$sloodleconfig->group      = 'misc';
$sloodleconfig->show       = false;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Demo Object');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
?>
