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

require_once '../../../lib/json/json_encoding.inc.php';


//ini_set('display_errors', 1);
//error_reporting(E_ALL);

$configVars = array();

$layoutid = optional_param('layoutid', 0, PARAM_INT);
$rezzeruuid = optional_param('layoutid', 0, PARAM_RAW);

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

$layoutname = $layout->name.' Copied '.date('Y-m-d H:i:s');
if (!$cloneid = $layout->save_clone( $layoutname )) {
	error_output('Could not clone layout');
}

$layout = new SloodleLayout();
if (!$layout->load( $cloneid )) {
	error_output('Could not load cloned layout');
}

$layoutid = $cloneid;



// TODO: Lots of duplication with index.php - would be good to reduce it somehow.


        // REGULAR SLOODLE TODO: This should filter for courses the user has access to.
        $courses = get_courses();
        $coursesbyid = array();
        foreach($courses as $course) {
                $id = $course->id;
                $coursesbyid[ $id ] = $course;
        }

        // Get a list of controllers which the user is permitted to authorise objects on
        $controllers = array();
        $recs = sloodle_get_records('sloodle', 'type', SLOODLE_TYPE_CTRL);
        // Make sure we have at least one controller
        if ($recs == false || count($recs) == 0) {
            error(get_string('objectauthnocontrollers','sloodle'));
            exit();
        }

        foreach ($recs as $r) {
            // Fetch the course module
            $cm = get_coursemodule_from_instance('sloodle', $r->id);
            if ($cm->course != $courseid) {
                continue;
            }
            // Check that the person can authorise objects of this module
            if (has_capability('mod/sloodle:objectauth', get_context_instance(CONTEXT_MODULE, $cm->id))) {
                // Store this controller
                $controllers[$cm->course][$cm->id] = $r;
            }
        }




	$courselayouts = array();


	//$object_configs = SloodleObjectConfig::AllAvailableAsArrayByGroup();
	$object_configs = SloodleObjectConfig::AllAvailableAsArray();
	$objectconfigsbygroup  = SloodleObjectConfig::AllAvailableAsArrayByGroup();
	if (!isset($objectconfigsbygroup['misc'])) {
		$objectconfigsbygroup['misc'] = array(); // always make sure we have this group so that we can add misc objects added to the rezzer.
	}
//	include('object_configs.array.php');

        // Construct the list of course names
        $coursenames = array();
	$layoutentries = array();
        foreach ($controllers as $cid => $ctrls) {

		$sloodle_course = new SloodleCourse();
		if (!$sloodle_course->load($cid)) {
			continue;
		}
		$moodle_course = $sloodle_course->get_course_object();
		$coursenames[$cid] = $moodle_course->fullname;
		$courselayouts[$cid] = array();

		foreach($ctrls as $contid => $ctrl) {
			$sloodle_course->ensure_at_least_one_layout('Scene ', $contid);
			$layouts = $sloodle_course->get_layouts($contid);
			$courselayouts[$cid][$contid] = array();
			foreach($layouts as $l) {
				$entries = $sloodle_course->get_layout_entries_for_layout_id($l->id);
				$entriesbygroup = array('communication'=>array(), 'activity'=>array(), 'registration'=>array(), 'misc'=>array() );
				foreach($entries as $e) {
					$objectname = $e->name;
					$grp = 'misc';
					if (isset($object_configs[$objectname])) {
						$grp = $object_configs[$objectname]->group;
					}
					if (!isset($entriesbygroup[ $grp ] )) {
						$entriesbygroup[ $grp ] = array();
					}
					$entriesbygroup[ $grp ][] = $e;	
				}
				$layoutentries[$l->id] = $entriesbygroup;
				$courselayouts[$cid][$contid][] = $l;
			}
		}

        }

	



	include('index.template.php');

	ob_start();
        print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, null);
	$add_layout_lists = ob_get_clean();

	ob_start();
        print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup );
	$add_object_groups = ob_get_clean();

	ob_start();
        print_add_object_forms($courses, $controllers, $courselayouts, $object_configs, $rezzeruuid );
	$add_object_forms = ob_get_clean();

	ob_start();
        print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries, $rezzeruuid);
	$edit_object_forms = ob_get_clean();

$content = array(
	'result' => 'cloned',
	'layoutname' => $layoutname, // TODO: Get this from the object_configs
	'layoutid' => $layoutid,
	'courseid' => $courseid,
	'controllerid' => $layout->controllerid,
	'add_layout_lists' => $add_layout_lists,
	'add_object_groups' => $add_object_groups,
	'add_object_forms' => $add_object_forms,
	'edit_object_forms' => $edit_object_forms
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
