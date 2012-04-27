<?php
    /**
    * Course information linker.
    * Allows objects in-world to query for information about a particular course.
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
    //
    // If everything is OK, the script will return status code, with the following information on the data lines:
    //  coursename_short|coursename_full
    //  autoreg_enabled|autoenrol_enabled
    //
    // The information will relate to whatever course the accessed controller belongs to.
    // (This is for security, to ensure course data cannot be retrieved unauthorised).
    // The autoreg and autoenrol values will be 0 or 1, indicate whether each feature is disabled or enabled on the course.
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    
    // Make sure Sloodle is actually installed
    $moduleinfo = sloodle_get_record('modules', 'name', 'sloodle');
    if (!$moduleinfo) {
        sloodle_debug('ERROR: Sloodle not installed<br/>');
        $sloodle->response->quick_output(-106, 'SYSTEM', 'The Sloodle module is not installed on this Moodle site.', false);
        exit();
    }
    
    // Check out autoreg and autoenrol settings
    $autoreg = '0';
    $autoenrol = '0';
    if ($sloodle->course->check_autoreg()) $autoreg = '1';
    if ($sloodle->course->check_autoenrol()) $autoenrol = '1';
    
    // Prepare the output
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->add_data_line(array($sloodle->course->get_short_name(), $sloodle->course->get_full_name()));
    $sloodle->response->add_data_line(array($autoreg, $autoenrol));

    // Render the output
    $sloodle->response->render_to_output();
    exit();
?>