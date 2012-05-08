<?php
    /**
    * Sloodle active object ping.
    * Allows active objects to notify the Sloodle installation that they are still 'alive'.
    *
    * @package sloodleclassroom
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // The following parameters are required:
    //
    //  sloodlecontrollerid = the ID of the controller through which the current object may access Sloodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate access
    //  sloodleobjuuid = the UUID of the object which is active
    //
    //
    // If the check is successful, the status code will be 1.
    // If the object was not found, status code -103 is returned.
    //
    // NOTE: using the "sloodleobjuuid" parameter allows an object to ping on behalf of another.
    // However, the object must be authorised on the controller identified by "sloodlecontrollerid".
    //
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request
    $sloodle = new SloodleSession();

    // The access record happens when we authenticate.
    // If it fails, it should error out and exit.
    $sloodle->authenticate_request();

    
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->set_refresh_seconds(SLOODLE_PING_INTERVAL);

    
    // Output the response
    $sloodle->response->render_to_output();
?>
