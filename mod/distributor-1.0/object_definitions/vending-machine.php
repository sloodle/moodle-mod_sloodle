<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Vending Machine';
$sloodleconfig->object_code= 'distributor';
$sloodleconfig->modname    = 'distributor-1.0';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectdistributor';
$sloodleconfig->module_no_choices_message= 'nodistributorinterface';
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_DISTRIB );
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Vending Machine');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 3600, 8),
	),
);
?>
