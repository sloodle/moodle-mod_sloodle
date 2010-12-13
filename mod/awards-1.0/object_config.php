<?php
    /**
    * Awards 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of the SLOODLE demo object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * The name of each form element becomes the name of a configuration parameter which is passed (via link message) to your scripts in SL.
    * For example, a form element called "sloodlemoduleid" will pass a value to your script in SL called "sloodlemoduleid".
    *
    *
    * @package sloodle
    * @copyright Copyright (c) 2009 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *  @contributor Paul G. Preibisch
    */
    global $CFG;
    
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
       
        $awards = array();
        foreach ($recs as $cm) {
            // Fetch the awards instance
            $inst = get_record('sloodle', 'id', $cm->instance, 'type', SLOODLE_TYPE_AWARDS);
            if (!$inst) continue;
            // Store the awards details
            $awards[$cm->id] = $inst->name;
        }
        // Sort the list by name
        natcasesort($awards);
        
        
    
        //--------------------------------------------------------
    // FORM
    
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        //sloodlemoduleid comes from the mdl_course_modules table and is the id of the actual awards module
        $sloodlemoduleid = (int)sloodle_get_value($settings, 'sloodlemoduleid', 0);
        
      
        
        

    
    ///// GENERAL CONFIGURATION /////
        // We will now display the configuration form.
    
        // Create a new section box for general configuration options
        print_box_start('generalbox boxaligncenter');
        ?>
        <!--  
            The Golden Man image is licenced under the Creative Commons License here:
            http://creativecommons.org/licenses/by-sa/3.0/
            And was created by: LuMaxArt Linkware Image www.lumaxart.com/
            http://www.flickr.com/photos/lumaxart/2293239853/sizes/l/
            -->
        <?php
        echo '<img src="'.SLOODLE_WWWROOT.'/lib/media/award.gif"><h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        helpbutton("awards_confighelp","Choose Sloodle Award System","sloodle",true,false,"",false);
         // Ask the user to select an awards
        
        echo get_string('awards:selectaward','sloodle').':&nbsp&nbsp';
        
        choose_from_menu($awards, 'sloodlemoduleid', $sloodlemoduleid,'');
        echo "<br><br>\n";
        //helpbutton("awards_confighelp2","Choose assignment","sloodle",true,false,"",false);
       
        print_box_end();

           
        
 
        
  
    ///// ACCESS LEVELS /////
        // This is common to nearly all objects, although variations are possible.
        // There are 3 access settings, in two categories:
        //  In-world: use and control
        //  Server: access
        //
        // The in-world 'use' setting determines who can generally use the object, whether it is public, limited to an SL group, or owner-only. (Public by default)
        // The in-world 'control' setting determines who has authority to control the object, which can similarly be public, group, or owner-only. (Owner-only by default)
        // The server access lets you limit usage to avatars which are registered or enrolled, or to members of staff. By default though, it is public.
        //
        // The following function displays the appropriate form data.
        // We pass in the existing settings so that it can setup defaults.
        // The subsequent 3 parameters determine if each type of access setting should be visible, in the order specified above.
        // They are optional, and all default to true if not specified.
    
        sloodle_print_access_level_options($settings, true, true, true);
        
    }
    
?>


