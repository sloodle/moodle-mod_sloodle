<?php

    /**
    *
    * This file is part of SLOODLE Tracker.
    * Copyright (c) 2009 Sloodle
    *
    * SLOODLE Tracker is free software: you can redistribute it and/or modify
    * it under the terms of the GNU General Public License as published by
    * the Free Software Foundation, either version 3 of the License, or
    * (at your option) any later version.
    *
    * SLOODLE Tracker is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    * GNU General Public License for more details.
    *
    * You should have received a copy of the GNU General Public License.
    * If not, see <http://www.gnu.org/licenses/>
    *
    * Contributors:
    * Peter R. Bloomfield  
    * Julio Lopez (SL: Julio Solo)
    * Michael Callaghan (SL: HarmonyHill Allen)
    * Kerri McCusker  (SL: Kerri Macchi)
    *
    * A project developed by the Serious Games and Virtual Worlds Group.
    * Intelligent Systems Research Centre.
    * University of Ulster, Magee	
    */

    /**
    * Second Life Tracker 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a tracker object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
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
        
        // We need to fetch a list of visible Second Life Tracker modules on the course
        // Get the ID of the chat type
        $rec = sloodle_get_record('modules', 'name', 'sloodle');
        if (!$rec) {
            sloodle_debug("Failed to get Sloodle module type.");
            exit();
        }
        $sloodlemoduleid = $rec->id;
        
        // Get all visible SLOODLE Tracker modules in the current course
        $recs = sloodle_get_records_select('course_modules', "course = $courseid AND module = $sloodlemoduleid AND visible = 1");
        $trackers = array();
        foreach ($recs as $cm) {
            // Fetch the Sloodle instance
            $inst = sloodle_get_record('sloodle', 'id', $cm->instance, 'type', SLOODLE_TYPE_TRACKER);
            if (!$inst) continue;
            // Store the Sloodle details
            $trackers[$cm->id] = $inst->name;
        }

        // Make sure there are some modules to be had        
        if (count($trackers) < 1) {
            error(get_string('notrackers','sloodle'));
            exit();
        }

        // Sort the list by name
        natcasesort($trackers);
        
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
        echo get_string('selecttracker','sloodle').': ';
        choose_from_menu($trackers, 'sloodlemoduleid', $sloodlemoduleid, '');
        echo "<br><br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        sloodle_print_access_level_options($settings, false, true, true);
        
    }
    
?>
