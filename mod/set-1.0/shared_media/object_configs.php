<?php
// TODO: This probably should be loaded from a config.php under each tool
if (!isset($object_configs)) {
	$object_configs = array();
} 

$object_configs['SLOODLE RegEnrol Booth'] = array(
	'modname' => 'enrolbooth-1.0',
	'group'   => 'Registration',
	'aliases' => array('SLOODLE 1.1 RegEnrol Booth'), 
	'field_sets' => array( 
		'Access' => array(
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
		'Access' => array(
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
		'Access' => array(
			'sloodleobjectaccessleveluse'  => access_level_object_use_control(),
		//	'accesslevelobjectctrl' => access_level_object_control_control(),
		//	'accesslevelserver'     => access_level_server_controls()
		),
	 ),
);

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

?>
