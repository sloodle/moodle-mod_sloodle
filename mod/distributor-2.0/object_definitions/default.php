<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Vending Machine';
$sloodleconfig->object_code= 'default';
$sloodleconfig->modname    = 'distributor-2.0';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectdistributor';
$sloodleconfig->module_no_choices_message= 'nodistributorinterface';
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_DISTRIB );
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 2.0 Vending Machine');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 3600, 8),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option()
	),
	'awards' => $sloodleconfig->awards_require_options()
);
$sloodleconfig->capabilities = array('distributor_send_object_http_in');
?>
