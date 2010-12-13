<?php
    /**
    * Presenter 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a presenter object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodlechat
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
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
        
        // We need to fetch a list of visible presenters on the course
        // Get the ID of the chat type
        $rec = get_record('modules', 'name', 'sloodle');
        if (!$rec) {
            sloodle_debug("Failed to get Sloodle module type.");
            exit();
        }
        $sloodlemoduleid = $rec->id;
        
        // Get all visible presenters in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $sloodlemoduleid AND visible = 1");
        $presenters = array();
        foreach ($recs as $cm) {
            // Fetch the Sloodle instance
            $inst = get_record('sloodle', 'id', $cm->instance, 'type', SLOODLE_TYPE_PRESENTER);
            if (!$inst) continue;
            // Store the Sloodle details
            $presenters[$cm->id] = $inst->name;
        }

        // Make sure there are some presenters to be had        
        if (count($presenters) < 1) {
            error(get_string('nopresenters','sloodle'));
            exit();
        }

        // Sort the list by name
        natcasesort($presenters);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        $sloodlelistentoobjects = (int)sloodle_get_value($settings, 'sloodlelistentoobjects', 0);
        $sloodleautodeactivate = (int)sloodle_get_value($settings, 'sloodleautodeactivate', 1);
    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select a Slideshow
        echo get_string('selectpresenter','sloodle').': ';
        choose_from_menu($presenters, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings, false, true, false);
        
    }
    
?>


