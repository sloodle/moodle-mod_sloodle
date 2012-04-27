<?php
    /**
    * Sloodle password reset linker.
    * Allows users in-world to request a password reset.
    * This is only intended for auto-registered users.
    *
    * @package sloodlepwreset
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodleuuid = the UUID of a user agent
    //  sloodleavname = the name of an avatar
    //
    // The following parameter is optional:
    //  sloodleserveraccesslevel = indicates what access level to enforce: 0 = public, 1 = course, 2 = site, 3 = staff
    //
    //
    // If successful, the script will reset the user's password, returning status code 1.
    // The data line will contain: username|password
    //
    // If the user has an active email account associated with their Moodle account, then
    //  status code -341 is returned, and the password is unchanged.
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, and validate the user, but do not allow auto-registration/enrolment
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->validate_user(true, true, true);
    
    // Request a password reset.
    $password = $sloodle->user->reset_password();
    
    // Prepare the response
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->add_data_line(array($sloodle->user->get_username(), $password));
    
    // If there are any pending password notifications for this user, then delete them
    $sloodle->user->purge_password_notifications();
    
    // Output the response data
    sloodle_debug('<pre>');
    $sloodle->response->render_to_output();
    sloodle_debug('</pre>');
    
?>