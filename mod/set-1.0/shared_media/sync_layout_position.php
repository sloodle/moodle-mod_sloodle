<?php
// Simulates an ajax object-rezzing request

require_once '../../../lib/json/json_encoding.inc.php';

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
require_once(SLOODLE_LIBROOT.'/user.php');

if (!$USER->id) {
	output( 'User not logged in' );
	exit;
}


$rezzer = new SloodleActiveObject();
$sloodleuser = new SloodleUser();
$sloodleuser->user_data = $USER;

if (!$layoutentryid = optional_param( 'layoutentryid', 0, PARAM_INT) ) {
	error_output( 'Layout ID missing' );
}

if (!$controllerid  = optional_param( 'controllerid', 0, PARAM_INT) ) {
	error_output( 'Controller ID missing' );
}

if ( !$rezzeruuid = optional_param( 'rezzeruuid', null, PARAM_SAFEDIR ) ) {
	error_output('Could not load rezzer');
}

$layoutentry = new SloodleLayoutEntry();
if (!$layoutentry->load($layoutentryid)) {
        error_output( 'Could not load layout entry' );
}

$controller = new SloodleController();
if (!$controller->load( $controllerid )) {
	error_output('Could not load controller');
}

$failures = array();
$active_objects = $controller->get_active_objects( $rezzeruuid, $layoutentryid );

foreach($active_objects as $ao) {
	$response = $ao->sendMessage('do:reportposition');
	//var_dump($response['result']);
	if (preg_match('/^(<.*?>)\|(<.*?>)\|(.*?)$/', $response['result'], $matches)) {
		$layoutentry->position = $matches[1];
		$layoutentry->rotation = $matches[2];
		$saved = $layoutentry->update();
	}
	//$rezzed_object_uuid = $reply['result'];
}

// TODO: If we get responses from multiple objects, pick the closest...

// TODO: Handle failures properly...

$result = 'synced';

$content = array(
	'result' => $result,
	'error' => $error,
);

print json_encode($content);

function error_output($error) {
	$content = array(
		'result' => 'failed',
		'error' => $error,
	);
	print json_encode($content);
	exit;
}
?>
