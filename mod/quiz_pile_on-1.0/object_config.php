<?php
    /**
    * Quiz 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a quiz object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodlequiz
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
        
        // We need to fetch a list of visible quizzes on the course
        // Get the ID of the chat type
        $rec = get_record('modules', 'name', 'quiz');
        if (!$rec) {
            sloodle_debug("Failed to get quiz module type.");
            exit();
        }
        $quizmoduleid = $rec->id;
        
        // Get all visible quizzes in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $quizmoduleid AND visible = 1");
        if (!$recs) {
            error(get_string('noquizzes','sloodle'));
            exit();
        }
        $quizzes = array();
        foreach ($recs as $cm) {
            // Fetch the quiz instance
            $inst = get_record('quiz', 'id', $cm->instance);
            if (!$inst) continue;
            // Store the quiz details
            $quizzes[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($quizzes);
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        $sloodlerepeat = (int)sloodle_get_value($settings, 'sloodlerepeat', 0);
        $sloodlerandomize = (int)sloodle_get_value($settings, 'sloodlerandomize', 1);
        $sloodleplaysound = (int)sloodle_get_value($settings, 'sloodleplaysound', 0);
    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user to select a quiz
        echo get_string('selectquiz','sloodle').': ';
        choose_from_menu($quizzes, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
        
        // Repeat the quiz
        echo get_string('repeatquiz','sloodle').' ';
        choose_from_menu_yesno('sloodlerepeat', $sloodlerepeat);
        echo "<br><br>\n";
        
        // Randomize the question order
        echo get_string('randomquestionorder','sloodle').' ';
        choose_from_menu_yesno('sloodlerandomize', $sloodlerandomize);
        echo "<br><br>\n";
    
        // Play sounds
        echo get_string('playsounds','sloodle').' ';
        choose_from_menu_yesno('sloodleplaysound', $sloodleplaysound);
        echo "<br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings, true, true, true);
        
    }
    
?>


