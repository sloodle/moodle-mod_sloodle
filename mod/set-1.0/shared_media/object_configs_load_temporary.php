<?php
// TODO: This probably should be loaded from a config.php under each tool
if (!isset($object_configs)) {
	$object_configs = array();
} 

$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Access Checker';
$sloodleconfig->object_code= 'access-checker';
$sloodleconfig->modname    = 'accesschecker-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Access Checker');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Access Checker Door';
$sloodleconfig->object_code= 'access-checker-door';
$sloodleconfig->modname    = 'accesschecker-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Access Checker');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;


$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE WebIntercom';
$sloodleconfig->object_code= 'webintercom';
$sloodleconfig->modname    = 'chat-1.0';
$sloodleconfig->module     = 'chat';
$sloodleconfig->module_choice_message = 'selectchatroom';
$sloodleconfig->module_no_choices_message= 'nochatrooms';
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 WebIntercom');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlelistentoobjects' => new SloodleConfigurationOptionYesNo( 'sloodlelistentoobjects', 'listentoobjects', '', 0 ),
		'sloodleautodeactivate'  => new SloodleConfigurationOptionYesNo( 'sloodleautodeactivate', 'allowautodeactivation', '', 1 ),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Choice (Vertical)';
$sloodleconfig->object_code= 'choice-vertical';
$sloodleconfig->modname    = 'choice-1.0';
$sloodleconfig->module     = 'choice';
$sloodleconfig->module_choice_message = 'selectchoice';
$sloodleconfig->module_no_choices_message= 'nochoices';
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Choice (Vertical)');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Choice (Horizontal)';
$sloodleconfig->object_code= 'choice-horizontal';
$sloodleconfig->modname    = 'choice-1.0';
$sloodleconfig->module     = 'choice';
$sloodleconfig->module_choice_message = 'selectchoice';
$sloodleconfig->module_no_choices_message= 'nochoices';
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Choice (Horizontal)');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8 ),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Distributor';
$sloodleconfig->object_code= 'distributor';
$sloodleconfig->modname    = 'distributor-1.0';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectdistributor';
$sloodleconfig->module_no_choices_message= 'nodistributorinterface';
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_DISTRIB );
$sloodleconfig->group      = 'inventory';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Distributor');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array(
		'sloodlerefreshtime' => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 3600, 8),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Enrolment Booth';
$sloodleconfig->object_code= 'enrolbooth';
$sloodleconfig->modname    = 'enrolbooth-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Enrolment');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Quiz Pile-On';
$sloodleconfig->object_code= 'quiz-pileon';
$sloodleconfig->modname    = 'quiz-1.0';
$sloodleconfig->module     = 'quiz';
$sloodleconfig->module_choice_message = 'selectquiz';// TODO: There's some extra craziness to make sure we only have sloodle stuff
$sloodleconfig->module_no_choices_message = 'noquizzes';
$sloodleconfig->group      = 'activity';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Quiz Pile-On');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlerepeat' => new SloodleConfigurationOptionYesNo( 'sloodlerepeat', 'repeatquiz', 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlerandomize', 'randomquestionorder', 0 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodledialog', 'usedialogs', 0 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', 0 ),
	)
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;





$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Quiz Chair';
$sloodleconfig->object_code= 'quiz';
$sloodleconfig->modname    = 'quiz-1.0';
$sloodleconfig->module     = 'quiz';
$sloodleconfig->module_choice_message = 'selectquiz';// TODO: There's some extra craziness to make sure we only have sloodle stuff
$sloodleconfig->module_no_choices_message = 'noquizzes';
$sloodleconfig->group      = 'activity';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Quiz Chair');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
	'generalconfiguration' => array( //TODO: Check defaults
		'sloodlerepeat' => new SloodleConfigurationOptionYesNo( 'sloodlerepeat', 'repeatquiz', 0 ),
		'sloodlerandomize' => new SloodleConfigurationOptionYesNo( 'sloodlerandomize', 'randomquestionorder', 0 ),
		'sloodledialog' => new SloodleConfigurationOptionYesNo( 'sloodledialog', 'usedialogs', 0 ),
		'sloodleplaysound' => new SloodleConfigurationOptionYesNo( 'sloodleplaysound', 'playsounds', 0 ),
	)
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;




$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE PrimDrop';
$sloodleconfig->object_code= 'primdrop';
$sloodleconfig->modname    = 'primdrop-1.0';
$sloodleconfig->module     = 'assignment';
$sloodleconfig->module_choice_message = 'selectassignment';
$sloodleconfig->module_no_choices_message = 'noassignments'; 
$sloodleconfig->module_filters = array( 'assignmenttype' => 'sloodleobject');
$sloodleconfig->group      = 'inventory';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Quiz Chair');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(), 
		'sloodleobjectaccesslevelctrl' => $sloodleconfig->access_level_object_control_option(),
		'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;




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

	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;




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
		'sloodleplaysound' => new SloodleConfigurationOptionText( 'sloodleidletimeout', 'idletimeoutseconds', '', 3600, 8 ),
	)
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;



$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Presenter';
$sloodleconfig->object_code= 'presenter';
$sloodleconfig->modname    = 'presenter-1.0';
$sloodleconfig->module     = 'sloodle';
$sloodleconfig->module_choice_message = 'selectpresenter';
$sloodleconfig->module_no_choices_message = 'nopresenters'; 
$sloodleconfig->module_filters = array( 'type' => SLOODLE_TYPE_PRESENTER); 
$sloodleconfig->group      = 'communication';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 Presenter');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
		'sloodleobjectaccesslevelctrl'  => $sloodleconfig->access_level_object_use_option(),
		'sloodleserveraccesslevel'      => $sloodleconfig->access_level_server_option(),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;




$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE RegEnrol Booth';
$sloodleconfig->object_code= 'regenrolbooth';
$sloodleconfig->modname    = 'regenrolbooth-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 RegEnrol Booth');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodleobjectaccessleveluse'   => $sloodleconfig->access_level_object_use_option(),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;




$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE LoginZone';
$sloodleconfig->object_code= 'loginzone';
$sloodleconfig->modname    = 'loginzone-1.0';
$sloodleconfig->group      = 'registration';
$sloodleconfig->show       = true;
$sloodleconfig->aliases    = array('SLOODLE 1.1 LoginZone');
$sloodleconfig->field_sets = array( 
	'access' => array(
		'sloodlerefreshtime'   => new SloodleConfigurationOptionText( 'sloodleidletimeout', 'idletimeoutseconds', '', 600, 8),
	),
);
$object_configs[$sloodleconfig->primname] = $sloodleconfig;

?>
