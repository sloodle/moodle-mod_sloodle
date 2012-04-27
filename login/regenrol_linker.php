<?php
    // This script is part of the Sloodle project

    /**
    * Registration and enrolment linker script.
    * Allows scripts in-world to initiate manual registration and enrolment.
    *
    * @package sloodleregenrol
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    *
    */
    
    /*
    * The following parameters are required:
    *
    *  sloodlecontrollerid = the ID of the controller to connect to
    *  sloodlepwd = password for authentication (either a prim password or an object-specific session key)
    *  sloodlemode = indicates the mode: "reg", "enrol", or "regenrol"
    *  sloodleuuid = UUID of the avatar
    *  sloodleavname = name of the avatar
    *
    * If successful, the status code returned will be 1 and the data line will contain a URL to forward the user to.
    * If nothing needs done because the user is already registered, then status code 301 is returned.
    * If nothing needs done because the user is already enrolled, then status code 401 is returned.
    * If the user cannot be enrolled because they are not yet registered, then status code -321.
    */
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    // Attempt to authenticate the user, but do not allow auto-registration/enrolment
    $sloodle->validate_user(false, true, true);
    $is_registered = $sloodle->user->is_user_loaded();
    $is_enrolled = false;
    if ($is_registered) {
        $is_enrolled = $sloodle->user->is_enrolled($sloodle->course->get_course_id());
    }
    
    // Make sure UUID and avatar name were specified
    $sloodleuuid = $sloodle->request->get_avatar_uuid(TRUE);
    $sloodleavname = $sloodle->request->get_avatar_name(TRUE);
    // Get the mode value
    $sloodlemode = $sloodle->request->required_param('sloodlemode');
    
    // If the mode is 'regenrol', but the user is already registered,
    //  then just do enrolment
    if ($sloodlemode == 'regenrol' && $is_registered) $sloodlemode = 'enrol';
    
    // What mode has been requested?
    switch ($sloodlemode)
    {
    case 'reg': case 'regenrol':
        // Is the user already registered?
        if ($is_registered) {
            $sloodle->response->set_status_code(301);
            $sloodle->response->set_status_descriptor('MISC_REGISTER');
        } else {
            // Add a pending avatar
            $pa = $sloodle->user->add_pending_avatar($sloodleuuid, $sloodleavname);
            if (!$pa) {
                $sloodle->response->set_status_code(-322);
                $sloodle->response->set_status_descriptor('MISC_REGISTER');
                $sloodle->response->add_data_line('Failed to add pending avatar details.');
            } else {
                // Construct and return a registration URL
                $url = SLOODLE_WWWROOT."/login/sl_welcome_reg.php?sloodleuuid=$sloodleuuid&sloodlelst={$pa->lst}";
                if ($sloodlemode == 'regenrol') $url .= '&sloodlecourseid='.$sloodle->course->get_course_id();                
                $sloodle->response->set_status_code(1);
                $sloodle->response->set_status_descriptor('OK');
                $sloodle->response->add_data_line($url);
            }
        }
        break;
        
    case 'enrol':
        // Is the user registered?
        if (!$is_registered) {
            $sloodle->response->set_status_code(-321);
            $sloodle->response->set_status_descriptor('MISC_REGISTER');
            $sloodle->response->add_data_line('Enrolment failed -- user is not yet registered.');
        } else {
            // Is the user already enrolled?
            if ($is_enrolled) {
                $sloodle->response->set_status_code(401);
                $sloodle->response->set_status_descriptor('MISC_ENROL');
            } else {
                // Construct and return an enrolment URL
                $sloodle->response->set_status_code(1);
                $sloodle->response->set_status_descriptor('OK');
                $sloodle->response->add_data_line("{$CFG->wwwroot}/course/enrol.php?id=".$sloodle->course->get_course_id());
            }
        }        
        break;
        
        
    default:
        $sloodle->response->set_status_code(-811);
        $sloodle->response->set_status_descriptor('REQUEST');
        $sloodle->response->add_data_line("Mode '$sloodlemode' unrecognised.");
        break;
    }
    
    
    // Render the response
    $sloodle->response->render_to_output();
    exit();
?>
