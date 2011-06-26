<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE MetaGloss';
$sloodleconfig->object_code= 'glossary';
$sloodleconfig->modname    = 'glossary-1.0';
$sloodleconfig->module     = 'glossary';
$sloodleconfig->module_choice_message = 'selectglossary';
$sloodleconfig->module_no_choices_message = 'noglossaries'; 
$sloodleconfig->module_filters = array( ); // TODO
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 MetaGloss');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'      => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlepartialmatches' => new SloodleConfigurationOptionYesNo( 'sloodlepartialmatches', 'showpartialmatches', 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlesearchaliases', 'searchaliases', 0 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodlesearchdefinitions', 'searchdefinitions', 0 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', 0 ),
	)
);
?>
