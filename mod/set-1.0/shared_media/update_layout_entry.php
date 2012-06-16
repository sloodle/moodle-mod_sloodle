<?php
// Simulates an ajax object-rezzing request

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

// TODO: We'll want to manage this info in a different way.
require_once(SLOODLE_LIBROOT.'/object_configs.php');

require_once '../../../lib/json/json_encoding.inc.php';

$configVars = array();

$layoutentryid = null;
$rezzeruuid = null;
foreach($_POST as $n => $v) {
	if ($n == 'layoutentryid') {
		$layoutentryid = intval($v);
	} else if ($n == 'rezzeruuid') {
		$rezzeruuid = $v;
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
    /*
	if (preg_match('/[^A-Za-z0-9_-]/', $v)) {
		error_output( 'Illegal characters in config value');
	}
	if (preg_match('/[^A-Za-z0-9_-]/', $n)) {
		error_output( 'Illegal characters in config name');
	}
    */
	$layoutentry->set_config( $n, $v );
}

// Send a reset to the object 
$controller = new SloodleController();
if (!$controller->load( $configVars['controllerid'] )) {
        error_output('Could not load controller');
}


$controller_context = get_context_instance( CONTEXT_MODULE, $configVars['controllerid']);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
        error_output( 'Access denied');
}


//var_dump($layoutentry);
if (!$layoutentry->update()) {
	error_output('Layout entry update failed');
}

$async = ( defined('SLOODLE_ASYNC_SEND_CONFIG') && SLOODLE_ASYNC_SEND_CONFIG );

$failures = array();
$active_objects = $controller->get_active_objects( $rezzeruuid, $layoutentryid );

if (count($active_objects) > 0) {
    foreach($active_objects as $ao) {
        if ($ao->configure_for_layout() || true) {
            $response = $ao->refreshConfig($async);
            sleep(1);
            $response2 = $ao->sendConfig($async);
        } 
        // No error handling here - if it breaks, just carry on.

            //var_dump($response['result']);
    /*
            if (preg_match('/^(<.*?>)\|(<.*?>)\|(.*?)$/', $response['result'], $matches)) {
                    $layoutentry->position = $matches[1];
                    $layoutentry->rotation = $matches[2];
                    $saved = $layoutentry->update();
            }
    */
    }
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
