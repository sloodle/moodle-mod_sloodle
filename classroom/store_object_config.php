<?php

    /**
    * Sloodle object configuration storage script.
    *
    * When passed a list of object configuration settings, it will store them.
    * User must be logged-in and authorised to manage activities on the specified course.
    *
    * @package sloodleclassroom
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // The following parameter is required:
    //
    //  sloodleauthid = identifies which authorisation (active obejct) entry is being configured
    //
    // All other parameters which start with "sloodle", except for "sloodledebug", are treated
    //  as configuration settings and stored accordingly.
    //
    
    /** Include the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Make sure the user is logged-in and is not a guest
    if (isloggedin() == false || isguestuser() == true) {
        error(get_string('noguestaccess','sloodle'));
        exit();
    }
    
    // We need to know which object is being configured
    $sloodleauthid = required_param('sloodleauthid', PARAM_INT);
    $auth_obj = SloodleController::get_object($sloodleauthid);
    if (!$auth_obj) {
        error(get_string('objectauthnotfound','sloodle'));
        exit();
    }
    // Make sure the object is authorised
    if ($auth_obj->course->controller->is_loaded() == false) {
        //TODO: more appropriate error message?
        error(get_string('objectauthnotfound','sloodle'));
        exit();
    }
    
    // Make sure the user has permission to manage activities on this course
    $course_context = get_context_instance(CONTEXT_COURSE, $auth_obj->course->get_course_id());
    require_capability('moodle/course:manageactivities', $course_context);
    
    // Delete all configuration options already associated with the object
    sloodle_delete_records('sloodle_object_config', 'object', $sloodleauthid);
    
    // Define parameter names we will ignore
    $IGNORE_PARAMS = array('sloodleauthid', 'sloodledebug');
    // This structure will store our values
    $config_setting = new stdClass();
    $config_setting->object = $sloodleauthid;
    
    // Add the new ones
    $numstored = 0;
    foreach ($_REQUEST as $k => $v) {
        // Ignore anything which does not start with "sloodle"
        if (strpos($k, 'sloodle') !== 0) continue;
        // Ignore certain parameters
        if (in_array($k, $IGNORE_PARAMS)) continue;
        
        // Store the setting
        $config_setting->name = $k;
        $config_setting->value = $v;
        if (sloodle_insert_record('sloodle_object_config', $config_setting)) {
            $numstored++;
        }
    }
    
    // Construct a breadcrumb navigation menu
    $nav = get_string('modulename', 'sloodle').' -> ';
    $nav .= get_string('objectconfiguration','sloodle');
    // Display the page header
    print_header(get_string('objectconfiguration','sloodle'), get_string('objectconfiguration','sloodle'), $nav, '', '', false);
    
    
    // Display the information about the object
    sloodle_print_box_start('generalbox boxaligncenter boxwidthnarrow');
    echo '<div style="text-align:center;">';
    echo '<span style="font-weight:bold; font-size:110%;">'.get_string('objectdetails','sloodle').'</span><br>';
    
    echo get_string('objectname','sloodle').': '.$auth_obj->name.'<br>';
    echo get_string('objectuuid','sloodle').': '.$auth_obj->uuid.'<br>';
    echo get_string('objecttype','sloodle').': '.$auth_obj->type.'<br>';
    echo get_string('authorizedfor', 'sloodle').$auth_obj->course->get_full_name().' &gt; '.$auth_obj->course->controller->get_name().'<br>';
    
    // Indicate how many settings were stored
    echo '<br><span style="font-weight:bold;">';
    print_string('numsettingsstored','sloodle');
    echo " $numstored</span><br>\n";
    
    echo '</div>';
    sloodle_print_box_end();
    echo '<br>';
    
    // Print a continue button, to go back to the course
    echo '<div style="text-align:center;">';
    echo "<form action=\"{$CFG->wwwroot}/course/view.php\" method=\"GET\">";
    echo '<input type="hidden" name="id" value="'.$auth_obj->course->get_course_id().'"/>';
    echo '<input type="submit" value="'.get_string('continue').'"/>';
    echo '</form></div>';
    
    sloodle_print_footer();
    
?>
