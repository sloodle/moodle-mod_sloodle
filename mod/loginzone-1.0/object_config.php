<?php
    /**
    * Password reset 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a password reset object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodleregenrol
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
        
        // No setup to do
        
    //--------------------------------------------------------
    // FORM
    
        // Get the current object configuration
        $settings = SloodleController::get_object_configuration($sloodleauthid);
        
        // Setup our default values
        $sloodlerefreshtime = (int)sloodle_get_value($settings, 'sloodlerefreshtime', 600);

    
    ///// GENERAL CONFIGURATION /////
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('generalconfiguration','sloodle').'</h3>';
        
        // Ask the user for a refresh period (# seconds between automatic updates)
        echo get_string('refreshtimeseconds','sloodle').': ';
        echo '<input type="text" name="sloodlerefreshtime" value="'.$sloodlerefreshtime.'" size="8" maxlength="8" />';
        echo "<br><br>\n";
        
        print_box_end();
        
        
    ///// ACCESS LEVELS /////
        // No access levels needed
        
    }
    
?>


