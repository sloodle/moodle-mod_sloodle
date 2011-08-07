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

require_once(SLOODLE_LIBROOT.'/object_configs.php');

require_once '../../../lib/json/json_encoding.inc.php';

$configVars = array();

$layoutid = null;
foreach($_GET as $n => $v) {
	if ($n == 'layoutid') {
		$layoutid = intval($v);
	} else if ($n == 'objectname') {
		$objectname = $v;
	} else if ($n == 'objectgroup') {
		$objectgroup= $v;
	} else {
		$configVars[$n] = $v;
	}
}

if (preg_match('/[^A-Za-z0-9_-/', $objectname)) {
	error_output( 'Illegal characters in object name');
}

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if (!$layout->load($layoutid)) {
	error_output( 'Layout not found');
}

$course_context = get_context_instance( CONTEXT_COURSE, $layout->course );
if (!has_capability('mod/sloodle:editlayouts', $course_context)) {
        error_output( 'Access denied');
}


$layoutentry = new SloodleLayoutEntry();
$layoutentry->name = $objectname;
$layoutentry->layout = $layoutid;
$layoutentry->position = "<0,-1,1.5>"; // default: behind and above the set where it's easy to see
$layoutentry->rotation = "<0.0,0.0,0.0,0.0>";

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
if (!$layoutentryid = $layoutentry->insert()) {
	error_output( 'Layout entry creation failed');
}

if (!$moduletitle = $layoutentry->get_course_module_title()) {
	$moduletitle = '';
}
$content = array(
	'result' => 'added',
	'objectgroup' => $objectgroup, // TODO: Get this from the object_configs
	'objectgrouptext' => get_string('objectgroup:'.$objectgroup, 'sloodle'), // TODO: Get this from the object_configs
	'objectname' => preg_replace('/SLOODLE\s/', '', $objectname),
	'objectcode' => $layoutentry->objectDefinition()->object_code,
        'moduletitle' => $moduletitle,
	'layoutid' => $layoutid,
	'layoutentryid' => $layoutentry->id
);

$rand = rand(0,10);
//sleep($rand);
print json_encode($content);
exit;
?>
<?php
// Simulates an ajax object-rezzing request
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

if ( !$layoutentry->load( $layoutentryid ) ) {
	error_output( 'Layout Entry ID missing' );
}

// TODO: Get actual object name via layoutentryid
$objectname = $layoutentry->name;
if ( !$objectname ) {
	error_output( 'Layout entry did not have a name');
}


$controller = new SloodleController();

if (!$controller->load( $controllerid )) {
	error_output('Could not load controller');
}

if ( !$rezzer->loadByUUID($_REQUEST['rezzeruuid']) ) {
	error_output('Could not load rezzer');
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
