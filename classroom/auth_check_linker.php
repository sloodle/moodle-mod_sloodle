<?php
    /**
    * Sloodle object authorization check linker.
    * Allows authorised objects in SL to check whether or not a specified user can authorize objects.
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
    //  sloodleuuid = the UUID of the agent requesting object authorisation
    //  sloodleavname = the name of the avatar requesting object authorisation
    //
    //
    // If the check is successful, the status code will be 1.
    // The data line will contain a 1 to indicate if the user can authorise objects on this course, or 0 otherwise.
    //
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../sl_config.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request and the user, but do not allow autoreg/autoenrol
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->validate_user(true, true, true);
    $sloodle->user->login();
    
    $can_authorize = false;
    
// MOODLE-SPECIFIC //
    // Check that the user has the Sloodle capability on this course
    $course_context = get_context_instance(CONTEXT_COURSE, $sloodle->course->get_course_id());
    $can_authorize = has_capability('mod/sloodle:objectauth' $course_context);
    
// END MOODLE-SPECIFIC //
    
    // Render the output
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    if ($can_authorize) $sloodle->response->add_data_line('1');
    else $sloodle->response->add_data_line('0');
    $sloodle->response->render_to_output();
?>