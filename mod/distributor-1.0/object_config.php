<?php
    /**
    * Distributor 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a distribution object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodledistributor
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
        
        // We need to fetch a list of visible distributors on the course
        // Get the ID of the Sloodle type
        $rec = get_record('modules', 'name', 'sloodle');
        if (!$rec) {
            sloodle_debug("Failed to get Sloodle module type.");
            exit();
        }
        
        // Get all visible Sloodle modules in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = {$rec->id} AND visible = 1");
        if (!is_array($recs)) $recs = array();
        $distributors = array();
        foreach ($recs as $cm) {
            // Fetch the distributor instance
            $inst = get_record('sloodle', 'id', $cm->instance, 'type', SLOODLE_TYPE_DISTRIB);
            if (!$inst) continue;
            // Store the distributor details
            $distributors[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($distributors);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        $sloodlerefreshtime = (int)sloodle_get_value($settings, 'sloodlerefreshtime', 3600);

    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select a distributor
        echo get_string('selectdistributor','sloodle').': ';
        choose_from_menu($distributors, 'sloodlemoduleid', $sloodlemoduleid, '<i>('.get_string('nodistributorinterface','sloodle').')</i>', '', 0);
        echo "<br><br>\n";
        
        // Ask the user for a refresh period (# seconds between automatic updates)
        echo get_string('refreshtimeseconds','sloodle').': ';
        echo '<input type="text" name="sloodlerefreshtime" value="'.$sloodlerefreshtime.'" size="8" maxlength="8" />';
        echo "<br><br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        // There is no need for server access controls, as users cannot access the server through the object
        // (server access is entirely done through Moodle for this one)
        sloodle_print_access_level_options($settings, true, true, false);
        
    }
    
?>


