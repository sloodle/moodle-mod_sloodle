<?php
/** Grab the Sloodle/Moodle configuration. */
require_once('../../../sl_config.php');
/** Include the Sloodle PHP API. */
/** Sloodle core library functionality */
require_once(SLOODLE_DIRROOT.'/lib.php');
/** General Sloodle functions. */
require_once(SLOODLE_LIBROOT.'/io.php');
/** Sloodle course data. */
require_once(SLOODLE_LIBROOT.'/course.php');
require_once(SLOODLE_LIBROOT.'/layout_profile.php');
require_once(SLOODLE_LIBROOT.'/active_object.php');
require_once(SLOODLE_LIBROOT.'/object_configs.php');
require_once(SLOODLE_LIBROOT.'/user.php');

require_once '../../../lib/json/json_encoding.inc.php';

// TODO: What should this be? Probably not 1...
$course_context = get_context_instance( CONTEXT_COURSE, 1);
$can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
if (!$can_use_layouts) {
	//include('../../../login/shared_media/index.php');
	error_output( 'Not permitted' );
}

$primname = optional_param('primname', NULL, PARAM_RAW);
$courseid = optional_param('courseid', NULL, PARAM_INT);

if (!$config = SloodleObjectConfig::ForObjectName($primname)) {
	error_output( 'Could not find object' );
}

$fields = array();

$fields['sloodlemoduleid'] = $config->course_module_options( $courseid );

foreach($config->field_sets as $fs => $flds) {
	foreach($flds as $n => $option_obj) {
		$fields[$n] = $option_obj->translatedOptions(); 
	}
}

$content = array(
	'result' => 'refreshed',
	'fields' => $fields
);

print json_encode($content);
exit;

function error_output($error) {
	$content = array(
		'result' => 'failed',
		'error' => $error,
	);
	print json_encode($content);
	exit;
}
?>
