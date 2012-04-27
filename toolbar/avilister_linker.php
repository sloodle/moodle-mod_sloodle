<?php
    /**
    * Sloodle AviLister linker script.
    *
    * Allows a tool in-world to fetch avatars' associated Moodle names.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Jeremy Kemp (and others?)
    * @contributor Peter R. Bloomfield
    *
    */
    
    // Access to this script can be authenticated in two ways: user-centric, and course-centric.
    // Both modes require the "sloodlepwd" parameter.
    // User-centric mode requires the avatar's UUID as "sloodleuuid".
    // Course-centric mode requires a Controller ID as "sloodlecontrollerid".
    //
    // NOTE: course-centric mode will be assumed if "sloodlecontrollerid" is present. User-centric mode otherwise.
    //
    // If using course-centric authentication, and no other parameters are provided, then a list of all
    //  avatar/Moodle names in the given course are returned. Attempting this from user-centric
    //  authentication will fail, returning status code -331.
    //
    //
    // In either authentication mode, the Moodle name of a specific avatar can be checked by specifying
    //  the following parameter:
    //
    //   sloodlelookupavname = name of an avatar lookup
    //
    //
    // Alternatively, in either authentication mode, the Moodle names of several avatars can be checked by
    //  specifying the following parameter:
    //
    //   sloodleavnamelist = a list of avatar names, separated by pipe characters
    //
    
    // In any mode, the script will return status code 1 on success, and the following on each data line:
    //  "<avatar_name>|<real_name>"
    // Single lookup mode returns 1 entry, whereas multi-lookup and list modes may return many.
    // If the single lookup fails, then error code -103 is returned.
    // If the other modes fail (i.e. no matching avatars found), then there are simply no data lines -- the status code is still 1.
    //
    // Note: data will *not* be given for Moodle users who have no avatar, nor avatars not linked to a Moodle user
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Process incoming data
    $sloodle = new SloodleSession();
    
    // Check what type of authentication we are using
    $course_centric = false;
    if ($sloodle->request->get_controller_id(false) == null) {
        // Attempt user-centric authentication
        $sloodle->authenticate_user_request();
        $sloodle->validate_avatar();
    } else {
        // Attempt course-centric authentication
        $sloodle->authenticate_request();
        $course_centric = true;
    }
    
    // Load the AviLister module
    $sloodle->load_module('avilister', false); // No database data required
    
    // Check for other parameters
    $sloodlelookupavname = $sloodle->request->optional_param('sloodlelookupavname');
    $sloodleavnamelist = $sloodle->request->optional_param('sloodleavnamelist');
    
    // Check what mode we are in (0 = course names, 1 = single-lookup, 2 = multi-lookup)
    $mode = 0;
    if (!empty($sloodlelookupavname)) $mode = 1;
    else if (!empty($sloodleavnamelist)) $mode = 2;
    switch ($mode) {
    case 0:
        // Course names - not valid with user-centric authentication
        if (!$course_centric) {
            $sloodle->response->quick_output(-331, 'USER_AUTH', 'Cannot access this information via user-centric authentication', false);
            exit();
        }
        // Get the array of names
        $names = $sloodle->module->find_real_names_course();
        if (!$names || count($names) == 0) {
            $sloodle->response->quick_output(-512, 'COURSE', 'Failed to access course to retrieve enrolled user data', false);
            exit();
        }
        // Output the list of names
        natcasesort($names);
        foreach ($names as $avatar_name => $real_name) {
            $sloodle->response->add_data_line(array($avatar_name, $real_name));
        }
        break;
        
    case 1:
        // Single lookup mode
        // Attempt to get the real name
        $sloodlelookupavname = addslashes(strip_tags($sloodlelookupavname));
        $real_name = $sloodle->module->find_real_name('', $sloodlelookupavname);
        if (!$real_name) {
            $sloodle->response->quick_output(-103, 'MISC', 'Could not locate requested avatar name', false);
            exit();
        }
        $sloodle->response->add_data_line(array($sloodlelookupavname, $real_name));
        break;
        
    case 2:
        // Split up the input array
        $sloodleavnamelist = addslashes(strip_tags($sloodleavnamelist));
        $avnames = explode('|', $sloodleavnamelist);
        // Get and output the array of names
        $names = $sloodle->module->find_real_names($avnames);
        if ($names && count($names) > 0) {
		    natcasesort($names);
		    foreach ($names as $avatar_name => $real_name) {
		        $sloodle->response->add_data_line(array($avatar_name, $real_name));
		    }
        }
        break;
    }
    
    
    // Output our response
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->render_to_output();
    
    exit();
?>
