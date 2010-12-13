<?php
    // This file is part of the Sloodle project (www.sloodle.org)

    /**
    * This page allows users to get/check their LoginZone allocation.
    * Should be directly accessed as an interface script.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */

    /** Sloodle/Moodle configuration script. */
    require_once('../sl_config.php');
    /** Main Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    

    // Fetch our request parameters
    $id = optional_param('id', 0, PARAM_INT); // Course Module instance ID
        
    // Attempt to fetch the course module instance
    if ($id) {
        if (!$course = get_record('course', 'id', $id)) {
            error('Could not find course');
        }
    } else {
        error('Must specify a course ID');
    }
    
    // Get the Sloodle course data
    $sloodle_course = new SloodleCourse();
    if (!$sloodle_course->load($course)) error(get_string('failedcourseload','sloodle'));
    
    // Ensure that the user is logged-in to this course
    require_login($course->id);
    $course_context = get_context_instance(CONTEXT_COURSE, $course->id);
    
    // Do not allow guest access
    if (isguestuser()) {
        error(get_string('noguestaccess', 'sloodle'));
        exit();
    }
    
    // This is really a dummy Sloodle Session
    $sloodle = new SloodleSession(false);
    $sloodle->user->load_user($USER->id);
    $has_avatar = $sloodle->user->load_linked_avatar();
    
    // Log the view
    add_to_log($course->id, 'sloodle', 'view loginzone', "mod/sloodle/classroom/loginzone.php?id={$course->id}", "$course->id");

    // Display the page header
    $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/classroom/loginzone.php?id={$course->id}\">".get_string('loginzone','sloodle')."</a>";
    print_header_simple(get_string('loginzone','sloodle'), "", $navigation, "", "", true, '', navmenu($course));
    
    echo '<h1 style="text-align:center;">'.get_string('loginzone','sloodle').'</h1>';
    
//------------------------------------------------------    
 
    // Loginzone information
    print_box_start('generalbox boxaligncenter boxwidthnormal');
    echo '<div style="text-align:center;"><h3>'.get_string('loginzonedata','sloodle').'</h3>';
    
    // Does the user have an avatar?
    if ($has_avatar) {
        print_box_start('generalbox boxaligncenter boxwidthwide');
        echo get_string('loginzone:alreadyregistered','sloodle').'<br><br>';
        echo "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=user&amp;id={$USER->id}&course={$course->id}\">".get_string('viewmyavatar', 'sloodle')."</a><br>\n";
        print_box_end();
    }
    
    // Check we have all the data we need
    $data_error = array();
    if ($sloodle_course->get_loginzone_position() == '') $data_error[] = get_string('position','sloodle');
    if ($sloodle_course->get_loginzone_size() == '') $data_error[] = get_string('size','sloodle');
    if ($sloodle_course->get_loginzone_region() == '') $data_error[] = get_string('region','sloodle');
    
    // Do we have all the data?
    if (count($data_error) > 0) {
        // No - display the error, and stop
        echo '<span style="font-weight:bold;color:red;">'.get_string('loginzone:datamissing','sloodle').'</span><br><i>(';
        $isfirst = true;
        foreach ($data_error as $de) {
            if ($isfirst) $isfirst = false;
            else echo ", ";
            echo "$de";
        }
        echo ')</i><br><br>';
        print_string('loginzone:mayneedrez','sloodle');
        print_box_end();
        print_footer();
        exit();
    }
    
    // Store a string indicating the time/date of the last loginzone update
    $lastupdated = '('.get_string('unknown','sloodle').')';
    if ($sloodle_course->get_loginzone_time_updated() > 0) $lastupdated = date('Y-m-d H:i:s', $sloodle_course->get_loginzone_time_updated());
    
    print_box_start('generalbox boxaligncenter boxwidthnarrow');
    echo get_string('position','sloodle').': '.$sloodle_course->get_loginzone_position().'<br>';
    echo get_string('size','sloodle').': '.$sloodle_course->get_loginzone_size().'<br>';
    echo get_string('region','sloodle').': '.$sloodle_course->get_loginzone_region().'<br>';
    echo get_string('lastupdated','sloodle').': '.$lastupdated.'<br>';
    print_box_end();
    echo '<br>';
    
    // How long ago was the loginzone rezzed?
    $time_difference = time() - $sloodle_course->get_loginzone_time_updated();
    if ($time_difference > 1800) {
        echo '<span style="font-weight:bold;color:red;">'.get_string('loginzone:olddata','sloodle').'</span><br>';
        echo get_string('loginzone:mayneedrez','sloodle').'<br><br>';
    }
    
    // If the user already had an avatar, then there's nothing else to do
    if ($has_avatar) {
        print_box_end();
        print_footer();
        exit();
    }
    
    // Make sure the user is allowed to register an avatar
    require_capability('mod/sloodle:registeravatar', get_context_instance(CONTEXT_SYSTEM));
    
    // Has a new allocation been requested?
    if (isset($_REQUEST['allocate_loginzone'])) {
        // Yes - generate one
        if ($sloodle_course->generate_loginzone_allocation($sloodle->user)) {
            echo '<span style="font-weight:bold;color:green;">'.get_string('loginzone:allocationsucceeded','sloodle').'</span><br>';
            echo get_string('loginzone:expirynote','sloodle').'<br>';
        } else {
            echo get_string('loginzone:allocationfailed','sloodle').'<br>';
        }
        echo '<br>';
    }
    
    // Does the user already have a loginzone?
    $alloc = $sloodle_course->get_loginzone_allocation($sloodle->user);
    if ($alloc) {
        // Yes - show the teleport link
        echo '<span style="font-size:150%; font-weight:bold;">';
        echo '<a href="'.$alloc.'">'.get_string('loginzone:teleport','sloodle').'</a>';
        echo '</span><br><br>';
    } else {
        echo '<span style="color:orange; font-weight:bold;">';
        print_string('loginzone:needallocation','sloodle');
        echo '</span><br><br>';
    }
    
    // Create a form
    echo "<br><form action=\"loginzone.php\" method=\"GET\">\n";
    echo "<input type=\"hidden\" name=\"id\" value=\"{$course->id}\">\n";
    echo "<input type=\"hidden\" name=\"allocate_loginzone\" value=\"true\">\n";
    
    // Let the user opt to generate a new LoginZone allocation
    echo "<input type=\"submit\" value=\"".get_string('loginzone:newallocation','sloodle')."\"/>\n";
    
    // Close the form
    echo "</form>\n";
    
    
    echo '</div>';
    print_box_end();

    

//------------------------------------------------------
    
    print_footer($course);
    
?>
