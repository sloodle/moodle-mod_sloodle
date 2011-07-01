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

	// TODO: Check if they're a teacher, if so give them the teacher view.
	$is_admin = false;
	$is_logged_in = isset($USER) && ($USER->id > 0);
$is_logged_in = false;

	$is_admin = true;
	
	// TODO: Add round filter etc
	$sql = "select max(u.userid) as userid, sum(p.amount) as balance, u.avname as avname from {$CFG->prefix}sloodle_award_points p left outer join {$CFG->prefix}sloodle_users u on p.userid=u.userid group by u.userid order by balance desc, avname asc;";

//select max(u.userid) as userid, sum(p.amount) as balance from mdl_sloodle_award_points p left outer join mdl_sloodle_users u on p.userid=u.userid inner join mdl_groups_members m on u.userid=m.userid where m.groupid=2 group by u.userid;

	$student_scores = get_records_sql( $sql );

	$roundrecs = get_records( 'sloodle_awards_rounds', 'id', $roundid );

	include('index.template.php');

	$full = false; 

/*
header('Cache-control: public');
header('Cache-Control: max-age=86400');
header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 60 * 60 * 24) . ' GMT');
header('Pragma: public');
*/


	print_html_top();
	print_toolbar( $baseurl, $is_logged_in );

	print_site_placeholder( $sitesURL );
	print_round_list( $roundrecs );
	print_score_list( "All groups", $student_scores, $object_uuid, $currency, $roundid, $is_logged_in); 
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
