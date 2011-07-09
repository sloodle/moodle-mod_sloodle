<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines the primary API class, SloodleSession.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    /** General functionality. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Request and response functionality. */
    require_once(SLOODLE_LIBROOT.'/io.php');
    /** User functionality. */
    require_once(SLOODLE_LIBROOT.'/user.php');
    /** Course functionality. */
    require_once(SLOODLE_LIBROOT.'/course.php');
    /** Sloodle Controller functionality. */
    require_once(SLOODLE_LIBROOT.'/controller.php');
    /** Module functionality. */
    require_once(SLOODLE_LIBROOT.'/modules.php');
    /** Plugin management. */
    require_once(SLOODLE_LIBROOT.'/plugins.php');

    /** Active Objects and their definitions. */
    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    
    /**
    * The primary API class, which manages all other parts.
    * @package sloodle
    */
    class SloodleSession
    {
    // DATA //
        
        /**
        * Incoming HTTP request.
        * @var SloodleRequest
        * @access public
        */
        var $request = null;
    
        /**
        * Outgoing response - can be rendered to HTTP or as a string.
        * @var SloodleResponse
        * @access public
        */
        var $response = null;
        
        /**
        * Current user information.
        * @var SloodleUser
        * @access public
        */
        var $user = null;
        
        /**
        * The Sloodle course structure for the course this session is accessing
        * @var SloodleCourse
        * @access public
        */
        var $course = null;
        
        /**
        * The Sloodle module this session relates to, if any.
        * Note: this may be the base Sloodle module class, or a derivative.
        * @var SloodleModule
        * @access public
        */
        var $module = null;

        /**
        * A plugin manager to help give access to plugins for various features.
        * @var SloodlePluginManager
        * @access public
        */
        var $plugins = null;

         /**
        * A SloodleActiveObject object representing the in-world object making the request.
        * @var $active_object
        * @access public
	* In case of notecard configuration, this may be null. 
	* (This should change in the future so that the server knows about all the objects it works with.)
	* TODO: The relationship between this and the controller could do with some work - 
	*  ... and some of the functionality in the controller should probably move to the active object.
	*  ... but we can't fix that until we've made all objects be represented by and active object, even notecard ones.
        */
        var $active_object = null;
        

    // FUNCTIONS //
    
        /**
        * Constructor - initialises members
        * @param bool $process If true (default) then basic request data will be processed immediately. Otherwise, it can be done manually by calling $request->process_request_data()
        */
        function SloodleSession($process = true)
        {
            // Construct the different parts of the session, as far as possible
            $this->user = new SloodleUser($this);
            $this->response = new SloodleResponse();
            $this->request = new SloodleRequest($this);
            $this->course = new SloodleCourse();
            $this->plugins = new SloodlePluginManager($this);
            
            // Process the basic request data
            if ($process) $this->request->process_request_data();

            // Active Object loading is happening right before check_authorization.
            // It should probably be happening earlier...
            // This whole thing should probably be happening backwards: 
            // Load up the active object, check it's OK, load it's controller, check it's active, load the course, etc.

        }
        
        
        /**
        * Constructs and loads the appropriate module part of the session.
        * Note that this function will fail if the current VLE user (in the $user member) does not have permission to access it.
        * @param string $type The expected type of module - function fails if type is not correctly matched
        * @param bool $db If true then the system will also try to load appropriate data from the database, as specified in the module ID request parameter
        * @param bool $require If true, then if something goes wrong, the script will be terminated with an error message
        * @param bool $override_access If true, then access can be gained to a module on a separate course from the current controller
        * @return bool True if successful, or false otherwise. (Note, if parameter $require was true, then the script will terminate before this function returns if something goes wrong)
        */
        function load_module($type, $db, $require = true, $override_access = false)
        {
            // If the database loading is requested, then make sure we have a parameter to load with
            $db_id = null;
            if ($db) {
                $db_id = $this->request->get_module_id($require);
                if ($db_id == null) return false;
                
                // Is access being overridden?
                if (!$override_access) {
                	// No
                	// Make sure we have a controller loaded
                	if (!$this->course->is_loaded() || !$this->course->controller->is_loaded()) {
                		if ($require) {
                			$this->response->quick_output(-714, 'MODULE_INSTANCE', 'Access has not been authenticated through a Controller. Access prohibited.', false);
                    		exit();
                		}
                		return false;
                	}
                	// Does the specified module instance exist in this course?
                	if (!record_exists('course_modules', 'id', $db_id, 'course', $this->course->get_course_id())) {
                		if ($require) {
                			$this->response->quick_output(-714, 'MODULE_INSTANCE', 'Module not found in requested course.', false);
                    		exit();
                		}
                		return false;
                	}
                }
            }

            // Construct the module
            $this->module = sloodle_load_module($type, $this, $db_id);
            if (!$this->module) {
                if ($require) {
                    $this->response->quick_output(-601, 'MODULE', 'Failed to construct module object', false);
                    exit();
                }
                return false;
            }
        }
        
        
        /**
        * Verifies security for the incoming request (but does not check user access).
        * Initially ensures that the request is coming in on a valid and enabled course/controller (rejects it if not).
        * The password is then checked, and it can handle prim-passwords and object-specific passwords.
        *
        * @param bool $require If true, the function will NOT return on authentication failure. Rather, it will terminate the script with an error message.
        * @return bool true if successful in authenticating the request, or false if not.
        */
        function authenticate_request( $require = true )
        {
            // Make sure that the request data has been processed
            if (!$this->request->is_request_data_processed()) {
                $this->request->process_request_data();
            }
            
            // Make sure the controller ID parameter was specified
            if ($this->request->get_controller_id($require) === null) return false;
            
            // Make sure we've got a valid course and controller object
            if (!$this->course->controller->is_loaded()) {
                if ($require) {
                    $this->response->quick_output(-514, 'COURSE', 'Course controller could not be accessed.', false);
                    exit();
                }
                return false;
            }
            if (!$this->course->is_loaded()) {
                if ($require) {
                    $this->response->quick_output(-512, 'COURSE', 'Course could not be accessed.', false);
                    exit();
                }
                return false;
            }
            
            // Make sure the course is available
            if (!$this->course->is_available()) {
                if ($require) {
                    $this->response->quick_output(-513, 'COURSE', 'Course not available.', false);
                    exit();
                }
                return false;
            }
            // Make sure the contrller is available
            if (!$this->course->controller->is_available()) {
                if ($require) {
                    $this->response->quick_output(-514, 'COURSE', 'Course controller not available.', false);
                    exit();
                }
                return false;
            }
            
            // Make sure the controller is enabled
            if (!$this->course->controller->is_enabled()) {
                if ($require) {
                    $this->response->quick_output(-514, 'COURSE', 'Course controller disabled.', false);
                    exit();
                }
                return false;
            }
        
            // Get the password parameter
            $password = $this->request->get_password($require);
            if ($password == null) {
                if ($require) {
                    $this->response->quick_output(-212, 'OBJECT_AUTH', 'Prim Password cannot be empty.', false);
                    exit();
                }
                return false;
            }
            
            // Does the password contain an object UUID?
            $parts = explode('|', $password);
            if (count($parts) >= 2) {
                $objuuid = $parts[0];
                $objpwd = $parts[1];
                // Make sure the password was provided
                if (empty($objpwd)) {
                    if ($require) {
                        $this->response->quick_output(-212, 'OBJECT_AUTH', 'Object-specific password not specified.', false);
                        exit();
                    }
                    return false;
                }
                
                // Load up the active object, if there is one.
	        // TODO: This should probably have happened earlier.
		$ao = new SloodleActiveObject();
		if ($ao->loadByUUID( $objuuid )) {
			$this->active_object = $ao;
		}

                if ($this->course->controller->check_authorisation($this->active_object, $objpwd)) {
                    // Passed authorisation - make sure the object is registered as being still active
                    $this->active_object->recordAccess();
                    return true;
                }
                if ($require) {
                    $this->response->quick_output(-213, 'OBJECT_AUTH', 'Object-specific password was invalid.', false);
                    exit();
                }
                return false;
    		}
            
            // Get the controller password
            $controllerpwd = $this->course->controller->get_password();
            // Prim Password access is disabled if no password has been specified
            if (strlen($controllerpwd) == 0) {
                if ($require) {
                    $this->response->quick_output(-213, 'OBJECT_AUTH', 'Access to this Controller by prim password has been disabled.', false);
                    exit();
                }
                return false;
            }
            // Check that the passwords match
            if ($password != $this->course->controller->get_password()) {
                if ($require) {
                    $this->response->quick_output(-213, 'OBJECT_AUTH', 'Prim password was invalid.', false);
                    exit();
                }
                return false;
            }

            return true;
        }
        
        
        /**
        * Verifies security for the incoming user-centric request.
        * This ensures that the identified object is authorised for user-centric activities with the specified user.
        * @param bool $require If TRUE (default) then the script will terminate with an error message on failure. Otherwise, it will return false on failure.
        * @return bool TRUE if successful, or FALSE on failure (unless parameter $require was TRUE).
        */
        function authenticate_user_request( $require = true )
        {
            // Get the avatar UUID parameter
            $avuuid = $this->request->get_avatar_uuid($require);
            if ($avuuid == null) {
                if ($require) {
                    $this->response->quick_output(-212, 'OBJECT_AUTH', 'Avatar UUID required for user-centric request authentication.', false);
                    exit();
                }
                return false;
            }
        
            // Get the password parameter
            $password = $this->request->get_password($require);
            if ($password == null) {
                if ($require) {
                    $this->response->quick_output(-212, 'OBJECT_AUTH', 'Password cannot be empty.', false);
                    exit();
                }
                return false;
            }
            
            // Does the password contain an object UUID?
            $parts = explode('|', $password);
            if (count($parts) < 2) {
                if ($require) {
                    $this->response->quick_output(-212, 'OBJECT_AUTH', 'Expected UUID and password, separated by pipe character.', false);
                    exit();
                }
                return false;
            }
            
            // Extract the parts
            $objuuid = $parts[0];
            $objpwd = $parts[1];
            
            // Make sure the password was provided
            if (empty($objpwd)) {
                if ($require) {
                    $this->response->quick_output(-212, 'OBJECT_AUTH', 'Object-specific password cannot be empty.', false);
                    exit();
                }
                return false;
            }
            
            // Attempt to retreive a record matching the avatar and object UUID's
            $rec = get_record('sloodle_user_object', 'avuuid', $avuuid, 'objuuid', $objuuid);
            if (!$rec) {
                if ($require) {
                    $this->response->quick_output(-216, 'OBJECT_AUTH', 'Object not found in database.', false);
                    exit();
                }
                return false;
            }
            
            // Make sure the object is authorised
            if (empty($rec->authorised) || $rec->authorised == "0") {
                if ($require) {
                    $this->response->quick_output(-214, 'OBJECT_AUTH', 'Object is not yet authorised.', false);
                    exit();
                }
                return false;
            }
            
            // Make sure the passwords match
            if ($objpwd != $rec->password) {
				if ($require) {
	                $this->response->quick_output(-213, 'OBJECT_AUTH', 'Object-specific password was invalid.', false);
	                exit();
				}
				return false;
            }
            
            // Everything looks fine
            return true;
        }
        
        
        /**
        * Validates the user account and enrolment (ensures there is an avatar linked to a VLE account, and that the VLE account is enrolled in the current course).
        * Attempts auto-registration/enrolment if that is allowed and required, and logs-in the user.
        * Server access level is checked if it is specified in the request parameters.
        * If the request indicates that it relates to an object, then the validation fails.
        * Note: if you only require to ensure that an avatar is registered, then use {@link validate_avatar()}.
        * @param bool $require If true, the script will be terminated with an error message if validation fails
        * @param bool $suppress_autoreg If true, auto-registration will be completely suppressed for this function call
        * @param bool $suppress_autoenrol If true, auto-enrolment will be completely suppressed for this function call
        * @return bool Returns true if validation and/or autoregistration were successful. Returns false on failure (unless $require was true).
        * @see SloodleSession::validate_avatar()
        */
        function validate_user($require = true, $suppress_autoreg = false, $suppress_autoenrol = false)
        {
            // Is it an object request?
            if ($this->request->is_object_request()) {
                if ($require) {
                    $this->response->quick_output(-301, 'USER_AUTH', 'Cannot validate object as user.', false);
                    exit();
                }
                return false;
            }
            
            // Was a server access level specified in the request?
            $sal = $this->request->get_server_access_level(false);
            if ($sal != null) {
                // Check what level was specified
                $sal = (int)$sal;
                $allowed = false;
                $reason = 'Unknown.';
                switch ($sal) {
                case SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC:
                    // Always allowed
                    $allowed = true;
                    break;
                
                case SLOODLE_SERVER_ACCESS_LEVEL_COURSE:
                    // Is a course already loaded?
                    if (!$this->course->is_loaded()) {
                        $reason = 'No course loaded.';
                        break;
                    }
                
                    // Was a user account already fully loaded?
                    if ($this->user->is_avatar_linked()) {
                        // Is the user enrolled on the current course?
                        if ($this->user->is_enrolled($this->course->get_course_id())) $allowed = true;
                        else $reason = 'User not enrolled in course.';
                    } else {
                        $reason = 'User not registered on site.';
                    }
                    break;
                    
                case SLOODLE_SERVER_ACCESS_LEVEL_SITE:
                    // Was a user account already fully loaded?
                    if ($this->user->is_avatar_linked()) $allowed = true;
                    else $reason = 'User not registered on site.';
                    break;
                    
                case SLOODLE_SERVER_ACCESS_LEVEL_STAFF:
                    // Is a course already loaded?
                    if (!$this->course->is_loaded()) {
                        $reason = 'No course loaded.';
                        break;
                    }
                
                    // Was a user account already fully loaded?
                    if ($this->user->is_avatar_linked()) {
                        // Is the user staff on the current course?
                        if ($this->user->is_staff($this->course->get_course_id())) $allowed = true;
                        else $reason = 'User not staff in course.';
                    } else {
                        $reason = 'User not registered on site.';
                    }
                    break;
                    
                default:
                    // Unknown access level
                    $reason = 'Access level not recognised';
                    break;
                }
                
                // Was the user blocked by access level?
                if (!$allowed) {
                    if ($require) {
                        $this->response->quick_output(-331, 'USER_AUTH', $reason, false);
                        exit();
                    }
                    return false;
                }
            }
        
        // REGISTRATION //
        
            // Make sure a the course is loaded
            if (!$this->course->is_loaded()) {
                if ($require) {
                    $this->response->quick_output(-511, 'COURSE', 'Cannot validate user - no course data loaded.', false);
                    exit();
                }
                return false;
            }
        
            // Is the user already loaded?
            if (!$this->user->is_avatar_linked())
            {
                // If an avatar is loaded, but the user isn't, then we probably have a deleted Moodle user
                if ($this->user->is_avatar_loaded() == true && $this->user->is_user_loaded() == false) {
                    $this->response->quick_output(-301, 'USER_AUTH', 'Avatar linked to deleted user account', false);
                    exit();
                }
            
                // Make sure avatar details were provided
                $uuid = $this->request->get_avatar_uuid(false);
                $avname = $this->request->get_avatar_name(false);
                // Is validation required?
                if ($require) {
                    // Check the UUID
                    if (empty($uuid)) {
                        $this->response->quick_output(-311, 'USER_AUTH', 'User UUID required', false);
                        exit();
                    }
                    // Check the name
                    if (empty($avname)) {
                        $this->response->quick_output(-311, 'USER_AUTH', 'Avatar name required', false);
                        exit();
                    }
                } else if (empty($uuid) || empty($avname)) {
                    // If there was a problem, just stop
                    return false;
                }
            
                // Ensure autoreg is not suppressed, and that it is permitted on that course and on the site
                if ($suppress_autoreg == true || $this->course->check_autoreg() == false) {
                    if ($require) {
                        $this->response->quick_output(-321, 'USER_AUTH', 'User not registered, and auto-registration of users was not permitted', false);
                        exit();
                    }
                    return false;
                }
                
                // It is important that we also check auto-enrolment here.
                // If that is not enabled, but the call here requires it, then there is no point registering the user.
                if ($suppress_autoenrol == true || $this->course->check_autoenrol() == false) {
                    if ($require) {
                        $this->response->quick_output(-421, 'USER_ENROL', 'User not enrolled, and auto-enrolment of users was not permitted', false);
                        exit();
                    }
                    return false;
                }
            
                // Is there an avatar loaded?
                if (!$this->user->is_avatar_loaded()) {
                    // Add the avatar details, linked to imaginary user 0
                    if (!$this->user->add_linked_avatar(0, $uuid, $avname)) {
                        if ($require) {
                            $this->response->quick_output(-322, 'USER_AUTH', 'Failed to add new avatar', false);
                            exit();
                        }
                        return false;
                    }
                }
                
                // If we reached here then we definitely have an avatar
                // Create a matching Moodle user
                $password = $this->user->autoregister_avatar_user();
                if ($password === FALSE) {
                    if ($require) {
                        $this->response->quick_output(-322, 'USER_AUTH', 'Failed to register new user account', false);
                        exit();
                    }
                    return false;
                }
                
                // Add a side effect code to our response data
                $this->response->add_side_effect(322);
                // The user needs to be notified of their new username/password
                if (isset($_SERVER['HTTP_X_SECONDLIFE_OBJECT_KEY'])) {
                    sloodle_login_notification($_SERVER['HTTP_X_SECONDLIFE_OBJECT_KEY'], $uuid, $this->user->get_username(), $password);
                }
            }
            
        // ENROLMENT //
            
            // Is the user already enrolled on the course?
            if (!$this->user->is_enrolled($this->course->get_course_id())) {
                // Ensure auto-enrolment is not suppressed, and that it is permitted on that course and on the site
                if ($suppress_autoenrol == true || $this->course->check_autoenrol() == false) {
                    if ($require) {
                        $this->response->quick_output(-421, 'USER_ENROL', 'Auto-enrolment of users was not permitted', false);
                        exit();
                    }
                    return false;
                }
                
                // Attempt to enrol the user
                if (!$this->user->enrol()) {
                    if ($require) {
                        $this->response->quick_output(-422, 'USER_ENROL', 'Auto-enrolment failed', false);
                        exit();
                    }
                    return false;
                }
                
                // Add a side effect code to our response data
                $this->response->add_side_effect(422);
            }
            
            // Make sure the user is logged-in
            return ($this->user->login());
        }
        
        /**
        * Validate the avatar specified in the request, to ensure it is registered to a Moodle account.
        * (Also ensures that avatar details were in fact provided in the request).
        * This is effectively a less strict version of {@link validated_user()}, which also checks enrolment and such like.
        * This function will NOT perform auto-registration or auto-enrolment.
        * @param bool $require If true, the script will be terminated with an error message if validation fails
        * @return bool Returns true if validation was successful. Returns false on failure (unless $require was true).
        * @see SloodleSession::validate_user()
        */
        function validate_avatar( $require = true )
        {
            // Attempt to fetch avatar details
            $sloodleuuid = $this->request->get_avatar_uuid(false);
            $sloodleavname = $this->request->get_avatar_name(false);
            // We need at least one of the values
            if (empty($sloodleuuid) && empty($sloodleavname)) {
                if ($require) {
                    $this->response->quick_output(-311, 'USER_AUTH', 'Require avatar UUID and/or name.', false);
                    exit();
                }
                return false;
            }
            
            // Attempt to find an avatar matching the given details
            $rec = false;
            if (!empty($sloodleuuid)) $rec = get_record('sloodle_users', 'uuid', $sloodleuuid);
            if (!$rec) $rec = get_record('sloodle_users', 'avname', $sloodleavname);
            // Did we find a matching entry?
            if (!$rec) {
                // No - avatar is not validated
                if ($require) {
                    $this->response->quick_output(-321, 'USER_AUTH', 'Require avatar UUID and/or name.', false);
                    exit();
                }
                return false;
            }
            
            return true;
        }
        
        
        
        //... Add functions for verifying user access to resources?
    }
    

?>
