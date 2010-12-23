<?php
// TODO: This probably should be loaded from a config.php under each tool
if (!isset($object_configs)) {
	$object_configs = array();
} 

$object_configs['SLOODLE Access Checker'] = array(
	'modname' => 'accesschecker-1.0',
	'object_code' => 'accesschecker',
	'group'   => 'registration',
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
	'object_code' => 'accesscheckerdoor',
	'group'   => 'registration',
	'aliases' => array('SLOODLE 1.1 Access Checker Door'), 
	'field_sets' => array( 
		'access' => array(
		'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
	//	'accesslevelobjectctrl' => access_level_object_control_control(),
	//	'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);

$object_configs['SLOODLE WebIntercom'] = array(
	'modname' => 'chat-1.0',
	'module_choice_message'  => 'selectchatroom',// TODO: There's some extra craziness to make sure we only have sloodle stuff
	'module_no_choices_message'  => 'nochatrooms', 
	'object_code' => 'webintercom',
	'module'  => 'chat',
	'group'   => 'communication',
	'aliases' => array('SLOODLE 1.1 Web Intercom', 'SLOODLE 1.1 WebIntercom'),  // not sure if this should have a space or not
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

$object_configs['SLOODLE Choice Horizontal'] = array(
	'modname' => 'choice-1.0',
	'object_code' => 'choicehorizontal',
	'module'  => 'choice',
	'group'   => 'communication',
	'aliases' => array('SLOODLE 1.1 Choice (Horizontal)'), 
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

$object_configs['SLOODLE Choice Vertical'] = array(
	'modname' => 'choice-1.0',
	'object_code' => 'choicevertical',
	'module'  => 'choice',
	'group'   => 'communication',
	'aliases' => array('SLOODLE 1.1 Choice (Vertical)'), 
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
	'object_code' => 'distributor',
	'module_type'  => SLOODLE_TYPE_DISTRIB,
	'module'  => 'sloodle',
	'group'   => 'inventory',
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
	'object_code' => 'entrolbooth',
	'group'   => 'registration',
	'aliases' => array('SLOODLE 1.1 Enrolment'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			//'accesslevelserver'     => access_level_server_controls()
		),
		
	 ),
);


$object_configs['SLOODLE Quiz Pile-On'] = array(
	'modname' => 'quiz_pile_on-1.0',
	'object_code' => 'quizpileon',
	'module'  => 'quiz',
	'module_choice_message'  => 'selectquiz',// TODO: There's some extra craziness to make sure we only have sloodle stuff
	'module_no_choices_message'  => 'noquizzes', 
	'group'   => 'activity',
	'aliases' => array('SLOODLE 1.1 Quiz'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlerepeat' => yes_no_control( 'repeatquiz' ),
			'sloodlerandomize' => yes_no_control( 'randomquestionorder' ),
			'sloodledialog' => yes_no_control( 'usedialogs' ),
			'sloodleplaysound' => yes_no_control( 'playsounds' ),
		),
	 ),
);


$object_configs['SLOODLE Quiz Chair'] = array(
	'modname' => 'quiz-1.0',
	'object_code' => 'quiz',
	'module'  => 'quiz',
	'module_choice_message'  => 'selectquiz',// TODO: There's some extra craziness to make sure we only have sloodle stuff
	'module_no_choices_message'  => 'noquizzes', 
	'group'   => 'activity',
	'aliases' => array('SLOODLE 1.1 Quiz'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
		'generalconfiguration' => array(
			'sloodlerepeat' => yes_no_control( 'repeatquiz' ),
			'sloodlerandomize' => yes_no_control( 'randomquestionorder' ),
			'sloodledialog' => yes_no_control( 'usedialogs' ),
			'sloodleplaysound' => yes_no_control( 'playsounds' ),
		),
	 ),
);


$object_configs['SLOODLE PrimDrop'] = array(
	'modname' => 'primdrop-1.0',
	'object_code' => 'primdrop',
	'module'  => 'assignment',
	'module_choice_message'  => 'selectglossary',// TODO: There's some extra craziness to make sure we only have sloodle stuff
	'module_no_choices_message'  => 'noassignments', 
	'group'   => 'inventory',
	'aliases' => array('SLOODLE 1.1 PrimDrop'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);


$object_configs['SLOODLE Password Reset'] = array(
	'modname' => 'pwreset-1.0',
	'object_code' => 'pwreset',
	'group'   => 'registration',
	'aliases' => array('SLOODLE 1.1 Password Reset'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			//'accesslevelobjectctrl' => access_level_object_control_control(),
			'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);



$object_configs['SLOODLE Glossary'] = array(
	'modname' => 'glossary-1.0',
	'object_code' => 'glossary',
	'module'  => 'glossary',
	'module_choice_message'  => 'selectglossary',
	'module_no_choices_message'  => 'noglossaries',
	'group'   => 'communication',
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
	'object_code' => 'presenter',
	'module_type' => SLOODLE_TYPE_PRESENTER,
	'module_choice_message'  => 'selectpresenter',
	'module_no_choices_message'  => 'nopresenters',
	'group'   => 'communication',
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
	'modname' => 'regenrolbooth-1.0',
	'object_code' => 'regenrolbooth',
	'group'   => 'registration',
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
$object_configs['SLOODLE Vending Machine'] = array(
	'modname' => 'distributor-1.0',
	'group'   => 'inventory',
	'aliases' => array( 'SLOODLE 1.1 Vending Machine'), 
	'field_sets' => array( 
		'access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
			'sloodleobjectaccesslevelctrl' => access_level_object_control_control(),
			'sloodleserveraccesslevel'     => access_level_server_controls()
		),
	 ),
);
*/

$object_configs['SLOODLE LoginZone'] = array(
	'modname' => 'loginzone-1.0',
	'object_code' => 'loginzone',
	'group'   => 'registration',
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
	return array(
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

function course_module_select_for_config( $config, $courseid, $val = null ) {

	if (!$options = course_module_options_for_config( $config, $courseid )) {
		return false;
	}
	$str = '<select name="sloodlemoduleid">'."\n";
	foreach($options as $n => $v) {
		$selectedattr = ($val == $n) ? ' selected ' : '';
		$str .= '<option '.$selectedattr.'value="'.htmlentities( $n ).'">'.htmlentities( $v ).'</option>'."\n";
	}
	$str .= '</select>';
	return $str;	
	
}

function course_module_options_for_config( $config, $courseid )  {

	$modtype = $config['module'];
	if (!$modtype) {
		return false;
	}

        // Determine which course is being accessed
        //$courseid = $auth_obj->course->get_course_id();

        // We need to fetch a list of visible quizzes on the course
        // Get the ID of the chat type
        $rec = get_record('modules', 'name', $modtype);
        if (!$rec) {
		return false;
        }
        $moduleid = $rec->id;

        // Get all visible quizzes in the current course
        $recs = get_records_select('course_modules', "course = ".intval($courseid)." AND module = ".intval($moduleid)." AND visible = 1");
        if (!$recs) {
		return false;
            //error(get_string('noquizzes','sloodle'));
        }

	$options = array();

        foreach ($recs as $cm) {
		// Fetch the quiz instance
		$inst = get_record($modtype, 'id', $cm->instance);
		if (!$inst) {
			continue;
		}
		// Store the quiz details
		$options[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($options);

	return $options;
	
}
?>
