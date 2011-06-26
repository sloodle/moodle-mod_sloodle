<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Password Reset';
$sloodleconfig->object_code= 'passwordreset';
$sloodleconfig->modname    = 'pwreset-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Password Reset');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'      => $sloodleconfig->access_level_server_option(),
	)
);
?>
