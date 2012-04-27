<?php
    // This script is part of the Sloodle project

    /**
    * User object authorisation checker.
    * Allows objects to check that their user-centric authorisation works.
    * It will also make sure the avatar is registered.
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
    *  sloodleuuid = UUID of the avatar
    *  sloodlepwd = password to authenticate with
    *
    * If the authorisation is OK, the status code returned will be 1.
    */
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    
    // Process the request and check the authorisation and avatar
    $sloodle = new SloodleSession();
    $sloodle->authenticate_user_request();
    $sloodle->validate_avatar();
    
    // Everything seems OK
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
	$sloodle->response->render_to_output();
    
    exit();
?>