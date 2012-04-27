<?php
    // This script is part of the Sloodle project

    /**
    * User object authorisation linker.
    * Allows objects to initiate authorisation for user-centric tasks.
    * Also allows manual registration of avatars.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    /*
    * The following parameters are required:
    *
    *  sloodleobjuuid = UUID of the object
    *  sloodleobjname = name of the object
    *  sloodleobjpwd = password for the object
    *  sloodleuuid = UUID of the avatar
    *  sloodleavname = name of the avatar
    *
    * If successful, the status code returned will be 1 and the data line will contain a URL to forward the user to.
    */
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    
    // Process the request (but we can't authenticate it)
    $sloodle = new SloodleSession();
    
    // Make sure we have the required parameters
    $objuuid = $sloodle->request->required_param('sloodleobjuuid');
    $objname = $sloodle->request->required_param('sloodleobjname');
    $objpwd = $sloodle->request->required_param('sloodleobjpwd');
    $avuuid = $sloodle->request->get_avatar_uuid();
    $avname = $sloodle->request->get_avatar_name();
    
    // Attempt to validate the user (but suppress autoreg/enrol)
    $avatar_validated = $sloodle->validate_avatar(false);
    // If user validation failed, then setup a pending avatar entry
    $lst = null;
    if (!$avatar_validated) {
        $pa = $sloodle->user->add_pending_avatar($avuuid, $avname);
        if (!$pa) {
            $sloodle->response->quick_output(-322, 'MISC_REGISTER', 'Failed to add pending avatar details.', false);
            exit();
        }
        
        // Store the login security token
        $lst = $pa->lst;
    }
    
    // Attempt to add a new object to the database
    $sloodleauthid = $sloodle->user->add_user_object($avuuid, $objuuid, $objname, $objpwd);
    if (!$sloodleauthid) {
        $sloodle->response->quick_output(-201, 'OBJECT_AUTH', 'Failed to add user object to database.', false);
        exit();
    }
    
    // Construct the URL
    $url = SLOODLE_WWWROOT ."/login/user_object_auth.php?sloodleauthid=$sloodleauthid";
    if (!empty($lst)) $url .= "&sloodleuuid=$avuuid&sloodlelst=$lst";
    
    // Render the response
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->add_data_line($url);
    $sloodle->response->render_to_output();
    exit();
?>