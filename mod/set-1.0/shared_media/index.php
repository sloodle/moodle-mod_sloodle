<?php
    // This script is part of the Sloodle project
    // Created for Avatar Classroom, with the intention of eventually being ported back to regular Sloodle.
    // Some assumptions that are true for Avatar Classroom won't be true for arbitrary Moodle sites.
    // I'll try to comment these REGULAR SLOODLE TODO.

    /*
    * This script is intended to be shown on the surface of the Set.
    *
    * It will need to be passed all the paramters necessary to register the set in Authorized Objects.
    * This will include an http-in channel, it will use to send instructions to the set.
    * 
    * It will allow the user to browse their courses, layouts and objects.
    * They will then be able to rez layouts by creating AJAX requests which the server will then pass on to the rezzer object.
    *
    * When used for regular Sloodle, it will have the user login before showing them anything.
    * With Avatar Classroom the user will instead login to the Avatar Classroom site.
    * The Avatar Classroom site will then proxy to this page, attaching a token which will be used to authenticate the user.
    */

    /**
    * @package sloodleset
    * @copyright Copyright (c) 2010 various contributors (see below)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    *
    */

    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../../sl_config.php');
    /** Include the Sloodle PHP API. */
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle course data. */
    require_once(SLOODLE_LIBROOT.'/course.php');
    require_once(SLOODLE_LIBROOT.'/layout_profile.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');

    include('index.template.php');
//ini_set('display_errors', 1);
//error_reporting(E_ALL);

        $baseurl = 'index.php?sloodleuuid='.htmlentities($_REQUEST['sloodleuuid']).'&sloodleavname='.htmlentities($_REQUEST['sloodleavname']).'&sloodleobjuuid='.htmlentities($_REQUEST['sloodleobjuuid']).'&sloodleobjname='.htmlentities($_REQUEST['sloodleobjname']).'&httpinurl='.htmlentities($_REQUEST['httpinurl']);

	$sitesURL = '';
	if (defined('SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL') && (SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL != '') ) {
		$sitesURL = SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL.$baseurl.'&ts='.time();
	}

	if (isset($_GET['logout'])) {
		if ( defined('SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE') && ( SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE != '' ) ) {
			require(SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE);	
		} else {
			require_logout();
			header('Location: '.$baseurl);
			exit;
		}
	}

	/*
	$courseid = optional_param( 'courseid', 0, PARAM_INT );
	$cmid = optional_param( 'cmid', 0, PARAM_INT );
	*/

	// TODO: What should this be? Probably not 1...
	//$can_edit_layouts = has_capability('mod/sloodle:editlayouts', $course_context);
	if (!$USER || !$USER->id) {
		if ( defined('SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE') && ( SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE != '' ) ) {
			require(SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE);	
		} else {
			require_login();
			exit;
		}
	}

	// Register the set using URL parameters
	$ao = new SloodleActiveObject();
	$object_uuid = required_param('sloodleobjuuid');
	if (!$ao->loadByUUID($object_uuid)) {
		$ao->controllerid = 0; // Hope that's OK...
		$ao->userid = $USER->id;
		$ao->uuid = $object_uuid;
		$ao->httpinurl = required_param('httpinurl');
		$ao->password = rand(100000,9999999999);
		$ao->name = required_param('sloodleobjname');
		$ao->type = 'set-1.0';
		$ao->save();
	} else 	{
		if ($httpinurl = optional_param( 'httpinurl', NULL, PARAM_RAW )) {
			if ($ao->httpinurl != $httpinurl) {
				$ao->httpinurl = $httpinurl;
				$ao->save();
			} 
		}
	}

	// A list of all the sites the user has - gets passed by avatar classroom - won't be used for regular sloodle sites
	// If supplied, adds an extra layer at the top above courses allowing you to switch between sites.
	$sites = $_REQUEST['sites'];
	$hasSites = count($sites) > 0;

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


	$full = false; 

	print_html_top();
	print_toolbar( $baseurl, $sitesURL );

	print_site_placeholder( $sitesURL );
	/*
	if ($hasSites) {
		print_site_list( $sites );
	}
	*/

	print_controller_list( $courses, $controllers, $hasSites = false, $sitesURL); 
	print_layout_list( $courses, $controllers, $courselayouts );
	print_add_layout_forms( $courses, $controllers, $object_uuid );

	print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, $object_uuid);
	print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup );
	print_add_object_forms($courses, $controllers, $courselayouts, $object_configs, $object_uuid); 
	print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries, $object_uuid); 

	print_html_bottom();

exit;
?>
