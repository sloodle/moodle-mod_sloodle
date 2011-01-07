<?php
// Simulates an ajax object-rezzing request

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

// TODO: We'll want to manage this info in a different way.
require_once(SLOODLE_LIBROOT.'/object_configs.php');

require_once '../../../lib/json/json_encoding.inc.php';

$configVars = array();

$layoutentryid = null;
foreach($_GET as $n => $v) {
	if ($n == 'layoutentryid') {
		$layoutentryid = intval($v);
	} else {
		$configVars[$n] = $v;
	}
}

if (!$layoutentryid) {
	error_output( 'Layout entry ID missing');
}

$layoutentry = new SloodleLayoutEntry();
if (!$layoutentry->load($layoutentryid)) {
	error_output( 'Could not load layout entry' );
}

foreach($configVars as $n=>$v) {
	if (preg_match('/[^A-Za-z0-9_-/', $v)) {
		error_output( 'Illegal characters in config value');
	}
	if (preg_match('/[^A-Za-z0-9_-/', $n)) {
		error_output( 'Illegal characters in config name');
	}
	$layoutentry->set_config( $n, $v );
}

//var_dump($layoutentry);
if (!$layoutentry->update()) {
	error_output('Layout entry update failed');
}


// Send a reset to the object 
$controller = new SloodleController();
if (!$controller->load( $configVars['controllerid'] )) {
        error_output('Could not load controller');
}

$failures = array();
$active_objects = $controller->get_active_objects( $layoutentryid );

foreach($active_objects as $ao) {
        $response = $ao->sendMessage('do:reset');
	sleep(1);
	$response2 = $ao->sendConfig();
        //var_dump($response['result']);
/*
        if (preg_match('/^(<.*?>)\|(<.*?>)\|(.*?)$/', $response['result'], $matches)) {
                $layoutentry->position = $matches[1];
                $layoutentry->rotation = $matches[2];
                $saved = $layoutentry->update();
        }
*/
}

if (!$moduletitle = $layoutentry->get_course_module_title()) {
	$moduletitle = '';
}

$content = array(
	'result' => 'updated',
	'objectname' => preg_replace('/SLOODLE\s/', '', $layoutentry->name),
	'moduletitle' => $moduletitle,
	'layoutid' => $layoutentry->layout,
	'layoutentryid' => $layoutentry->id
);

$rand = rand(0,10);
//sleep($rand);
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
