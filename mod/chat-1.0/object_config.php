<?php
    /**
    * Chat 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a chat object, v1.0.
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
        
        // We need to fetch a list of visible chatrooms on the course
        // Get the ID of the chat type
        $rec = get_record('modules', 'name', 'chat');
        if (!$rec) {
            sloodle_debug("Failed to get chatroom module type.");
            exit();
        }
        $chatmoduleid = $rec->id;
        
        // Get all visible chatrooms in the current course
        $recs = get_records_select('course_modules', "course = $courseid AND module = $chatmoduleid AND visible = 1");
        if (!$recs) {
            error(get_string('nochatrooms','sloodle'));
            exit();
        }
        $chatrooms = array();
        foreach ($recs as $cm) {
            // Fetch the chatroom instance
            $inst = get_record('chat', 'id', $cm->instance);
            if (!$inst) continue;
            // Store the chatroom details
            $chatrooms[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($chatrooms);
        
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
        
        // Ask the user to select a chatroom
        echo get_string('selectchatroom','sloodle').': ';
        choose_from_menu($chatrooms, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
    
        // Listening to object chat
        echo get_string('listentoobjects','sloodle').': ';
        choose_from_menu_yesno('sloodlelistentoobjects', $sloodlelistentoobjects);
        echo "<br><br>\n";
        
        // Allowing auto-deactivation
        echo get_string('allowautodeactivation','sloodle').': ';
        choose_from_menu_yesno('sloodleautodeactivate', $sloodleautodeactivate);
        echo "<br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings);
        
    }
    
?>


