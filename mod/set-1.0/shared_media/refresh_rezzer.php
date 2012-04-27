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

ini_set('display_errors', 1);
error_reporting(E_ALL);

$content = new stdClass();

$layoutid = optional_param('layoutid', 0, PARAM_INT);
$rezzeruuid = optional_param('rezzeruuid', 0, PARAM_RAW);

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if (!$layout->load( $layoutid )) {
	error_output('Could not load layout');
}

if (!$courseid = $layout->course) {
	error_output('Could not get courseid from layout');
}

$controller_context = get_context_instance( CONTEXT_MODULE, $layout->controllerid);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
    error_output( 'Access denied');
}

$rezzer = new SloodleActiveObject();
if (!$rezzer->loadByUUID($rezzeruuid, $lazy = true)) {
    error_output( 'Rezzer not found');
}

$layoutentries_to_uuids = $rezzer->layoutentryids_to_uuids_of_currently_rezzed( $layoutid );
if (!is_array($layoutentries_to_uuids)) {
    error_output('Fetching entries failed');
}

$content->result = 'refreshed';
$content->layoutentries_to_uuids = $layoutentries_to_uuids;

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
