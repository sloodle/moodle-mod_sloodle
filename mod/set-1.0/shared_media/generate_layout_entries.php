<?php
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
require_once(SLOODLE_LIBROOT.'/user.php');

require_once(SLOODLE_LIBROOT.'/object_configs.php');
require_once '../../../lib/json/json_encoding.inc.php';


ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once(SLOODLE_LIBROOT.'/layout_recipe/layout_recipe_base.php');
        // TODO: What should this be? Probably not 1...
        $course_context = get_context_instance( CONTEXT_COURSE, 1);
        $can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
        if (!$can_use_layouts) {
                //include('../../../login/shared_media/index.php');
                include('login.php');
        }


$courseid = optional_param('courseid', 0, PARAM_INT);
$layoutid = optional_param('layoutid', 0, PARAM_INT);
$recipe   = optional_param('layoutrecipe', 'SloodleSimpleLayoutRecipe', PARAM_TEXT);

if (!$layoutid) {
	error_output( 'Layout ID missing');
}

if (!class_exists( $recipe ) ){
	error_output( 'Recipe definition not found');
}

$layout = new SloodleLayout();
if (!$layout->load($layoutid)) {
	error_output( 'Could not load layout');
}

$recipe = new $recipe();
if (!$recipe->generate()) {
	error_output( 'Could not generate recipe');
}

if (!$recipe->saveToLayoutWithID( $layoutid )) {
	error_output( 'Could not save generated recipe to layout');
}
//$courseid = $layout->course;

$addedentries = array();
foreach($layout->get_entries() as $layoutentry) {
	$config = SloodleObjectConfig::ForObjectName($layoutentry->name);

	$modtitle = $layoutentry->get_course_module_title();
	if (!$modtitle) {
		$modtitle = '';
	}

	$addedentries[] = array(
		'objectgroup' => $config->group,
		'objectgrouptext' => get_string('objectgroup:'.$config->group, 'sloodle'), 
		'objectcode' => $config->object_code, 
		'objectname' => preg_replace('/SLOODLE\s/', '', $layoutentry->name),
		'moduletitle' => $modtitle,
		'layoutid' => $layoutid,
		'layoutentryid' => $layoutentry->id
	);
};

$content = array(
	'result' => 'generated',
	'layoutid' => $layoutid,
	'addedentries' => $addedentries,
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
