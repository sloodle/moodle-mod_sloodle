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

//ini_set('display_errors', 1);
//error_reporting(E_ALL);

        $baseurl = 'index.php?sloodleuuid='.htmlentities($_REQUEST['sloodleuuid']).'&sloodleobjuuid='.htmlentities($_REQUEST['sloodleobjuuid']).'&httpinurl='.htmlentities($_REQUEST['httpinurl']);

	if (isset($_GET['logout'])) {
		require_logout();
		header('Location: http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/'.$baseurl.'&ts='.time().'&logout');
		exit;
	}

	/*
	$courseid = optional_param( 'courseid', 0, PARAM_INT );
	$cmid = optional_param( 'cmid', 0, PARAM_INT );
	*/

	// TODO: What should this be? Probably not 1...
	$course_context = get_context_instance( CONTEXT_COURSE, 1);
	$can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
	if (!$can_use_layouts) {
		//include('../../../login/shared_media/index.php');
		include('login.avatarclassroom.php');
		//include('login.php');
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

	// REGULAR SLOODLE TODO: This should filter for courses the user has access to.
	$courses = get_courses();
	$coursesbyid = array();
	foreach($courses as $course) {
		$id = $course->id;
		$coursesbyid[ $id ] = $course;
	}

        // Get a list of controllers which the user is permitted to authorise objects on
        $controllers = array();
        $recs = get_records('sloodle', 'type', SLOODLE_TYPE_CTRL);
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

	include(SLOODLE_LIBROOT.'/object_configs.php');
	//$object_configs = SloodleObjectConfig::AllAvailableAsArrayByGroup();
	$object_configs = SloodleObjectConfig::AllAvailableAsArray();
	$objectconfigsbygroup  = SloodleObjectConfig::AllAvailableAsArrayByGroup();
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
		$layouts = $sloodle_course->get_layouts();
		foreach($layouts as $l) {
			$entries = $sloodle_course->get_layout_entries_for_layout_id($l->id);
			$entriesbygroup = array('communication'=>array(), 'inventory'=>array(), 'registration'=>array(), 'activity'=>array());
			foreach($entries as $e) {
				$objectname = $e->name;
				$grp = 'other';
				if (isset($object_configs[$objectname])) {
					$grp = $object_configs[$objectname]->group;
				}
				if (!isset($entriesbygroup[ $grp ] )) {
					$entriesbygroup[ $grp ] = array();
				}
				$entriesbygroup[ $grp ][] = $e;	
			}
			$layoutentries[$l->id] = $entriesbygroup;
		}
		$courselayouts[$cid] = $layouts;
		$coursenames[$cid] = $moodle_course->fullname;
        }

	include('index.template.php');

	$full = false; 

	print_html_top();
	print_toolbar( $baseurl );

	/*
	if ($hasSites) {
		print_site_list( $sites );
	}
	*/

	print_controller_list( $courses, $controllers, $hasSites = false); 
	print_layout_list( $courses, $controllers, $courselayouts );
	print_add_layout_form( $cid );
	print_html_bottom();

	print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, $object_uuid);
	print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup );
	print_add_object_forms($courses, $controllers, $courselayouts, $object_configs ); 
	print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries); 

	print_html_bottom();



exit;
///// MOODLE-SPECIFIC /////
    $course_context = get_context_instance(CONTEXT_COURSE, $sloodle->course->get_course_id());
    $can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
    $can_edit_layouts = has_capability('mod/sloodle:editlayouts', $course_context);
///// END MOODLE-SPECIFIC /////

    // If the user cannot use layouts at all, then we cannot do anything
    if (!$can_use_layouts) {
        $sloodle->response->quick_output(-301, 'USER_AUTH', 'User does not have permission to use layout profiles.', false);
        exit();
    }
    
    // Get the optional parameters
    $sloodlelayoutname = $sloodle->request->optional_param('sloodlelayoutname');
    $sloodlelayoutentries = $sloodle->request->optional_param('sloodlelayoutentries');
    $sloodleadd = $sloodle->request->optional_param('sloodleadd', 'false');
    if (strcasecmp($sloodleadd, 'true') == 0 || $sloodleadd == '1') $sloodleadd = true;
    else $sloodleadd = false;
    // Determine which mode we're in (0 = browse, 1 = query, 2 = update)
    $mode = 0;
    if ($sloodlelayoutname === null) $mode = 0;
    else if ($sloodlelayoutentries === null) $mode = 1;
    else $mode = 2;
    
    
    // Enter the appropriate mode
    switch ($mode) {
    case 0:
        // BROWSE MODE //
        // Fetch the layouts in this course
        $layouts = $sloodle->course->get_layout_names();
        // Add one data line per layout
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        foreach ($layouts as $id => $name) {
            $sloodle->response->add_data_line($name);
        }
        
        break;
        
    case 1:
        // QUERY MODE //
        // Attempt to load the specified profile
        $layout_entries = $sloodle->course->get_layout_entries($sloodlelayoutname);
        if ($layout_entries === false) {
            // Profile not found
            $sloodle->response->set_status_code(-902);
            $sloodle->response->set_status_descriptor('LAYOUT');
            $sloodle->response->add_data_line('Named profile does not exist');
        } else {
            // Output one entry per line
            $sloodle->response->set_status_code(1);
            $sloodle->response->set_status_descriptor('OK');
            foreach ($layout_entries as $le) {
                $sloodle->response->add_data_line(array($le->name, $le->position, $le->rotation, $le->id));
            }
        }
        
        break;
        
    case 2:
        // UPDATE MODE //
        // Make sure the user has permission to edit profiles
        if ($can_edit_layouts) {
        } else {
            $sloodle->response->set_status_code(-301);
            $sloodle->response->set_status_descriptor('LAYOUT_PROFILE');
            $sloodle->response->add_data_line('User does not have permission to edit layout profiles');
        }
        
        // This array will store the new entries for our layout
        $entries = array();
        // Go through each line of incoming data
        $lines = explode("\n", $sloodlelayoutentries);
        foreach ($lines as $l) {
            // Split the data into separate fields, and check that we have enough in this entry
            $fields = explode("|", $l);
            if (count($fields) < 3) continue;
            // Construct an entry object
            $entryobj = new SloodleLayoutEntry();
            $entryobj->name = $fields[0];
            $entryobj->position = $fields[1];
            $entryobj->rotation = $fields[2];
            $entryobj->objectuuid = $fields[3];
            $entries[] = $entryobj;
        }
        
        // Udpate the layout
        if ($sloodle->course->save_layout($sloodlelayoutname, $entries, $sloodleadd)) {
            $sloodle->response->set_status_code(1);
            $sloodle->response->set_status_descriptor('OK');
        } else {
            $sloodle->response->set_status_code(-901);
            $sloodle->response->set_status_descriptor('LAYOUT_PROFILE');
            $sloodle->response->add_data_line('Failed to save new layout');
        }

	// TODO: Copy the object settings to the layouts table
        
        break;
        
    default:
        // Unknown mode
        $sloodle->response->set_status_code(-904);
        $sloodle->response->set_status_descriptor('LAYOUT_PROFILE');
        $sloodle->response->add_data_line('Error determining layout operation');
        break;
    }
    
    
    // Render our output
    sloodle_debug('<pre>'); // <- to help visualising output in a browser when debugging
    $sloodle->response->render_to_output();
    sloodle_debug('</pre>');
    
?>
