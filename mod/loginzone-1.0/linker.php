<?php
    /**
    * LoginZone linker script.
    *
    * Allows an in-world LoginZone to communicate with the main server
    *
    * @package sloodleregenrol
    * @copyright Copyright (c) 2007 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    *
    */
    
    
    // This script is expected to be accessed by objects from in-world.
    // The following parameters are required at all times:
    //
    //   sloodlecontrollerid = integer ID of a Sloodle controller
    //   sloodlepwd = password for authentication
    //
    // There are two modes of operation.
    // In Mode 1, a LoginZone is reporting its own size and position. That requires the following parameters:
    //
    //   sloodlepos = a vector "<x,y,z>" indicating the position of the loginzone
    //   sloodlesize = a vector "<x,y,z>" indicating the size of the loginzone
    //   sloodleregion = the name of the region where the loginzone is located
    //
    // In Mode 2, a LoginZone is reporting that a user has teleported in to authenticate their avatar, requiring the following parameters:
    //
    //   sloodlepos = the position at which the avatar has appeared
    //   sloodleavname = the name of the avatar
    //   sloodleuuid = the UUID of the avatar
    //
    // ***** Note: the script assumes Mode 2 if either the avatar name or the UUID is specified *****

    // In either mode, the success response status code will be 1 ("OK").
    // Various errors codes may also be used.
    // The avatar UUID (if specified) will be returned in the request for Mode 2, according to the communications specification.

    /** Get the Sloodle configuration. */
	require_once('../../init.php');
    /** Get the Sloodle API. */
	require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
	
    // Start handling the request
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    
    // Are we using Mode 1?
    if ($sloodle->request->get_avatar_name(false) == null && $sloodle->request->get_avatar_uuid(false) == null) {
        // Mode 1
        
        // We require therefore that position, size and region are all specified
        $sloodlepos = $sloodle->request->required_param('sloodlepos', PARAM_TEXT);
        $sloodlesize = $sloodle->request->required_param('sloodlesize', PARAM_TEXT);
        $sloodleregion = $sloodle->request->required_param('sloodleregion', PARAM_TEXT);
        
        // Remove the decimal places
        $sloodlepos = sloodle_round_vector($sloodlepos);
        $sloodlesize = sloodle_round_vector($sloodlesize);
        
        // Add all the data
        $sloodle->course->set_loginzone_position($sloodlepos);
        $sloodle->course->set_loginzone_size($sloodlesize);
        $sloodle->course->set_loginzone_region($sloodleregion);
        $sloodle->course->set_loginzone_time_updated();
        
        // Attempt to update the database
        if ($sloodle->course->write()) {
            $sloodle->response->set_status_code(1);
            $sloodle->response->set_status_descriptor('OK');
        } else {
            $sloodle->response->set_status_code(-101);
            $sloodle->response->set_status_descriptor('SYSTEM');
            $sloodle->response->add_data_line('Failed to store LoginZone data');
        }
        
    } else {
        // Mode 2
        
        // We require therefore that position is specified
        $sloodlepos = $sloodle->request->required_param('sloodlepos', PARAM_TEXT);
        // Remove the decimal places
        $sloodlepos = sloodle_round_vector($sloodlepos);
        
        // Make sure the avatar name and UUID were specified
        $sloodleuuid = $sloodle->request->get_avatar_uuid();
        $sloodleavname = $sloodle->request->get_avatar_name();
        
        // Check to see if the user identified in the request is already in the database
        $sloodle_user_exists = $sloodle->user->load_avatar($sloodleuuid, $sloodleavname);
        if ($sloodle_user_exists) {
            // Nothing we need to do - just stop here
            $sloodle->response->set_status_code(301);
            $sloodle->response->set_status_descriptor('MISC_REGISTER');
            $sloodle->response->add_data_line('Avatar already registered');
            $sloodle->response->render_to_output();
            exit();
        }
        
        // Attempt to find the Sloodle user specified by login position in the request
        if ($sloodle->course->load_user_by_loginzone($sloodlepos, $sloodle->user)) {
            // Success
            
            // Make sure the user has permission to register their avatar
            $sloodle->user->login();
            if (!has_capability('mod/sloodle:registeravatar', get_context_instance(CONTEXT_SYSTEM))) {
                $sloodle->response->set_status_code(-331);
                $sloodle->response->set_status_descriptor('USER_AUTH');
                $sloodle->response->add_data_line('User does not have permission to register an avatar.');
                
            } else {
                // Add the avatar to our database
                if ($sloodle->user->add_linked_avatar($sloodle->user->get_user_id(), $sloodleuuid, $sloodleavname)) {
                    // Delete the LoginZone allocation now
                    $sloodle->course->delete_loginzone_allocation($sloodle->user);
                    // We've been successful
                    $sloodle->response->set_status_code(1);
                    $sloodle->response->set_status_descriptor('OK');
                } else {
                    // Failed to add the avatar
                    $sloodle->response->set_status_code(-102);
                    $sloodle->response->set_status_descriptor('SYSTEM');
                    $sloodle->response->add_data_line('Failed to add avatar to database');
                }
            }
            
        } else {
            // Report the problem back in the response
            $sloodle->response->set_status_code(-301);
            $sloodle->response->set_status_descriptor('USER_AUTH');
            $sloodle->response->add_data_line('No user found with specified Login Position.');
        }
        
    }
    
    // Output the response
    sloodle_debug("<pre>");
    $sloodle->response->render_to_output();
    sloodle_debug("</pre>");
    exit();

?>
