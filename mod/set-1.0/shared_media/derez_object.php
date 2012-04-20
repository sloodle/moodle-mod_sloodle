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

require_once(SLOODLE_LIBROOT.'/object_configs.php');

$error = '';

if (!$USER->id) {
	output( 'User not logged in' );
	exit;
}

$rezzer = new SloodleActiveObject();
$sloodleuser = new SloodleUser();
$sloodleuser->user_data = $USER;

// Set this if we really need an answer now.
// This is used when removing from a layout, because we want to derez the objects first
// ...and we won't want to go ahead with the rest of the operation unless the object is gone.
$forcesynchronous = optional_param('synchronous', 0, PARAM_INT);
$async = ( $forcesynchronous || ( defined('SLOODLE_ASYNC_REZZING') && SLOODLE_ASYNC_REZZING ) );

if (!$layoutentryid = optional_param( 'layoutentryid', 0, PARAM_INT) ) {
	error_output( 'Layout ID missing' );
}

if (!$controllerid  = optional_param( 'controllerid', 0, PARAM_INT) ) {
	error_output( 'Controller ID missing' );
}

$controller_context = get_context_instance( CONTEXT_MODULE, $controllerid);
if (!has_capability('mod/sloodle:uselayouts', $controller_context)) {
        error_output( 'Access denied');
}

if ( !$rezzeruuid = optional_param( 'rezzeruuid', null, PARAM_SAFEDIR ) ) {
	error_output('Could not load rezzer');
}

$primpassword = sloodle_random_prim_password();

$controller = new SloodleController();

if (!$controller->load( $controllerid )) {
	error_output('Could not load controller');
}

$failures = array();
//$active_objects = $controller->get_active_objects( $rezzeruuid, $layoutentryid );
//$active_objects = $controller->get_active_objects( null, $layoutentryid);
$active_objects = $controller->get_active_objects( $rezzeruuid, $layoutentryid );

$result = '';
foreach($active_objects as $ao) {
    if ($ao->isQueueActive() && $async) {
        if ($ao->queueDeRez()) {
            $result = 'queued';
        } else {
            $failures[] = $ao;
        }
    } else {
        if (!$ao->deRez()) {
            $result = 'derezzed';
        } else {
            $failures[] = $ao;
        }
    }
	
	//$rezzed_object_uuid = $reply['result'];
}

// TODO: Handle failures properly...

if (count($failures) > 0) {
	$result = 'failed';
	$error = 'derez_failed';
}

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
