<?php
// TODO: This probably should be loaded from a config.php under each tool
if (!isset($object_configs)) {
	$object_configs = array();
} 

$object_configs['SLOODLE Access Checker'] = array(
	'modname' => 'accesschecker-1.0',
	'group'   => 'Registration',
	'aliases' => array('SLOODLE 1.1 Access Checker'), 
	'field_sets' => array( 
		'access' => array(
		'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
	//	'accesslevelobjectctrl' => access_level_object_control_control(),
	//	'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);

$object_configs['SLOODLE Access Checker Door'] = array(
	'modname' => 'accesscheckerdoor-1.0',
	'group'   => 'Registration',
	'aliases' => array('SLOODLE 1.1 Access Checker Door'), 
	'field_sets' => array( 
		'access' => array(
		'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
	//	'accesslevelobjectctrl' => access_level_object_control_control(),
	//	'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);

$object_configs['SLOODLE Web Intercom'] = array(
	'modname' => 'quiz-1.0',
	'module'  => 'quiz',
	'group'   => 'Communication',
	'aliases' => array('SLOODLE 1.1 Web Intercom'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlelistentoobjects' => array(
				'title'       => 'listentoobjects',
				'description' => '',
				'options'    => array(
					1 => 'Yes',
					0 => 'No',
				),
			'default' => 0,
			'type' => 'radio',
			),
			'sloodleautodeactivate' => array(
				'title'       => 'allowautodeactivation',
				'description' => '',
				'options'    => array(
					1 => 'Yes',
					0 => 'No',
				),
			'default' => 1,
			'type' => 'radio',
			),
		)
	 ),
);

$object_configs['SLOODLE Choice'] = array(
	'modname' => 'choice-1.0',
	'module'  => 'choice',
	'group'   => 'Communication',
	'aliases' => array('SLOODLE 1.1 Choice'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlerefreshtime' => array(
				'title'       => 'refreshtimeseconds',
				'description' => '',
				'options'    => array(
					1 => 'Yes',
					0 => 'No',
				),
			'default' => 0,
			'type' => 'input',
			'lenght' => 8,
			),
		)
	 ),
);


$object_configs['SLOODLE Distributor'] = array(
	'modname' => 'distributor-1.0',
	'module_type'  => SLOODLE_TYPE_DISTRIB,
	'module'  => 'sloodle',
	'group'   => 'Communication',
	'aliases' => array('SLOODLE 1.1 Distributor'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlerefreshtime' => array(
				'title'       => 'refreshtimeseconds',
				'description' => '',
				'default' => 3600,
				'type' => 'input',
				'length' => 8,
			),
		)
	 ),
);


$object_configs['SLOODLE Enrolment Booth'] = array(
	'modname' => 'enrolbooth-1.0',
	'group'   => 'Registration',
	'aliases' => array('SLOODLE 1.1 Enrolment'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			//'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);


$object_configs['SLOODLE Glossary'] = array(
	'modname' => 'glossary-1.0',
	'module'  => 'glossary',
	'module_choice_message'  => 'selectglossary',
	'module_no_choices_message'  => 'noglossaries',
	'group'   => 'Communication',
	'aliases' => array('SLOODLE 1.1 Glossary'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlepartialmatches' => yes_no_control( 'showpartialmatches' ),
			'sloodlesearchaliases'  => yes_no_control( 'searchaliases' ),
			'sloodlesearchdefinitions'  => yes_no_control( 'searchdefinitions' ),
			'sloodleidletimeout' => array(
				'title'       => 'idletimeoutseconds',
				'description' => '',
				'default' => 3600,
				'type' => 'input',
				'length' => 8,
			),
		),
	 ),
);


$object_configs['SLOODLE Presenter'] = array(
	'modname' => 'presenter-2.0',
	'module'  => 'sloodle',
	'module_type' => SLOODLE_TYPE_PRESENTER,
	'module_choice_message'  => 'selectpresenter',
	'module_no_choices_message'  => 'nopresenters',
	'group'   => 'Communication',
	'aliases' => array('SLOODLE 1.1 Presenter'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
	/*
	TODO: The old objection_config page fetches sloodlelistentoobjects and sloodleautodeactivate, but doesn't need them.
	Probably redundant, but should confirm.
	*/
	 ),
);

$object_configs['SLOODLE RegEnrol Booth'] = array(
	'modname' => 'enrolbooth-1.0',
	'group'   => 'Registration',
	'aliases' => array('SLOODLE 1.1 RegEnrol Booth'), 
	'field_sets' => array( 
		'access' => array(
		'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
	//	'accesslevelobjectctrl' => access_level_object_control_control(),
	//	'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);

/*
*/
$object_configs['SLOODLE Vending Machine'] = array(
	'modname' => 'distributor-1.0',
	'group'   => 'Inventory',
	'aliases' => array( 'SLOODLE 1.1 Vending Machine'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'sloodleobjectaccesslevelctrl' => access_level_object_control_control(),
			'sloodleserveraccesslevel'     => access_level_server_controls()
		),
	 ),
);

$object_configs['SLOODLE LoginZone'] = array(
	'modname' => 'loginzone-1.0',
	'group'   => 'Registration',
	'aliases' => array( 'SLOODLE 1.1 LoginZone'), 
	'field_sets' => array( 
		'generalconfiguration' => array(
			'sloodlerefreshtime' => array(
				'title'       => 'idletimeoutseconds',
				'description' => '',
				'default' => 600,
				'type' => 'input',
				'length' => 8,
			),
		),
	 ),
);

$objectconfigsbygroup = array();
foreach($object_configs as $objname => $objconfig) {
	$group = $objconfig['group'];
	if (!isset($objectconfigsbygroup[$group])) {
		$objectconfigsbygroup[$group] = array();
	}
	$objectconfigsbygroup[$group][$objname] = $objconfig;
}

function access_level_server_controls() {
	return array(
		'title'       => 'accesslevelserver',
		'description' => 'accesslevelserver:desc',
		'options' => array(
			SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_SERVER_ACCESS_LEVEL_COURSE => 'accesslevel:course',
			SLOODLE_SERVER_ACCESS_LEVEL_SITE   => 'accesslevel:site',
			SLOODLE_SERVER_ACCESS_LEVEL_STAFF  => 'accesslevel:staff'
		),
		'default' => SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC,
		'type' => 'radio',
	);
}

function access_level_object_use_control() {
	return array(
		'title'       => 'accesslevelobject:use',
		'description' => '',
		'options'    => array(
			SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_OBJECT_ACCESS_LEVEL_GROUP  => 'accesslevel:group',
			SLOODLE_OBJECT_ACCESS_LEVEL_OWNER  => 'accesslevel:owner'
		),
		'default' => SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC,
		'type' => 'radio',
	);

}

function access_level_object_control_control() {
	return array(
		'title'       => 'accesslevelobject:control',
		'description' => '',
		'options'    => array(
			SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_OBJECT_ACCESS_LEVEL_GROUP  => 'accesslevel:group',
			SLOODLE_OBJECT_ACCESS_LEVEL_OWNER  => 'accesslevel:owner'
		),
		'default' => SLOODLE_OBJECT_ACCESS_LEVEL_OWNER,
		'type' => 'radio',
	);
}

function yes_no_control( $title ) {
	array(
		'title'       => $title,
		'description' => '',
		'options'    => array(
			1 => 'Yes',
			0 => 'No',
		),
		'default' => 1,
		'type' => 'yesno',
	);
}
?>
