<?php
    /**
    * Glossary 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a glossary object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodleglossary
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
        
        // We need to fetch a list of visible glossaries on the course
        // Get the ID of the chat type
        $rec = get_record('modules', 'name', 'glossary');
        if (!$rec) {
            sloodle_debug("Failed to get glossary module type.");
            exit();
        }
        $glossarymoduleid = $rec->id;
        
        // Get all visible glossary in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $glossarymoduleid AND visible = 1");
        if (!$recs) {
            error(get_string('noglossaries','sloodle'));
            exit();
        }
        $glossaries = array();
        foreach ($recs as $cm) {
            // Fetch the chatroom instance
            $inst = get_record('glossary', 'id', $cm->instance);
            if (!$inst) continue;
            // Store the glossary details
            $glossaries[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($glossaries);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        $sloodlepartialmatches = (int)sloodle_get_value($settings, 'sloodlepartialmatches', 1);
        $sloodlesearchaliases = (int)sloodle_get_value($settings, 'sloodlesearchaliases', 0);
        $sloodlesearchdefinitions = (int)sloodle_get_value($settings, 'sloodlesearchdefinitions', 0);
        $sloodleidletimeout = (int)sloodle_get_value($settings, 'sloodleidletimeout', 120);
        
    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select a chatroom
        echo get_string('selectglossary','sloodle').': ';
        choose_from_menu($glossaries, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
    
        // Show partial matches
        echo get_string('showpartialmatches','sloodle').': ';
        choose_from_menu_yesno('sloodlepartialmatches', $sloodlepartialmatches);
        echo "<br><br>\n";
        
        // Search aliases
        echo get_string('searchaliases','sloodle').': ';
        choose_from_menu_yesno('sloodlesearchaliases', $sloodlesearchaliases);
        echo "<br><br>\n";
        
        // Search definitions
        echo get_string('searchdefinitions','sloodle').': ';
        choose_from_menu_yesno('sloodlesearchdefinitions', $sloodlesearchdefinitions);
        echo "<br><br>\n";
        
        // Ask the user for an idle timeout period (# seconds of no activity before automatic shutdown)
        echo get_string('idletimeoutseconds','sloodle').': ';
        echo '<input type="text" name="sloodleidletimeout" value="'.$sloodleidletimeout.'" size="8" maxlength="8" />';
        echo "<br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings);
        
    }
    
?>


