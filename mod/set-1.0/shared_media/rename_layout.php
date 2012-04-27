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



$layoutid = optional_param('layoutid', 0, PARAM_INT);
$layoutname = optional_param('layoutname', 0, PARAM_TEXT);

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if (!$layout->load( $layoutid )) {
	error_output('Could not load layout');
}

$controller_context = get_context_instance( CONTEXT_MODULE, $layout->controllerid);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
        error_output( 'Access denied');
}


$layout->name = $layoutname;
if (!sloodle_update_record('sloodle_layout', $layout)) {
	error_output('Could not save layout');
}

$content = array(
	'result' => 'renamed',
	'layoutname' => $layoutname, // TODO: Get this from the object_configs
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
