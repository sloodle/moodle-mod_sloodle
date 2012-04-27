<?php
// Simulates an ajax object-rezzing request

require_once '../../../lib/json/json_encoding.inc.php';

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
require_once(SLOODLE_LIBROOT.'/active_object.php');
require_once(SLOODLE_LIBROOT.'/user.php');

//ini_set('display_errors', 1);
//error_reporting(E_ALL);


require_once(SLOODLE_LIBROOT.'/object_configs.php');
$object_configs = SloodleObjectConfig::AllAvailableAsArray();

if (!$USER->id) {
	output( 'User not logged in' );
	exit;
}

$rezzer = new SloodleActiveObject();
$sloodleuser = new SloodleUser();
$sloodleuser->user_data = $USER;

if (!$layoutentryid = optional_param('layoutentryid', 0, PARAM_INT)) {
	error_output( 'Layout ID missing' );
}

if (!$controllerid  = optional_param('controllerid', 0, PARAM_INT)) {
	error_output( 'Controller ID missing' );
}

$layoutentry = new SloodleLayoutEntry();
if ( !$layoutentry->load( $layoutentryid ) ) {
	error_output( 'Layout Entry ID missing' );
}


$controller_context = get_context_instance( CONTEXT_MODULE, $controllerid);
if (!has_capability('mod/sloodle:uselayouts', $controller_context)) {
        error_output( 'Access denied');
}


// TODO: Get actual object name via layoutentryid
$objectname = $layoutentry->name;
if ( !$objectname ) {
	error_output( 'Layout entry did not have a name');
}

$config = SloodleObjectConfig::ForObjectName( $objectname );
$possibleobjectnames = $config->possibleObjectNames();

$primpassword = sloodle_random_prim_password();

$controller = new SloodleController();

if (!$controller->load( $controllerid )) {
	error_output('Could not load controller');
}

if ( !$rezzer->loadByUUID($_REQUEST['rezzeruuid']) ) {
	error_output('Could not load rezzer');
}

$rez_http_in_password = sloodle_random_prim_password();

//build response string
$response = new SloodleResponse();
$response->set_status_code(1);
$response->set_status_descriptor('SYSTEM');
$response->set_request_descriptor('REZ_OBJECT');
$response->set_http_in_password($rezzer->httpinpassword);
$response->add_data_line(join('|', $possibleobjectnames)); // object names - rezzer will use the first one it has in its inventory
$response->add_data_line('<0,-1,0>'); // position
$response->add_data_line('<0,0,0>'); // rotation
$response->add_data_line($rez_http_in_password); // This is set as the start parameter. As of 2011-08-08, this is ignored by the object at this point. When we do object persistance, it should be used to prevent people hijacking the object.

// The following are sent to the rezzer just in case the rezzer needs to tell us what it rezzed.
// In the normal case where we rez synchronously we already know it
// ...but if we want to rez asynchronously, it may be useful.
$response->add_data_line($primpassword); 
$response->add_data_line($layoutentryid); 

//create message - NB for some reason render_to_string changes the string by reference instead of just returning it.
$renderStr="";
$response->render_to_string($renderStr);

//send message to httpinurl
$async = ( defined('SLOODLE_ASYNC_REZZING') && SLOODLE_ASYNC_REZZING );
$reply = $rezzer->sendMessage($renderStr, $async, false, 'rez');

if ($async) {

    $result = 'queued';
    $error = '';

    $content = array(
        'result' => $result,
        'error' => $error,
    );

    print json_encode($content);
    exit;

}




if (!( $reply['info']['http_code'] == 200 ) ) {
	error_output('Rezzing failed');
}

$lines = explode("\n",$reply['result']);
$rezzed_object_uuid = $lines[0];

if ( !$authid = $controller->register_object($rezzed_object_uuid, $objectname, $sloodleuser, $primpassword, $rez_http_in_password, $config->type()) ) {
	error_output('Object registration failed');
}

if (!$controller->configure_object_from_layout_entry($authid, $layoutentryid, $rezzer->uuid)) {
	error_output('Configuration from layout entry failed');
}

// The object may have registered itself and its URL before we got here.
// In that case, send it its config.
// TODO: This uses more db hits than it should - it would be better if register_object returned the object, not just its ID.
$ao = new SloodleActiveObject();
if ($ao->loadByUUID($rezzed_object_uuid)) {
    if ($ao->httpinurl) {
        $extraParams = array('sloodlerezzeruuid' => $rezzer->uuid);
        $ao->sendConfig($extraParams, $async = false);
    }
}

$result = 'rezzed';
$error = '';

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
