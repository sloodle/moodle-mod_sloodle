<?php
    
    /**
    * Sloodle general library.
    *
    * Provides various utility functionality for general Sloodle purposes.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    *
    */
    
    // This library expects that the Sloodle config file has already been included
    //  (along with the Moodle libraries)
    
    /** Include our email functionality. */
    require_once(SLOODLE_LIBROOT.'/mail.php');

    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    require_once(SLOODLE_LIBROOT.'/currency.php');


    /**
    * Force the user to login, but reject guest logins.
    * This function exists to workaround some Moodle 1.8 bugs.
    * @return void
    */
    function sloodle_require_login_no_guest()
    {
        global $CFG, $SESSION, $FULLME;
        // Attempt a direct login initially
        require_login(0, false);
        // Has the user been logged-in as a guest?
        if (isguestuser()) {
            // Make sure we can come back here after login
            $SESSION->wantsurl = $FULLME;
            // Redirect to the appropriate login page
            if (empty($CFG->loginhttps)) {
                redirect($CFG->wwwroot .'/login/index.php');
            } else {
                $wwwroot = str_replace('http:','https:', $CFG->wwwroot);
                redirect($wwwroot .'/login/index.php');
            }
            exit();
        }
    }    
    
    /**
    * Sets a Sloodle configuration value.
    * This data will be stored in Moodle's "config" table, so it will persist even after Sloodle is uninstalled.
    * After being set, it will be available (read-only) as a named member of Moodle's $CFG variable.
    * <b>NOTE:</b> in Sloodle debug mode, this function will terminate the script with an error if the name is not prefixed with "sloodle_".
    * @param string $name The name of the value to be stored (should be prefixed with "sloodle_")
    * @param string $value The string representation of the value to be stored
    * @return bool True on success, or false on failure (may fail if database query encountered an error)
    * @see sloodle_get_config()
    */
    function sloodle_set_config($name, $value)
    {
        // If in debug mode, ensure the name is prefixed appropriately for Sloodle
        if (defined('SLOODLE_DEBUG') && SLOODLE_DEBUG) {
            if (substr_count($name, 'sloodle_') < 1) {
                exit ("ERROR: sloodle_set_config(..) called with invalid value name \"$name\". Expected \"sloodle_\" prefix.");
            }
        }
        // Use the standard Moodle config function, ignoring the 3rd parameter ("plugin", which defaults to NULL)
        return set_config(strtolower($name), $value);
	}

    /**
    * Gets a Sloodle configuration value from Moodle's "config" table.
    * This function does not necessarily need to be used.
    * All configuration data is available as named members of Moodle's $CFG global variable.
    * <b>NOTE:</b> in Sloodle debug mode, this function will terminate the script with an error if the name is not prefixed with "sloodle_".
    * @param string $name The name of the value to be stored (should be prefixed with "sloodle_")
    * @return mixed A string containing the configuration value, or false if the query failed (e.g. if the named value didn't exist)
    * @see sloodle_set_config()
    */
	function sloodle_get_config($name)
    {
        // If in debug mode, ensure the name is prefixed appropriately for Sloodle
        if (defined('SLOODLE_DEBUG') && SLOODLE_DEBUG) {
            if (substr_count($name, 'sloodle_') < 1) {
                exit ("ERROR: sloodle_get_config(..) called with invalid value name \"$name\". Expected \"sloodle_\" prefix.");
            }
        }
        // Use the Moodle config function, ignoring the plugin parameter
        $val = get_config(NULL, strtolower($name));
        // Older Moodle versions return a database record object instead of the value itself
        // Workaround:
        if (is_object($val)) return $val->value;
        return $val;
	}
    
    /**
    * Determines whether or not auto-registration is allowed for the site.
    * @return bool True if auto-reg is allowed on the site, or false otherwise.
    */
    function sloodle_autoreg_enabled_site()
    {
        return (bool)sloodle_get_config('sloodle_allow_autoreg');
    }
    
    /**
    * Determines whether or not auto-enrolment is allowed for the site.
    * @return bool True if auto-enrolment is allowed on the site, or false otherwise.
    */
    function sloodle_autoenrol_enabled_site()
    {
        return (bool)sloodle_get_config('sloodle_allow_autoenrol');
    }

    /**
    * Sends an XMLRPC message into Second Life.
    * @param string $channel A string containing a UUID identifying the XMLRPC channel in SL to be used
    * @param int $intval An integer value to be sent in the message
    * @param string $strval A string value to be sent in the message
    * @return bool True if successful, or false if an error occurs
    */
    function sloodle_send_xmlrpc_message($channel,$intval,$strval)
    {
        // Include our XMLRPC library
        require_once(SLOODLE_DIRROOT.'/lib/xmlrpc.inc');
        // Instantiate a new client object for communicating with Second Life
        $client = new xmlrpc_client("http://xmlrpc.secondlife.com/cgi-bin/xmlrpc.cgi");
        // Construct the content of the RPC
        $content = '<?xml version="1.0"?><methodCall><methodName>llRemoteData</methodName><params><param><value><struct><member><name>Channel</name><value><string>'.$channel.'</string></value></member><member><name>IntValue</name><value><int>'.$intval.'</int></value></member><member><name>StringValue</name><value><string>'.$strval.'</string></value></member></struct></value></param></params></methodCall>';
        
        // Attempt to send the data via http
        $response = $client->send(
            $content,
            60,
            'http'
        );
        
        //var_dump($response); // Debug output
        // Make sure we got a response value
        if (!isset($response->val) || empty($response->val) || is_null($response->val)) {
            // Report an error if we are in debug mode
            if (defined('SLOODLE_DEBUG') && SLOODLE_DEBUG) {
                print '<p align="left">Not getting the expected XMLRPC response. Is Second Life broken again?<br/>';
                if (isset($response->errstr)) print "XMLRPC Error - ".$response->errstr;
                print '</p>';
            }
            return FALSE;
        }
        
        // Check the contents of the response value
        //if (defined('SLOODLE_DEBUG') && SLOODLE_DEBUG) {
        //    print_r($response->val);
        //}
        
        //TODO: Check the details of the response to see if this was successful or not...
        return TRUE;
    
    }

    /**
    * Old logging function
    * @todo <b>May require update?</b>
    */
    function sloodle_add_to_log($courseid = null, $module = null, $action = null, $url = null, $cmid = null, $info = null)
    {

       global $CFG;

       // TODO: Make sure we set this in the calling function, then remove this bit
       if ($courseid == null) {
          $courseid = optional_param('sloodle_courseid',0,PARAM_RAW);
       }

       // if no action is specified, use the object name
       if ($action == null) {
          $action = $_SERVER['X-SecondLife-Object-Name'];
       }

       $region = $_SERVER['X-SecondLife-Region'];
       if ($info == null) {
          $info = $region;
       }

       $slurl = '';
       if (preg_match('/^(.*)\(.*?\)$/',$region,$matches)) { // strip the coordinates, eg. Cicero (123,123)
          $region = $matches[1];
       }

       $xyz = $_SERVER['X-SecondLife-Local-Position'];
       if (preg_match('/^\((.*?),(.*?),(.*?)\)$/',$xyz,$matches)) {
          $xyz = $matches[1].'/'.$matches[2].'/'.$matches[3];
       }

       return add_to_log($courseid, null, $action, $CFG->wwwroot.'/mod/sloodle/toslurl.php?region='.urlencode($region).'&xyz='.$xyz, $userid, $info );
       //return add_to_log($courseid, null, "ok", "ok", $userid, "ok");

    }

    /**
    * Determines whether or not Sloodle is installed.
    * Queries Moodle's modules table for a Sloodle entry.
    * <b>NOTE:</b> does not check for the presence of the Sloodle files.
    * @return bool True if Sloodle is installed, or false otherwise.
    */
    function sloodle_is_installed()
    {
        // Is there a Sloodle entry in the modules table?
        return sloodle_record_exists('modules', 'name', 'sloodle');
    }
    
    /**
    * Generates a random login security token.
    * Uses mixed-case letters and numbers to generate a random 16-character string.
    * @return string
    * @see sloodle_random_web_password()
    */
    function sloodle_random_security_token()
    {
        // Define the characters we can use in our token, and get the length of it
        $str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $strlen = strlen($str) - 1;
        // Prepare the token variable
        $token = '';
        // Loop once for each output character
        for($length = 0; $length < 16; $length++) {
            // Shuffle the string, then pick and store a random character
            $str = str_shuffle($str);
            $char = mt_rand(0, $strlen);
            $token .= $str[$char];
        }
        
        return $token;
    }
    
    /**
    * Generates a random web password
    * Uses mixed-case letters and numbers to generate a random 8-character string.
    * @return string
    * @see sloodle_random_security_token()
    */
    function sloodle_random_web_password()
    {
        // Define the characters we can use in our token, and get the length of it
        $str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $strlen = strlen($str) - 1;
        // Prepare the password string
        $pwd = '';
        // Loop once for each output character
        for($length = 0; $length < 8; $length++) {
            // Shuffle the string, then pick and store a random character
            $str = str_shuffle($str);
            $char = mt_rand(0, $strlen);
            $pwd .= $str[$char];
        }
        
        return $pwd;
    }
    
    /**
    * Generates a random prim password (7 to 9 digit number).
    * @return string The password as a string
    */
    function sloodle_random_prim_password()
    {
        return (string)mt_rand(1000000, 999999999);
    }
    
    /**
    * Converts a string vector to an array vector.
    * String vector should be of format "<x,y,z>".
    * Converts to associative array with members 'x', 'y', and 'z'.
    * Returns false if input parameter was not of correct format.
    * @param string $vector A string vector of format "<x,y,z>".
    * @return mixed
    * @see sloodle_array_to_vector()
    * @see sloodle_round_vector()
    */
    function sloodle_vector_to_array($vector)
    {
        if (preg_match('/<(.*?),(.*?),(.*?)>/',$vector,$vectorbits)) {
            $arr = array();
            $arr['x'] = $vectorbits[1];
            $arr['y'] = $vectorbits[2];
            $arr['z'] = $vectorbits[3];
            return $arr;
        }
        return false;
    }
    
    /**
    * Converts an array vector to a string vector.
    * Array vector should be associative, containing elements 'x', 'y', and 'z'.
    * Converts to a string vector of format "<x,y,z>".
    * @return string
    * @see sloodle_vector_to_array()
    * @see sloodle_round_vector()
    */
    function sloodle_array_to_vector($arr)
    {
        $ret = '<'.$arr['x'].','.$arr['y'].','.$arr['z'].'>';
        return $ret;
    }
    
    /**
    * Obtains the identified course module instance database record.
    * @param int $id The integer ID of a course module instance
    * @return mixed  A database record if successful, or false if it could not be found
    */
    function sloodle_get_course_module_instance($id)
    {
        return sloodle_get_record('course_modules', 'id', $id);
    }
    
    /**
    * Determines whether or not the specified course module instance is visible.
    * Checks that the instance itself and the course section are both valid.
    * @param int $id The integer ID of a course module instance.
    * @return bool True if visible, or false if invisible or not found
    */
    function sloodle_is_course_module_instance_visible($id)
    {
        // Get the course module instance record, whether directly from the parameter, or from the database
        if (is_object($id)) {
            $course_module_instance = $id;
        } else if (is_int($id)) {
            if (!($course_module_instance = sloodle_get_record('course_modules', 'id', $id))) return FALSE;
        } else return FALSE;
        
        // Make sure the instance itself is visible
        if ((int)$course_module_instance->visible == 0) return FALSE;
        // Find out which section it is in, and if that section is valid
        if (!($section = sloodle_get_record('course_sections', 'id', $course_module_instance->section))) return FALSE;
        if ((int)$section->visible == 0) return FALSE;
        
        // Looks like the module is visible
        return TRUE;
    }
    
    /**
    * Determines if the specified course module instance is of the named type.
    * For example, this can check if a particular instance is a "forum" or a "chat".
    * @param int $id The integer ID of a course module instance
    * @param string $module_name Module type to check (must be the exact name of an installed module, e.g. 'sloodle' or 'quiz')
    * @return bool True if the module is of the specified type, or false otherwise
    */
    function sloodle_check_course_module_instance_type($id, $module_name)
    {
        // Get the record for the module type
        if (!($module_record = sloodle_get_record('modules', 'name', $module_name))) return FALSE;

        // Get the course module instance record, whether directly from the parameter, or from the database
        if (is_object($id)) {
            $course_module_instance = $id;
        } else if (is_int($id)) {
            if (!($course_module_instance = sloodle_get_record('course_modules', 'id', $id))) return FALSE;
        } else return FALSE;
        
        // Check the type of the instance
        return ($course_module_instance->module == $module_record->id);
    }
    
    /**
    * Obtains the ID number of the specified module (type not instance).
    * @param string $name The name of the module type to check, e.g. 'sloodle' or 'forum'
    * @return mixed Integer containing module ID, or false if it is not installed
    */
    function sloodle_get_module_id($name)
    {
        // Ensure the name is a non-empty string
        if (!is_string($name) || empty($name)) return FALSE;
        // Obtain the module record
        if (!($module_record = sloodle_get_record('modules', 'name', $module_name))) return FALSE;
        
        return $module_record->id;
    }
    
    /**
    * Checks if the specified position is in the current (site-wide) loginzone.
    * @param mixed $pos A string vector or an associated array vector
    * @return bool True if position is in LoginZone, or false if not
    * @see sloodle_login_zone_coordinates()
    * @todo Update or remove... no longer valid
    */
    function sloodle_position_is_in_login_zone($pos)
    {
        // Get a position array from the parameter
        $posarr = NULL;
        if (is_array($pos) && count($pos) == 3) {
            $posarr = $pos;
        } else if (is_string($pos)) {
            $posarr = sloodle_vector_to_array($pos);
        } else {
            return FALSE;
        }
        // Fetch the loginzone boundaries
        list($maxarr,$minarr) = sloodle_login_zone_coordinates();

        // Make sure the position is not past the maximum bounds
        if ( ($posarr['x'] > $maxarr['x']) || ($posarr['y'] > $maxarr['y']) || ($posarr['z'] > $maxarr['z']) ) {
            return FALSE;
        }
        // Make sure the position is not past the minimum bounds
        if ( ($posarr['x'] < $minarr['x']) || ($posarr['y'] < $minarr['y']) || ($posarr['z'] < $minarr['z']) ) {
            return FALSE;
        }

        return TRUE;
    }
    
    /**
    * Generates teleport coordinates for a user who has already finished the LoginZone process.
    * @param string $pos A string vector giving the position of the LoginZone
    * @param string $size A string vector giving the size of the LoginZone
    * @return array, bool An associative array vector containing a teleport location, or false if the operation fails.
    */
    function sloodle_finished_login_coordinates($pos, $size)
    {
        // Make sure the parameters are valid types
        if (!is_string($pos) || !is_string($size)) {
            return FALSE;
        }
        // Convert both to arrays
        $posarr = sloodle_vector_to_array($pos);
        $sizearr = sloodle_vector_to_array($size);
        // Calculate a position just below the loginzone
        $coord = array();
        $coord['x'] = round($posarr['x'],0);
        $coord['y'] = round($posarr['y'],0);
        $coord['z'] = round(($posarr['z']-(($sizearr['z'])/2)-2),0);
        return $coord;
    }
    
    /**
    * Generates a random position within a cuboid zone of the specified size.
    * (Note: leaves a 2 metre margin round the outside)
    * @param array $size Associative array giving the size of the zone
    * @return array An associative vector array
    */
    function sloodle_random_position_in_zone($size)
    {
        // Construct the half-size array
        $halfsize = array('x'=>($size['x'] / 2.0) - 2.0, 'y'=>($size['y'] / 2.0) - 2.0, 'z'=>($size['z'] / 2.0) - 2.0);
    
        $pos = array();
        $pos['x'] = mt_rand(0.0, $size['x'] - 4.0) - $halfsize['x'];
        $pos['y'] = mt_rand(0.0, $size['y'] - 4.0) - $halfsize['y'];
        $pos['z'] = mt_rand(0.0, $size['z'] - 4.0) - $halfsize['z'];
        return $pos;
    }

    // Round the specified 3d vector to integer values
    // $pos should be a vector string "<x,y,z>" or an associative array {x,y,z}
    // Return is the same as the type passed-in
    // If the input type is unrecognised, it simply returns it back out unchanged
    /**
    * Rounds the specified 3d vector integer values.
    * Can handle/return a string vector, or an array vector.
    * (Output type matches input type).
    * @param mixed $pos Either a string vector or an array vector
    * @return mixed
    */
    function sloodle_round_vector($pos)
    {
        // We will work with an array, but allow for conversion to/from string
        $arrayvec = $pos;
        $returnstring = FALSE;
        // Is it a string?
        if (is_string($pos)) {
            $arrayvec = sloodle_vector_to_array($pos);
            $returnstring = TRUE;
        } else if (!is_array($pos)) {
            return $pos;
        }
    
        // Construct an output array
        $output = array();
        foreach ($arrayvec as $key => $val) {
            $output[$key] = round($val, 0);
        }
        
        // If we need to convert it back to a string, then do so
        if ($returnstring) {
            return sloodle_array_to_vector($output);
        }
        
        return $output;
    }
    
    /**
    * Calculates the maximum and minimum bounds of the specified LoginZone
    * Returns the bounds as a numeric array of two associate array vectors: ($max, $min).
    * (Or returns false if no LoginZone position/size could be found in the Moodle configuration table).
    * @param string $pos A string vector giving the position of the LoginZone
    * @param string $size A string vector giving the size of the LoginZone
    * @return array
    */
    function sloodle_login_zone_bounds($pos, $size)
    {
        // Make sure the parameters are valid types
        if (($pos == FALSE) || ($size == FALSE)) {
            return FALSE;
        }
        // Convert both to arrays
        $posarr = sloodle_vector_to_array($pos);
        $sizearr = sloodle_vector_to_array($size);
        // Calculate the bounds
        $max = array();
        $max['x'] = $posarr['x']+(($sizearr['x'])/2)-2;
        $max['y'] = $posarr['y']+(($sizearr['y'])/2)-2;
        $max['z'] = $posarr['z']+(($sizearr['z'])/2)-2;
        $min = array();
        $min['x'] = $posarr['x']-(($sizearr['x'])/2)+2;
        $min['y'] = $posarr['y']-(($sizearr['y'])/2)+2;
        $min['z'] = $posarr['z']-(($sizearr['z'])/2)+2;
        
        return array($max,$min);
    }
    
    
    /**
    * Checks if the given prim password is valid.
    * @param string $password The password string to check
    * @return bool True if it is valid, or false otherwise.
    */
    function sloodle_validate_prim_password($password)
    {
        // Check that it's a string
        if (!is_string($password)) return false;
        // Check the length
        $len = strlen($password);
        if ($len < 5 || $len > 9) return false;
        // Check that it's all numbers
        if (!ctype_digit($password)) return false;
        // Check that it doesn't start with a 0
        if ($password[0] == '0') return false;
        
        // It all seems fine
        return true;
    }
    
    /**
    * Checks if the given prim password is valid, and provides feedback.
    * An array is written to by reference, each element containing error codes.
    * Each error code is a word. The full text of the error message may be obtained
    *  from the string file by looking for "primpass:errorcode".
    *
    * @param string $password The password to validate
    * @param array &$errors An array (passed by reference) which will contain any error messages
    * @return bool True if the prim password is valid, or false otherwise
    */
    function sloodle_validate_prim_password_verbose($password, &$errors)
    {
        // Initialise variables
        $errors = array();
        $result = true;
        
        // Check that it's a string
        if (!is_string($password)) {
            $errors[] = 'invalidtype';
            $result = false;
        }
        // Check the length
        $len = strlen($password);
        if ($len < 5) {
            $errors[] = 'tooshort';
            $result = false;
        }
        if ($len > 9) {
            $errors[] = 'toolong';
            $result = false;
        }
        
        // Check that it's all numbers
        if (!ctype_digit($password)) {
            $errors[] = 'numonly';
            $result = false;
        }
        
        // Check that it doesn't start with a 0
        if ($password[0] == '0') {
            $errors[] = 'leadingzero';
            $result = false;
        }
        
        return $result;
    }
    
    
    /**
    * Stores a pending login notification for an auto-registered user.
    * A cron job will process the pending notification queue.
    * @param string $destination Identifies the destination of the notification (for SL, this will be the object UUID. The send function will construct the email address)
    * @param string $avatar Identifier for the avatar being notified
    * @param string $username The username to notify the user of
    * @param string $password The (plaintext) password to notify the user of
    * @return bool True if successful, or false otherwise
    */
    function sloodle_login_notification($destination, $avatar, $username, $password)
    {
        // If another pending notification already exists for the same username, then delete it
        sloodle_delete_records('sloodle_login_notifications', 'username', $username);
        
        // Add the new details
        $notification = new stdClass();
        $notification->destination = $destination;
        $notification->avatar = $avatar;
        $notification->username = $username;
        $notification->password = $password;

        return (bool)sloodle_insert_record('sloodle_login_notifications', $notification);
    }
    
    /**
    * Send a login notification.
    * @param string $destination Identifies the destination of the notification (for SL, this will be the object UUID. The target email address will be constructed)
    * @param string $avatar Identifier for the avatar being notified
    * @param string $username The username to notify the user of
    * @param string $password The (plaintext) password to notify the user of
    * @return bool True if successful, or false otherwise
    */
    function sloodle_send_login_notification($destination, $avatar, $username, $password)
    {
        global $CFG;
        return sloodle_text_email_sl($destination, 'SLOODLE_LOGIN', "$avatar|{$CFG->wwwroot}|$username|$password");
    }
    
    /**
    * Processes pending login notifications, up to a certain limit.
    * Retrieves the requests one-at-a-time for processing.
    * This is slower, but ensures minimal damage if the process is terminated, e.g. due to server timeout.
    * @param int $limit The maximum number of pending requests to process.
    * @return void
    */
    function sloodle_process_login_notifications($limit = 25)
    {
        global $CFG;
        
        // Validate the limit
        $limit = (int)$limit;
        if ($limit < 1) return;
        
        // Go through each one
        for ($i = 0; $i < $limit; $i++) {
            // Obtain the first record
            $recs = sloodle_get_records('sloodle_login_notifications', '', '', 'id', '*', 0, $limit);
            if (!$recs) return false;
            reset($recs);
            $rec = current($recs);
            
            // Determine the user ID of the person who requested this
            $userid = 0;
            if (!($sloodleuser = sloodle_get_record('sloodle_users', 'uuid', $rec->avatar))) {
                // Failed to the user - get the guest user instead
                $guestdata = guest_user();
                $userid = $guestdata->id;
            } else {
                // Got the data - store the user ID
                $userid = $sloodleuser->userid;
            }
            
            // Send the notification
            if (sloodle_send_login_notification($rec->destination, $rec->avatar, $rec->username, $rec->password)) {
                // Log the notification
                 add_to_log(SITEID, 'sloodle', 'view', '', 'Sent login details by email to avatar in-world', 0, $userid);
            } else {
                // Log the failed notification (but don't keep trying the same one)
                add_to_log(SITEID, 'sloodle', 'view failed', '', 'Failed to send login details by email to avatar in-world', 0, $userid);
            }
            
            // Delete the record from the data
            sloodle_delete_records('sloodle_login_notifications', 'id', $rec->id);
        }
    }
    
    
    /**
    * Extracts a value from a name-value associative array if it is set.
    * (The array should associate name to value).
    * @param array $settings The array of names and values
    * @param string $name The name of the value to retrieve
    * @param mixed $default The default value to return if the specified value was not found
    * @return mixed The value from the input array, or the $default parameter
    */
    function sloodle_get_value($settings, $name, $default = null)
    {
        if (is_array($settings) && isset($settings[$name])) return $settings[$name];
        return $default;
    }
    
    
    /**
    * Outputs the standard form elements for access levels in object configuration.
    * Each part can be optionally hidden, and default values can be provided.
    * (Note: the server access level must be communicated from the object back to Moodle... rubbish implementation, but it works!)
    * @param array $current_config An associative array of setting names to values, containing defaults. (Ignored if null).
    * @param bool $show_use_object Determines whether or not the "Use Object" setting is shown
    * @param bool $show_control_object Determines whether or not the "Control Object" setting is shown
    * @param bool $show_server Determines whether or not the server access setting is shown
    * @return void
    */
    function sloodle_print_access_level_options($current_config, $show_use_object = true, $show_control_object = true, $show_server = true)
    {
        // Quick-escape: if everything is being suppressed, then do nothing
        if (!($show_use_object || $show_control_object || $show_server)) return;
        
        // Fetch default values from the configuration, if possible
        $sloodleobjectaccessleveluse = sloodle_get_value($current_config, 'sloodleobjectaccessleveluse', SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC);
        $sloodleobjectaccesslevelctrl = sloodle_get_value($current_config, 'sloodleobjectaccesslevelctrl', SLOODLE_OBJECT_ACCESS_LEVEL_OWNER);
        $sloodleserveraccesslevel = sloodle_get_value($current_config, 'sloodleserveraccesslevel', SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC);
        
        // Define our object access level array
        $object_access_levels = array(  SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => get_string('accesslevel:public','sloodle'),
                                        SLOODLE_OBJECT_ACCESS_LEVEL_GROUP => get_string('accesslevel:group','sloodle'),
                                        SLOODLE_OBJECT_ACCESS_LEVEL_OWNER => get_string('accesslevel:owner','sloodle') );
        // Define our server access level array
        $server_access_levels = array(  SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC => get_string('accesslevel:public','sloodle'),
                                        SLOODLE_SERVER_ACCESS_LEVEL_COURSE => get_string('accesslevel:course','sloodle'),
                                        SLOODLE_SERVER_ACCESS_LEVEL_SITE => get_string('accesslevel:site','sloodle'),
                                        SLOODLE_SERVER_ACCESS_LEVEL_STAFF => get_string('accesslevel:staff','sloodle') );
    
        // Display box and a heading
        print_box_start('generalbox boxaligncenter');
        echo '<h3>'.get_string('accesslevel','sloodle').'</h3>';
    
        // Print the object settings
        if ($show_use_object || $show_control_object) {
            
            // Object access
            echo '<b>'.get_string('accesslevelobject','sloodle').'</b><br><i>'.get_string('accesslevelobject:desc','sloodle').'</i><br><br>';
            // Use object
            if ($show_use_object) {
                echo get_string('accesslevelobject:use','sloodle').': ';
                choose_from_menu($object_access_levels, 'sloodleobjectaccessleveluse', $sloodleobjectaccessleveluse, '');
                echo '<br><br>';
            }
            // Control object
            if ($show_control_object) {
                echo get_string('accesslevelobject:control','sloodle').': ';
                choose_from_menu($object_access_levels, 'sloodleobjectaccesslevelctrl', $sloodleobjectaccesslevelctrl, '');
                echo '<br><br>';
            }
        }
        
        // Print the server settings
        if ($show_server) {
            // Server access
            echo '<b>'.get_string('accesslevelserver','sloodle').'</b><br><i>'.get_string('accesslevelserver:desc','sloodle').'</i><br><br>';
            echo get_string('accesslevel','sloodle').': ';
            choose_from_menu($server_access_levels, 'sloodleserveraccesslevel', $sloodleserveraccesslevel, '');
            echo '<br>';
        }        
        
        print_box_end();
    }

    function sloodle_access_level_option_choice($option, $current_config, $show, $prefix = '', $suffix = '') {

	$access_levels = array();
        if ($option == 'sloodleserveraccesslevel') {
            $access_levels = array( SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC => get_string('accesslevel:public','sloodle'),
                                    SLOODLE_SERVER_ACCESS_LEVEL_COURSE => get_string('accesslevel:course','sloodle'),
                                    SLOODLE_SERVER_ACCESS_LEVEL_SITE => get_string('accesslevel:site','sloodle'),
                                    SLOODLE_SERVER_ACCESS_LEVEL_STAFF => get_string('accesslevel:staff','sloodle') 
                                  );
        } else {
            $access_levels = array( SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => get_string('accesslevel:public','sloodle'),
                                    SLOODLE_OBJECT_ACCESS_LEVEL_GROUP => get_string('accesslevel:group','sloodle'),
                                    SLOODLE_OBJECT_ACCESS_LEVEL_OWNER => get_string('accesslevel:owner','sloodle') 
                                  );
        }

        $defaults = array(
            'sloodleobjectaccessleveluse' => SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC,
            'sloodleobjectaccesslevelctrl' => SLOODLE_OBJECT_ACCESS_LEVEL_OWNER,
            'sloodleserveraccesslevel' => SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC
        );

        // Fetch default values from the configuration, if possible
        $selected_value = sloodle_get_value($current_config, $option, $defaults[$option]);
        
        if ($show) {
            return choose_from_menu($access_levels, $prefix.$option.$suffix, $selected_value, '', '', 0, $return = true);
        } else {
            return '&nbsp;';
        } 
        
    }


    /**
    * Returns a very approximate natural language description of a period of time (in minutes, hours, days, or weeks).
    * Can also be used to describe how long ago something happened, in which case anything less than 1 minute is treated as 'now'.
    * @param int $secs Number of seconds in period of time
    * @param bool $ago If true (not default), then the time will be described in past tense, e.g. "3 days ago", as opposed to simply "3 days".
    * @return string
    */
    function sloodle_describe_approx_time($secs, $ago = false)
    {
        // Make sure the time is a positive integer
        $secs = (int)$secs;
        if ($secs < 0) $secs *= -1;
        
        // Less than a minute
        if ($secs < 60) {
            // If we are describing a past time, then approximate to 'now'
            if ($ago) return ucwords(get_string('now', 'sloodle'));
            // Give the number of seconds
            if ($secs == 1) return '1 '. get_string('second', 'sloodle');
            return $secs.' '. get_string('seconds', 'sloodle');
        }
        
        // This variable will hold the time description
        $desc = '';
        
        // Roughly 1 minute
        if ($secs < 120) $desc = '1 '. get_string('minute', 'sloodle');
        // Several minutes (up to 1 hour)
        else if ($secs < 3600) $desc = ((string)(int)($secs / 60)).' '. get_string('minutes', 'sloodle');
        // Roughly 1 hour
        else if ($secs < 7200) $desc = '1 '. get_string('hour', 'sloodle');
        // Several hours (up to 1 day)
        else if ($secs < 86400) $desc = ((string)(int)($secs / 3600)).' '. get_string('hours', 'sloodle');
        // Roughly 1 day
        else if ($secs < 172800) $desc = '1 '. get_string('day', 'sloodle');
        // Several days (up to 1 week)
        else if ($secs < 604800) $desc = ((string)(int)($secs / 86400)).' '. get_string('days', 'sloodle');
        // Roughly 1 week
        else if ($secs < 1209600) $desc = '1 '. get_string('week', 'sloodle');
        // Several weeks (up to 2 months)
        else if ($secs < 5184000) $desc = ((string)(int)($secs / 604800)).' '. get_string('weeks', 'sloodle');
        // Several months (up to 11 months)
        else if ($secs < 29462400) $desc = ((string)(int)($secs / 2592000)).' '. get_string('months', 'sloodle');
        // 1 year
        else if ($secs < 63072000) $desc = '1 '. get_string('year', 'sloodle');
        // Several years
        else $desc = ((string)(int)($secs / 31536000)).' '. get_string('years', 'sloodle');
        
        // Add 'ago' if necessary
        if ($ago) return get_string('timeago', 'sloodle', $desc);
        return $desc;
    }
    
    /**
    * Gets the basic URL of the current web-page being accessed.
    * Includes the protocol, hostname, and script path/name.
    * @return string
    */
    function sloodle_get_web_path()
    {
        // Check for the protocol
        if (empty($_SERVER['HTTPS']) || $_SERVER['HTTPS'] == 'off') $protocol = "http";
        else $protocol = "https";
        // Get the host name (e.g. domain)
        $host = $_SERVER['SERVER_NAME'];
        // Finally, get the script path/name
        $file = $_SERVER['SCRIPT_NAME'];
        
        return $protocol.'://'.$host.$file;
    }
    
    /**
    * Gets an array of subdirectories within the given directory.
    * Ignores anything which starts with a .
    * @param string $dir The directory to search WITHOUT a trailing slash. (Note: cannot search the current directory or higher in the file hierarchy)
    * @param bool $relative If TRUE (default) the array of results will be relative to the input directory. Otherwise, they will include the input directory path.
    * @return array|false A numeric array of subdirectory names sorted alphabetically, or false if an error occurred (such as the input value not being a directory)
    */
    function sloodle_get_subdirectories($dir, $relative = true)
    {
        // Make sure we have a valid directory
        if (empty($dir)) return false;
        // Open the directory
        if (!is_dir($dir)) return false;
        if (!$dh = opendir($dir)) return false;
        
        // Go through each item
        $output = array();
        while (($file = readdir($dh)) !== false) {
            // Ignore anything starting with a . and anything which isn't a directory
            if (strpos($file, '.') == 0) continue;
            $filetype = @filetype($dir.'/'.$file);
            if (empty($filetype) || $filetype != 'dir') continue;
            
            // Store it
            if ($relative) $output[] = $file;
            else $output[] = $dir.'/'.$file;
        }
        closedir($dh);
        natcasesort($output);
        return $output;
    }
    
    /**
    * Gets an array of files within the given directory.
    * Ignores anything which starts with a .
    * @param string $dir The directory to search WITHOUT a trailing slash. (Note: cannot search the current directory or higher in the file hierarchy)
    * @param bool $relative If TRUE (default) the array of results will be relative to the input directory. Otherwise, they will include the input directory path.
    * @return array|false A numeric array of file names sorted alphabetically, or false if an error occurred (such as the input value not being a directory)
    */
    function sloodle_get_files($dir, $relative = true)
    {
        // Make sure we have a valid directory
        if (empty($dir)) return false;
        // Open the directory
        if (!is_dir($dir)) return false;
        if (!$dh = opendir($dir)) return false;
        
        // Go through each item
        $output = array();
        while (($file = readdir($dh)) !== false) {
            // Ignore anything starting with a . and anything which isn't a file
            if (strpos($file, '.') == 0) continue;
            $filetype = @filetype($dir.'/'.$file);
            if (empty($filetype) || $filetype != 'file') continue;
            
            // Store it
            if ($relative) $output[] = $file;
            else $output[] = $dir.'/'.$file;
        }
        closedir($dh);
        natcasesort($output);
        return $output;
    }
    
    
    /**
    * Gets all object types and versions available in this installation.
    * Creates a 2-dimensional associative array.
    * The top level is the object name, and the second is the object version (both as strings).
    * The associated value is the path to the configuration form script, or boolean false
    *  if the object has no configuration options.
    * @return array|false Returns a 2d associative array if successful, or false if an error occurs
    */
    function sloodle_get_installed_object_types()
    {
        // Fetch all sub-directories of the "mod" directory
        
        // Go through each object to parse names and version numbers.
        // Object names should have format "name-version" (e.g. "chat-1.0").
        // We will skip anything that does not match this format.
        // We will also skip anything with a "noshow" file in the folder.

	return SloodleObjectConfig::AllAvailableAsNameVersionHash();

    }
   

    /**
    * Render a page viewing a particular feature, or a SLOODLE module.
    * Outputs error text in SLOODLE debug mode.
    * @param string $feature The name of a feature to view ("course", "user", "users"), or "module" to indicate that we are viewing some kind of module. Note: features should contain only alphanumric characters.
    * @return bool True if successful, or false if not.
    */
    function sloodle_view($feature)
    {
        global $CFG, $USER;
        // Make sure the parameter is safe -- nothing but alphanumeric characters.
        if (!ctype_alnum($feature)) {
            sloodle_debug('sloodle_view(..): Invalid characters in view feature, "'.$feature.'"');
            return false;
        }
        if (empty($feature)) {
            sloodle_debug('sloodle_view(..): No feature name specified.');
            return false;
        }
        $feature = trim($feature);

        // Has a module been requested?
        if (strcasecmp($feature, 'module') == 0) {
            // We should have an ID parameter, indicating which module has been requested
            $id = required_param('id', PARAM_INT);
            // Query the database for the SLOODLE module sub-type
            $instanceid = sloodle_get_field('course_modules', 'instance', 'id', $id);
            if ($instanceid === false) error('Course module instance '.$id.' not found.');
            $type = sloodle_get_field('sloodle', 'type', 'id', $instanceid);
            if ($type === false) error('SLOODLE module instance '.$instanceid.' not found.');
            // We will just use the type as a feature name now.
            // This means the following words are unavailable as module sub-types: course, user, users
            $feature = $type;
        }

        // Attempt to include the relevant viewing class
        $filename = SLOODLE_DIRROOT."/view/{$feature}.php";
        if (!file_exists($filename)) {
            error("SLOODLE file not found: view/{$feature}.php");
            exit();
        }
        require_once($filename);

        // Create and execute the viewing instance
        $classname = 'sloodle_view_'.$feature;
        if (!class_exists($classname)) {
            error("SLOODLE class missing: {$classname}");
            exit();
        }
        $viewer = new $classname();
        $viewer->view();

        return true;
    } 

    /**
    * Returns the given string, 'cleaned' and ready for output to SL as UTF-8.
    * Removes tags and slash-characters.
    * @param string str The string to clean.
    * @return string
    */
    function sloodle_clean_for_output($str)
    {
        return sloodle_strip_new_lines(strip_tags(stripcslashes(@html_entity_decode($str, ENT_QUOTES, 'UTF-8'))));
    }

    /**
    * Returns the src of the first <img> tag found in the html
    * @param string str The string to clean.
    * @return string
    */
    function sloodle_extract_first_image_url($html) {
        if (preg_match("/<img .*?(?=src)src=\"([^\"]+)\"/si", $html, $m)) {
        	return $m[1];
        }
        return '';
    }

    /**
    * Returns the given string with new line characters removed
    * Removes new line characters
    * @param string data The string to clean.
    * @return string
    */
    function sloodle_strip_new_lines($data) {
        $data=str_replace("\r","",$data);
        $data=str_replace("\n","",$data); 
        return $data;
    }

    /**
    * Returns the given string, 'cleaned' and ready for storage in the database.
    * Note: removes tags and slash-characters.
    * @param string str The string to clean.
    * @return string
    */
    function sloodle_clean_for_db($str)
    {
        return htmlentities($str, ENT_QUOTES, 'UTF-8');
    }

    /**
    * Converts a shorthand file size to a number of bytes, if necessary.
    * This follows PHP shorthand, with K for Kilobytes, M for Megabytes, and G for Gigabytes.
    * @param string size The shorthand size to conert
    * @return integer The size specified in bytes
    */
    function sloodle_convert_file_size_shorthand($size)
    {
        $size = trim($size);
        $num = (int)$size;
        $char = strtolower($size{strlen($size)-1});
        switch ($char)
        {
        case 'g': $num *= 1024;
        case 'm': $num *= 1024;
        case 'k': $num *= 1024;
        }

        return $num;
    }

    /**
    * Converts a file size to plain text.
    * For example, will convert "1024" to "1 kilobyte".
    * @param integer|string size If an integer, then it is the number of bytes. If a string, then it can be PHP shorthand, such as "1M" for 1 megabyte.
    * @return string A text string describing the specified size.
    */
    function sloodle_get_size_description($size)
    {
        // Make sure we have a number of bytes
        $bytes = 0;
        if (is_int($size)) $bytes = $size;
        else $bytes = sloodle_convert_file_size_shorthand($size);
        $desc = '';

        // Keep the number small by going with the largest possible units
        if ($bytes >= 1073741824) $desc = ($bytes / 1073741824)." GB";
        else if ($bytes >= 1048576) $desc = ($bytes / 1048576). " MB";
        else if ($bytes >= 1024) $desc = ($bytes / 1024). " KB";
        else $desc = $bytes . " bytes";

        return $desc;
    }

    /**
    * Gets the maximum size of a file (in bytes) that can be uploaded using POST.
    * @return integer
    */
    function sloodle_get_max_post_upload()
    {
        // Get the sizes of the relevant limits
        $upload_max_filesize = sloodle_convert_file_size_shorthand(ini_get('upload_max_filesize'));
        $post_max_size = sloodle_convert_file_size_shorthand(ini_get('post_max_size'));

        // Use the smaller limit
        return min($upload_max_filesize, $post_max_size);
    }

    /*
    Used to sign a piece of data to ensure that data passed to the user was issued by us.
    Made for the presenter image upload, where we can't use the session because the flash component that talks to the server won't pass a cookie.
    */
    function sloodle_signature($data) {
    	global $CFG;

        $salt = '';
        if ( isset($CFG->sloodle_signature_salt) && ($CFG->sloodle_signature_salt != '' ) ) {
            $salt = $CFG->sloodle_signature_salt;
        } else {
            $salt = random_string(40);
            set_config('sloodle_signature_salt', $salt);
        }

        if (function_exists('hash_hmac')) {
            return hash_hmac('sha256', $data, $salt);
        }
        return sloodle_custom_hmac('sha1', $data, $salt);
    }

    // From http://php.net/manual/en/function.hash-hmac.php
    // For use if the php hash_hmac isn't available
   function sloodle_custom_hmac($algo, $data, $key, $raw_output = false)
   {
       $algo = strtolower($algo);
       $pack = 'H'.strlen($algo('test'));
       $size = 64;
       $opad = str_repeat(chr(0x5C), $size);
       $ipad = str_repeat(chr(0x36), $size);

       if (strlen($key) > $size) {
           $key = str_pad(pack($pack, $algo($key)), $size, chr(0x00));
       } else {
           $key = str_pad($key, $size, chr(0x00));
       }

       for ($i = 0; $i < strlen($key) - 1; $i++) {
           $opad[$i] = $opad[$i] ^ $key[$i];
           $ipad[$i] = $ipad[$i] ^ $key[$i];
       }

       $output = $algo($opad.pack($pack, $algo($ipad.$data)));

       return ($raw_output) ? pack($pack, $output) : $output;
    }

?>
