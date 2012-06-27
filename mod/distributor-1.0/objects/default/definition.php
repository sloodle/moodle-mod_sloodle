<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE 1.1 Vending Machine';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectdistributor';
$sloodleconfig->module_no_choices_message= 'nodistributorinterface';
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_DISTRIB );
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 1.0'); // Replaced in SLOODLE 2.0 with a new, incompatible vending machine using http-in
$sloodleconfig->aliases    = array();
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
?>
