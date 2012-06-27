<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE MetaGloss';
$sloodleconfig->module     = 'glossary';
$sloodleconfig->module_choice_message = 'selectglossary';
$sloodleconfig->module_no_choices_message = 'noglossaries'; 
$sloodleconfig->module_filters = array( ); // TODO
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 MetaGloss');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlepartialmatches' => new SloodleConfigurationOptionYesNo( 'sloodlepartialmatches', 'showpartialmatches', null, 1 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlesearchaliases', 'searchaliases', null, 0 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodlesearchdefinitions', 'searchdefinitions', null, 0 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', null, 0 ),
	),
	'accesslevel' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'      => $sloodleconfig->access_level_server_option(),
		'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_control_option()

	)
);
?>
