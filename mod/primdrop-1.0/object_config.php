<?php
    /**
    * PrimDrop 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a PrimDrop object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodleprimdrop
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // IMPORTANT: make sure this is called from within a Sloodle script
    if (!defined('SLOODLE_VERSION')) {
        error('Not called from within a Sloodle script.');
        exit();
    }
    
    // Execute everything within a function to ensure we don't mess up the data in the other file
    sloodle_display_config_form($sloodleauthid, $auth_obj);
    
    
    
    function sloodle_display_config_form($sloodleauthid, $auth_obj)
    {
    //--------------------------------------------------------
    // SETUP
        
        // Determine which course is being accessed
        $courseid = $auth_obj->course->get_course_id();
        
        // We need to fetch a list of visible Sloodle Object assignments on the course
        // Get the ID of the assignment type
        $rec = get_record('modules', 'name', 'assignment');
        if (!$rec) {
            sloodle_debug("Failed to get assignment module type.");
            exit();
        }
        $assignmentmoduleid = $rec->id;
        
        // Get all visible assignments in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $assignmentmoduleid AND visible = 1");
        if (!$recs) {
            error(get_string('noassignments','sloodle'));
            exit();
        }
        $assignments = array();
        foreach ($recs as $cm) {
            // Fetch the assignment instance
            $inst = get_record('assignment', 'id', $cm->instance);
            if (!$inst) continue;
            // Ignore anything except Sloodle Object assignments
            if ($inst->assignmenttype != 'sloodleobject') continue;
            // Store the assignment details
            $assignments[$cm->id] = $inst->name;
        }
        
        // Make sure that we got some Sloodle Object assignments
        if (count($assignments) == 0) {
            error(get_string('nosloodleassignments','sloodle'));
            exit();
        }
        
        // Sort the list by name
        natcasesort($assignments);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select an assignment
        echo get_string('selectassignment','sloodle').': ';
        choose_from_menu($assignments, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings);
        
    }
    
?>