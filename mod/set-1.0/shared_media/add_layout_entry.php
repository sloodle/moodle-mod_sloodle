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

require_once(SLOODLE_LIBROOT.'/object_configs.php');

require_once '../../../lib/json/json_encoding.inc.php';

include('index.template.php');


$configVars = array();

$skipvars = array(
    'controllerid', // Should be in the layout entry
    'courseid', // Should come from the controller
    'layoutentryid', // Layout entry
    'rezzeruuid' // Doesn't belong in layout
);

$layoutid = null;
foreach($_POST as $n => $v) {
    if (in_array($n, $skipvars)) {
        continue;
    }
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

/*
if (preg_match('/[^A-Za-z0-9_-]/', $objectname)) {
	error_output( 'Illegal characters in object name');
}
*/

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

$layout = new SloodleLayout();
if (!$layout->load($layoutid)) {
	error_output( 'Layout not found');
}

$controller_context = get_context_instance( CONTEXT_MODULE, $layout->controllerid);
if (!has_capability('mod/sloodle:editlayouts', $controller_context)) {
        error_output( 'Access denied');
}


$layoutentry = new SloodleLayoutEntry();
$layoutentry->name = $objectname;
$layoutentry->layout = $layoutid;
$layoutentry->position = "<0,-1,1.5>"; // default: behind and above the set where it's easy to see
$layoutentry->rotation = "<0.0,0.0,0.0,0.0>";

foreach($configVars as $n=>$v) {
    /*
	if (preg_match('/[^A-Za-z0-9_-/', $v)) {
		error_output( 'Illegal characters in config value');
	}
    */
	if (preg_match('/[^A-Za-z0-9_-]/', $n)) {
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

if (!$config = $layoutentry->get_object_config()) {
	error_output( 'Could not create config for object');
}

if (!$courseid = $layout->course) {
    error_output('Could not get courseidfrom layout');
}

if (!$controllerid = $layout->controllerid) {
    error_output('Could not get controllerid from layout');
}

$edit_object_form = '';
$html_list_item = '';

//var_dump($objectname);
//var_dump($config);
//var_dump($courseid);
//var_dump($controllerid);

ob_start();
$element_id = print_rezzable_item_li( $layoutentry, $courseid, $controllerid, $layout, false); 
$html_list_item = ob_get_clean();

ob_start();
$element_id = print_config_form( $layoutentry, $config, $courseid, $controllerid, $layoutid, $config->group, $rezzer->uuid);
$edit_object_form = ob_get_clean();

$content = array(
	'result' => 'added',
	'objectgroup' => $objectgroup, // TODO: Get this from the object_configs
	'objectgrouptext' => get_string('objectgroup:'.$objectgroup, 'sloodle'), // TODO: Get this from the object_configs
	'objectname' => preg_replace('/SLOODLE\s/', '', $objectname),
	'objecttypelinkable' => $layoutentry->objectDefinition()->type_for_link(),
        'moduletitle' => $moduletitle,
	'layoutid' => $layoutid,
	'layoutentryid' => $layoutentry->id, 
    'edit_object_form' => $edit_object_form,
    'html_list_item' => $html_list_item
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
