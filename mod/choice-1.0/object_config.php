<?php
    /**
    * Choice 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a choice object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodlechoice
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
        
        // We need to fetch a list of visible choices on the course
        // Get the ID of the choice type
        $rec = get_record('modules', 'name', 'choice');
        if (!$rec) {
            sloodle_debug("Failed to get choice module type.");
            exit();
        }
        $choicemoduleid = $rec->id;
        
        // Get all visible choices in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $choicemoduleid AND visible = 1");
        if (!$recs) {
            error(get_string('nochoices','sloodle'));
            exit();
        }
        $choices = array();
        foreach ($recs as $cm) {
            // Fetch the choice instance
            $inst = get_record('choice', 'id', $cm->instance);
            if (!$inst) continue;
            // Store the choice details
            $choices[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($choices);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        $sloodlerefreshtime = (int)sloodle_get_value($settings, 'sloodlerefreshtime', 600);
        $sloodlerelative = (int)sloodle_get_value($settings, 'sloodlerelative', 0);
    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select a choice
        echo get_string('selectchoice','sloodle').': ';
        choose_from_menu($choices, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
    
        // Ask the user for a refresh period (# seconds between automatic updates)
        echo get_string('refreshtimeseconds','sloodle').': ';
        echo '<input type="text" name="sloodlerefreshtime" value="'.$sloodlerefreshtime.'" size="8" maxlength="8" />';
        echo "<br><br>\n";
        
        // Show relative results
        echo get_string('relativeresults','sloodle').': ';
        choose_from_menu_yesno('sloodlerelative', $sloodlerelative);
        echo "<br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings, true, false, true);
        
    }
    
?>
