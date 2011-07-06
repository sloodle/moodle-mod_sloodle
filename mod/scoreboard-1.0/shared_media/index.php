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
    * @package sloodle
    * @copyright Copyright (c) 2011 various contributors (see below)
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

    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');

//ini_set('display_errors', 1);
//error_reporting(E_ALL);

	// Register the set using URL parameters
	$ao = new SloodleActiveObject();
	$object_uuid = required_param('sloodleobjuuid');
	if (!$ao->loadByUUID($object_uuid)) {
		print "not found";
		exit;
	}

	$configs = $ao->config_name_value_hash();

	$roundid = 1;
	$currencyid = 0;

	$refreshtime = isset($configs['sloodlerefreshtime']) ? $configs['sloodlerefreshtime'] : 60;

	$context = get_context_instance(CONTEXT_COURSE,$ao->course->course_object->id);
	$contextid = $context->id;
	$courseid = $ao->course->course_object->id;

	$is_logged_in = isset($USER) && ($USER->id > 0);

        $is_admin = $is_logged_in && has_capability('moodle/course:manageactivities', $context); 

	$scoresql = "select userid as userid, sum(amount) as balance from mdl_sloodle_award_points p where p.roundid = {$roundid} and p.currencyid = {$currencyid} group by p.userid order by balance desc;";
	//$scoresql = "select userid as userid, sum(amount) as balance from mdl_sloodle_award_points p inner join mdl_sloodle_award_rounds ro on p.roundid=ro.id where p.roundid = {$roundid} and ro.courseid = {$courseid} and p.currencyid = {$currencyid} group by p.userid order by balance desc;";

 	$usersql = "select max(u.id) as userid, u.firstname as firstname, u.lastname as lastname, su.avname as avname from mdl_user u inner join mdl_role_assignments ra on u.id left outer join mdl_sloodle_users su on u.id=su.userid where ra.contextid={$contextid} group by u.id order by avname asc;";

//select max(u.userid) as userid, sum(p.amount) as balance from mdl_sloodle_award_points p left outer join mdl_sloodle_users u on p.userid=u.userid inner join mdl_groups_members m on u.userid=m.userid where m.groupid=2 group by u.userid;

	$scores = get_records_sql( $scoresql );
	$students = get_records_sql( $usersql);

	$students_by_userid = array();
	foreach($students as $student) {
		$students_by_userid[ $student->userid ] = $student;
	}

	// students with scores, in score order
	$student_scores = array();
	foreach($scores as $score) {
		$userid = $score->userid;
		if (!isset($students_by_userid[ $userid ])) { // student deleted but their score is still there.
			continue;
		}
		$student = $students_by_userid[ $userid ];
		$student->has_scores = true;
		$student->balance = $score->balance;
		$student_scores[$userid] = $student;
	}

	// students without scores
	if ($is_admin) {
		foreach($students_by_userid as $userid => $student) {
			if (isset($student_scores[ $userid ] )) {
				continue; // already done
			}
			$student->has_scores = false;
			$student->balance = 0;
			$student_scores[ $userid ] = $student;
		}
	}

	$roundrecs = get_records( 'sloodle_awards_rounds', 'id', $roundid );

	include('index.template.php');

	$full = false; 

/*
header('Cache-control: public');
header('Cache-Control: max-age=86400');
header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 60 * 60 * 24) . ' GMT');
header('Pragma: public');
*/


	print_html_top('', $is_logged_in);
	print_toolbar( $baseurl, $is_logged_in );

	print_site_placeholder( $sitesURL );
//	print_round_list( $roundrecs );
	print_score_list( "All groups", $student_scores, $object_uuid, $currency, $roundid, $refreshtime, $is_logged_in, $is_admin); 
	print_user_points_change_form( ); 



	print_html_bottom();

exit;
	/*
	if ($hasSites) {
		print_site_list( $sites );
	}
	*/

	print_controller_list( $courses, $controllers, $hasSites = false, $sitesURL); 
	print_layout_list( $courses, $controllers, $courselayouts );
	print_add_layout_forms( $courses, $controllers );
	print_html_bottom();

	print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, $object_uuid);
	print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup );
	print_add_object_forms($courses, $controllers, $courselayouts, $object_configs ); 
	print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries); 




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
