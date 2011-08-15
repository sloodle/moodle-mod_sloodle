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
require_once(SLOODLE_LIBROOT.'/user.php');

require_once '../../../lib/json/json_encoding.inc.php';

        // TODO: What should this be? Probably not 1...
        $course_context = get_context_instance( CONTEXT_COURSE, 1);
        $can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
        if (!$can_use_layouts) {
                //include('../../../login/shared_media/index.php');
                include('login.php');
        }


$layoutid = optional_param('layoutid', '', PARAM_INT);

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if ($layout->load($layoutid)) {
	if (!$deleted = $layout->delete()) {
		error_output( 'Layout deletion failed');
	}
}

$controller_context = get_context_instance( CONTEXT_MODULE, $layout->controllerid);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
        error_output( 'Access denied');
}


$content = array(
	'result' => 'deleted',
	'layoutid' => $layoutid,
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
