<?php
/** Grab the Sloodle/Moodle configuration. */
require_once('../../../init.php');
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

$layoutid = optional_param('layoutid', '', PARAM_INT);

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if (!$layout->load($layoutid)) {
    error_output( 'Could not load layout to delete it.');
}

$controller_context = get_context_instance( CONTEXT_MODULE, $layout->controllerid);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
        error_output( 'Access denied');
}

if (!$deleted = $layout->delete()) {
    error_output( 'Layout deletion failed');
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
