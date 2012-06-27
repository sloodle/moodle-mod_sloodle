<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Demo Object';
$sloodleconfig->group      = 'misc';
$sloodleconfig->collections= array('SLOODLE 1.0'); // Not currently displayed in SLOODLE 2.0
$sloodleconfig->aliases    = array('SLOODLE 1.1 Demo Object');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
?>
