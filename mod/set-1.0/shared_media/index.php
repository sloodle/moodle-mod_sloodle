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
    * They will then be able to rez layouts by creating AJAX requests which sill 
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

	/*
	$courseid = optional_param( 'courseid', 0, PARAM_INT );
	$cmid = optional_param( 'cmid', 0, PARAM_INT );
	*/

	// TODO: What should this be? Probably not 1...
	$course_context = get_context_instance( CONTEXT_COURSE, 1);
	$can_use_layouts = has_capability('mod/sloodle:uselayouts', $course_context);
	if (!$can_use_layouts) {
		include('../../../login/shared_media/index.php');
		exit;
	}

	// TODO: Register the set

	/*
	if ($cmid) {
		$controller = new SloodleController();
		if (!$controller->load($cmid)) {
			print "Error: Could not load Sloodle course module";	
		}

	} if ($courseid) {
		$sloodle_course = new SloodleCourse();
		if (!$sloodle_course->load($courseid)) {
			print "Error: Could not load course";	
		}
		$moodle_course = $sloodle_course->get_course_object();
		$layouts = $sloodle_course->get_layout_names();
		$courselayouts[$cid] = $layouts;
		$coursenames[$cid] = $moodle_course->fullname;
		print '<div class="top_navigation"><a href="http://api.avatarclassroom.com/sites.php?...">Sites</a> &gt; <a href="index.php">Courses</a> &gt; '.htmlentities($moodle_course->fullname).'</div>';
	} else {
		print '<div class="top_navigation"><a href="http://api.avatarclassroom.com/sites.php?...">Sites</a> &gt; <b>Courses</b></div>';
	}
	*/

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
			$layoutentries[$l->id] = $sloodle_course->get_layout_entries_for_layout_id($l->id);
		}
		$courselayouts[$cid] = $layouts;
		$coursenames[$cid] = $moodle_course->fullname;
        }

	include('index.template.php');

exit;
    
    // Authenticate the request and user, but do not allow auto-registration and enrolment
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->validate_user(true, true, true);
    
    // We need to check certain capabilities
    $can_use_layouts = false;
    $can_edit_layouts = false;
    
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
