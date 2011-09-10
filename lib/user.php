<?php    
    /**
    * Sloodle user library.
    *
    * Provides functionality for reading, managing and editing user data.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    * @since Sloodle 0.2
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // This library expects that the Sloodle config file has already been included
    //  (along with the Moodle libraries)
    
    /** Include the Sloodle IO library. */
    require_once(SLOODLE_DIRROOT.'/lib/io.php');
    /** Include the general Sloodle functionality. */
    require_once(SLOODLE_DIRROOT.'/lib/general.php');
    /** Include the Sloodle course data structure. */
    require_once(SLOODLE_DIRROOT.'/lib/course.php');
    /** Include the user object data structure */
    require_once(SLOODLE_DIRROOT.'/lib/user_object.php');
    
    
    /**
    * A class to represent a single user, including Moodle and Sloodle data.
    * @package sloodle
    */
    class SloodleUser
    {
    // DATA //
    
        /**
        * Internal only - reference to the containing {@link SloodleSession} object.
        * Note: always check that it is not null before use!
        * @var object
        * @access protected
        */
        var $_session = null;
    
        /**
        * Internal only - avatar data.
        * In Moodle, corresponds to a record from the 'sloodle_users' table.
        * @var object
        * @access private
        */
        var $avatar_data = null;
        
        /**
        * Internal only - user data. (i.e. VLE user)
        * In Moodle, corresponds to a record from the 'user' table.
        * @var obejct
        * @access private
        */
        var $user_data = null;
        
        
    // CONSTRUCTOR //
    
        /**
        * Class constructor.
        * @param object &$_session Reference to the containing {@link SloodleSession} object, if available.
        * @access public
        */
        function SloodleUser(&$_session = null)
        {
            if (!is_null($_session)) $this->_session = &$_session;
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the unique ID of the avatar.
        * @return mixed Type depends on VLE. (Integer on Moodle). Returns null if there is no avatar.
        * @access public
        */
        function get_avatar_id()
        {
            if (!isset($this->avatar_data->id)) return null;
            return $this->avatar_data->id;
        }
        
        /**
        * Gets the unique ID of the VLE user.
        * @return mixed Type depends on VLE. (Integer on Moodle). Returns null if there is no user
        * @access public
        */
        function get_user_id()
        {
            if (!isset($this->user_data->id)) return null;
            return $this->user_data->id;
        }
        
        /**
        * Determines whether or not an avatar is loaded.
        * @return bool
        */
        function is_avatar_loaded()
        {
            return isset($this->avatar_data);
        }
        
        /**
        * Determines whether or not a VLE user is loaded.
        * @return bool
        */
        function is_user_loaded()
        {
            return isset($this->user_data);
        }
        
        
        /**
        * Gets the UUID of the avatar
        * @return string
        */
        function get_avatar_uuid()
        {
            return $this->avatar_data->uuid;
        }
        
        /**
        * Sets the UUID of the avatar
        * @param string $uuid The new UUID
        * @return void
        */
        function set_avatar_uuid($uuid)
        {
            $this->avatar_data->uuid = $uuid;
        }
        
        /**
        * Gets the name of the avatar
        * @return string
        */
        function get_avatar_name()
        {
            return $this->avatar_data->avname;
        }
        
        /**
        * Sets the name of the avatar
        * @param string $avname The new avatar name
        * @return void
        */
        function set_avatar_name($avname)
        {
            $this->avatar_data->avname = $avname;
        }
        
        /**
        * Gets the user's username
        * @return string
        */
        function get_username()
        {
            return $this->user_data->username;
        }
        
        /**
        * Gets the first name of the user
        * @return string
        */
        function get_user_firstname()
        {
            return $this->user_data->firstname;
        }
        
        /**
        * Gets the last name of the user
        * @return string
        */
        function get_user_lastname()
        {
            return $this->user_data->lastname;
        }
        
        /**
        * Gets the timestamp of whenever the avatar was last active
        * @return int
        */
        function get_avatar_last_active()
        {
            return (int)$this->avatar_data->lastactive;
        }
        
        /**
        * Sets the timestamp of when the user was last active
        * @param int $timestamp A UNIX timestamp, or null to use the current time
        * @return void
        */
        function set_avatar_last_active($timestamp = null)
        {
            if ($timestamp == null) $timestamp = time();
            $this->avatar_data->lastactive = $timestamp;
        }
        
        /**
        * Gets the user's email address.
        * @return string|null The user's email address, or null if none is specified of if email is disabled.
        */
        function get_user_email()
        {
            if (isset($this->user_data->email) && !empty($this->user_data->emailstop))
                return $this->user_data->email;
            return null;
        }
        
        
    // USER LINK FUNCTIONS //
        
        /**
        * Determines whether or not the current user and avatar are linked.
        * @return bool True if they are linked, or false if not.
        */
        function is_avatar_linked()
        {
            // Make sure there is data in both caches
            if (empty($this->avatar_data) || empty($this->user_data)) return false;
            // Check for the link (ignore the number 0, as that is not a valid ID)
            if ($this->avatar_data->userid != 0 && $this->avatar_data->userid == $this->user_data->id) return true;
            return false;
        }
    
   
        /**
        * Links the current avatar to the current user.
        * <b>NOTE:</b> does not remove any other avatar links to the VLE user.
        * @return bool True if successful or false otherwise.
        * @access public
        */
        function link_avatar()
        {
            // Make sure there is data in both caches
            if (empty($this->avatar_data) || empty($this->user_data)) return false;
            
            // Set the linked user ID and update the database record
            $olduserid = $this->avatar_data->userid;
            $this->avatar_data->userid = $this->user_data->id;
            if (sloodle_update_record('sloodle_users', $this->avatar_data)) return true;
            // The operation failed, so change the user ID back
            $this->avatar_data->userid = $olduserid;
            return false;
        }
        
        
    // DATABASE FUNCTIONS //
    
        /**
        * Deletes the current avatar from the database.
        * @return bool True if successful, or false on failure
        * @access public
        */
        function delete_avatar()
        {
            // Make sure we have avatar data
            if (empty($this->avatar_data)) return false;
            
            // Attempt to delete the record from the database
            return sloodle_delete_records('sloodle_users', 'id', $this->avatar_data->id);
        }
        
        /**
        * Loads the specified avatar from the database.
        * @param mixed $id The ID of the avatar (type depends on VLE; integer for Moodle)
        * @return bool True if successful, or false otherwise.
        * @access public
        */
        function load_avatar_by_id($id)
        {
            // Make sure the ID is valid
            if (!is_int($id) || $id <= 0) return false;
            // Fetch the avatar data
            $this->avatar_data = sloodle_get_record('sloodle_users', 'id', $id);
            if (!$this->avatar_data) {
                $this->avatar_data = null;
                return false;
            }
            return true;
        }
        
        /**
        * Finds an avatar with the given UUID and/or name, and loads its data.
        * The UUID is searched for first. If that is not found, then the name is used.
        * @param string $uuid The UUID of the avatar, or blank to search only by name.
        * @param string $avname The name of the avatar, or blank to search only by UUID.
        * @return bool True if successful, or false otherwise
        * @access public
        */
        function load_avatar($uuid, $avname)
        {
            // Both parameters can't be empty
            if (empty($uuid) && empty($avname)) return false;
            
            // Attempt to search by UUID first
            if (!empty($uuid)) {
                $this->avatar_data = sloodle_get_record('sloodle_users', 'uuid', $uuid);
                if ($this->avatar_data) return true;
            }
            
            // Attempt to search by name
            if (!empty($avname)) {
                $this->avatar_data = sloodle_get_record('sloodle_users', 'avname', $avname);
                if ($this->avatar_data) return true;
            }
            
            // The search failed
            $this->avatar_data = null;
            return false;
        }
        
        /**
        * Load the specified user from the database
        * @param mixed $id The unique identifier for the VLE user. (Type depends on VLE; integer for Moodle)
        * @return bool True if successful, or false on failure
        * @access public
        */
        function load_user($id)
        {
            // Make sure the ID is valid
            $id = (int)$id;
            if ($id <= 0) return false;
            
            // Attempt to load the data
            $this->user_data = get_complete_user_data('id', $id);
            if (!$this->user_data) {
                $this->user_data = null;
                return false;
            }

            
            return true;
        }
        
        /**
        * Uses the current avatar data to update the database.
        * @return bool True if successful, or false if the update fails
        * @access public
        */
        function write_avatar()
        {
            // Make sure we have avatar data
            if (empty($this->avatar_data) || $this->avatar_data->id <= 0) return false;
            // Make the update
            return sloodle_update_record('sloodle_users', $this->avatar_data);
        }
        
        /**
        * Adds a new avatar to the database, and link it to the specified user.
        * If successful, it deletes any matching avatar details from pending users list.
        * @param mixed $userid Site-wide unique ID of a user (type depends on VLE; integer for Moodle)
        * @param string $uuid UUID of the avatar
        * @param string $avname Name of the avatar
        * @return bool True if successful, or false if not.
        * @access public
        */
        function add_linked_avatar($userid, $uuid, $avname)
        {
            // Setup our object
            $this->avatar_data = new stdClass();
            $this->avatar_data->id = 0;
            $this->avatar_data->userid = $userid;
            $this->avatar_data->uuid = $uuid;
            $this->avatar_data->avname = $avname;
            
            // Add the data to the database
            $this->avatar_data->id = sloodle_insert_record('sloodle_users', $this->avatar_data);
            if (!$this->avatar_data->id) {
                $this->avatar_data = null;
                return false;
            }
            
            // Delete any pending avatars with the same details
            sloodle_delete_records('sloodle_pending_avatars', 'uuid', $uuid, 'avname', $avname);
            
            return true;
        }
        
        /**
        * Adds a new unlinked avatar to the database (the entry is pending linking)
        * @param string $uuid UUID of the avatar
        * @param string $avname Name of the avatar
        * @param int $timestamp The timestamp at which to mark the update (or null to use the current timestamp). Entries expire after a certain period.
        * @return object|bool Returns the database object if successul, or false if not.
        * @access public
        */
        function add_pending_avatar($uuid, $avname, $timestamp = null)
        {
            // Setup the timestamp
            if ($timestamp == null) $timestamp = time();
            
            // Setup our object
            $pending_avatar = new stdClass();
            $pending_avatar->id = 0;
            $pending_avatar->uuid = $uuid;
            $pending_avatar->avname = $avname;
            $pending_avatar->lst = sloodle_random_security_token();
            $pending_avatar->timeupdated = $timestamp;
            
            // Add the data to the database
            $pending_avatar->id = sloodle_insert_record('sloodle_pending_avatars', $pending_avatar);
            if (!$pending_avatar->id) {
                return false;
            }
            
            return $pending_avatar;
        }
        
        
        /**
        * Auto-register a new user account for the current avatar.
        * NOTE: this does NOT respect ANYTHING but the most basic Moodle accounts.
        * Use at your own risk!
        * @return string|bool The new password (plaintext) if successful, or false if not
        * @access public
        */
        function autoregister_avatar_user()
        {
            global $CFG;
        
            // Make sure we have avatar data, and reset the user data
            if (empty($this->avatar_data)) return false;
            $this->user_data = null;
            
            // Construct a basic username
            $nameparts = explode(' ', $this->avatar_data->avname);
            $baseusername = strip_tags(stripslashes(implode('', $nameparts)));
            $username = $baseusername;
            $conflict_moodle = sloodle_record_exists('user', 'username', $username);
            
            // If that didn't work, then try a few random variants (just a number added to the end of the name)
            $MAX_RANDOM_TRIES = 3;
            $rnd_try = 0;
            while ($rnd_try < $MAX_RANDOM_TRIES && $conflict_moodle) {
                // Pick a random 3 digit number
                $rnd_num = mt_rand(100, 998);
                if ($rnd_num >= 666) $rnd_num++; // Some users may object to this number
                
                // Construct a new username to try
                $username = $baseusername . (string)$rnd_num;
                // Check for conflicts
                $conflict_moodle = sloodle_record_exists('user', 'username', $username);
                
                // Next attempt
                $rnd_try++;
            }
            
            // Stop if we haven't found a unique name
            if ($conflict_moodle) return false;
            
            // Looks like we got an OK username
            // Generate a random password
            $plain_password = sloodle_random_web_password();
            
            // Create the new user
            $this->user_data = create_user_record($username, $plain_password);
            if (!$this->user_data) {
                $this->user_data = null;
                return false;
            }
            
            // Get the complete user data again, so that we have the password this time
            $this->user_data = get_complete_user_data('id', $this->user_data->id);
            
            // Attempt to use the first and last names of the avatar
            $this->user_data->firstname = $nameparts[0];
            if (isset($nameparts[1])) $this->user_data->lastname = $nameparts[1];
            else $this->user_data->lastname = $nameparts[0];
            // Prevent emails from being sent to this user
            $this->user_data->emailstop = 1;
            
            // Attempt to update the database (we don't really care if this fails, since everything else will have worked)
            sloodle_update_record('user', $this->user_data);
            
            // Now link the avatar to this account
            $this->avatar_data->userid = $this->user_data->id;
            sloodle_update_record('sloodle_users', $this->avatar_data);
            
            return $plain_password;
        }
       
        /**
        * Load the avatar linked to the current user.
        * @return bool,string True if a link was loaded, false if there was no link, or string 'multi' if multiple avatars are linked
        * @access public
        */
        function load_linked_avatar()
        {
            // Make sure we have some user data
            if (empty($this->user_data)) return false;
            $this->avatar_data = null;
            
            // Fetch all avatar records which are linked to the user
            $recs = sloodle_get_records('sloodle_users', 'userid', $this->user_data->id);
            if (!is_array($recs)) return false;
            if (count($recs) > 1) return 'multi';
            
            // Store the avatar data
            reset($recs);
            $this->avatar_data = current($recs);
            return true;
        }

        /**
        * Find the VLE user linked to the current avatar.
        * @return bool True if successful, or false if no link was found
        * @access public
        */
        function load_linked_user()
        {
            // Make sure we have some avatar data
            if (empty($this->avatar_data)) return false;
            
            // Fetch the user data
            $this->user_data = get_complete_user_data('id', $this->avatar_data->userid);
            if ($this->user_data) return true;
            return false;
        }
        
        
    ///// LOGIN FUNCTIONS /////
    
        /**
        * Internally 'log-in' the current user.
        * In Moodle, this just stores all the user data in the global $USER variable.
        * This function will not perform automatic registration.
        * @return bool True if successful, or false otherwise.
        * @access public
        */
        function login()
        {
            global $USER;
            // Make sure we have some user data
            if (empty($this->user_data)) return false;
            $USER = get_complete_user_data('id', $this->user_data->id);
            return true;
        }
        
        
    ///// COURSE FUNCTIONS /////
    
        /**
        * Gets a numeric array of {@link SloodleCourse} objects for courses the user is enrolled in.
        * WARNING: this function is not very efficient, and will likely be very slow on large sites.
        * @param mixed $category Unique identifier of a category to limit the query to. Ignored if null. (Type depends on VLE; integer for Moodle)
        * @return array A numeric array of {@link SloodleCourse} objects
        * @access public
        */
        function get_enrolled_courses($category = null)
        {
            // Make sure we have user data
            if (empty($this->user_data)) return array();
            // If it is the guess user, then they are not enrolled at all
            if (isguestuser($this->user_data->id)) return array();            
            
            // Convert the category ID as appropriate
            if ($category == null || $category < 0 || !is_int($category)) $category = 0;
            
            // Modified from "get_user_capability_course()" in Moodle's "lib/accesslib.php"
            
            // Get a list of all courses on the system
            $usercourses = array();
            $courses = get_courses($category);
            // Go through each course
            foreach ($courses as $course) {
                // Check if the user can view this course and is not a guest in it.
                // (Note: the site course is always available to all users.)
                $course_context = get_context_instance(CONTEXT_COURSE, $course->id);
                if ($course->id == SITEID || (has_capability('mod/sloodle:courseparticipate', $course_context, $this->user_data->id) )) {
                    $sc = new SloodleCourse();
                    $sc->load($course);
                    $usercourses[] = $sc;
                }
            }
            return $usercourses;
        }
        
        /**
        * Gets a numeric array of {@link SloodleCourse} objects for courses the user is Sloodle staff.
        * This relates to the "mod/sloodle:staff" capability.
        * WARNING: this function is not very efficient, and will likely be very slow on large sites.
        * @param mixed $category Unique identifier of a category to limit the query to. Ignored if null. (Type depends on VLE; integer for Moodle)
        * @return array A numeric array of {@link SloodleCourse} objects
        * @access public
        */
        function get_staff_courses($category = null)
        {
            // Make sure we have user data
            if (empty($this->user_data)) return array();
            
            // Convert the category ID as appropriate
            if ($category == null || $category < 0 || !is_int($category)) $category = 0;
            
            // Modified from "get_user_capability_course()" in Moodle's "lib/accesslib.php"
            
            // Get a list of all courses on the system
            $usercourses = array();
            $courses = get_courses($category);
            // Go through each course
            foreach ($courses as $course) {
                // Check if the user can teach using Sloodle on this course
                if (has_capability('mod/sloodle:staff', get_context_instance(CONTEXT_COURSE, $course->id), $this->user_data->id)) {
                    $sc = new SloodleCourse();
                    $sc->load($course);
                    $usercourses[] = $sc;
                }
            }
            return $usercourses;
        }
           
            /**
             * is_really_enrolled checks if the current user is enrolled in the course.  The other is_enrolled function
             * evaluates to true for administrators even if they are not enrolled in the course. This function will
             * evaluate to false for administrators
             * @param $courseid [integer] the id of the course
             */
            function is_really_enrolled($courseid)
            {
         
                global $USER;
                global $CFG;
                $sql = "SELECT u.id, u.username FROM ".$CFG->prefix."user u, ".$CFG->prefix."role_assignments r";
                 $sql .= " WHERE u.id = r.userid";
                 $sql .= " AND r.contextid = ? AND u.id=?";
                return sloodle_get_records_sql_params($sql, array($courseid, $USER->id));
        }
        /**
        * Is the current user enrolled in the specified course?
        * NOTE: a side effect of this is that it logs-in the user
        * @param mixed $course Unique identifier of the course -- type depends on VLE (integer for Moodle)
        * @param bool True if the user is enrolled, or false if not.
        * @access public
        * @todo Update to match parameter format and handling of {@link enrol()} function.
        */
        function is_enrolled($courseid)
        {
            
            global $USER;
            // Attempt to log-in the user
            if (!$this->login()) return false;
            
            // NOTE: this stuff was lifted from the Moodle 1.8 "course/enrol.php" script
            
            // Create a context for this course
            if (!$context = get_context_instance(CONTEXT_COURSE, $courseid)) return false;
            // Ensure we have up-to-date capabilities for the current user
            load_all_capabilities();
            
            // Check if the user can view the course, and does not simply have guest access to it
            // Allow the site course
            return ($courseid == SITEID || (has_capability('mod/sloodle:courseparticipate', $context) ));
        }
             
        
        /**
        * Is the current user Sloodle staff in the specified course?
        * NOTE: a side effect of this is that it logs-in the user
        * @param mixed $course Unique identifier of the course -- type depends on VLE (integer for Moodle)
        * @param bool True if the user is staff, or false if not.
        * @access public
        * @todo Update to match parameter format and handling of {@link enrol()} function.
        */
        function is_staff($courseid)
        {
            global $USER;
            // Attempt to log-in the user
            if (!$this->login()) return false;
            
            // NOTE: this stuff was lifted from the Moodle 1.8 "course/enrol.php" script
            
            // Create a context for this course
            if (!$context = get_context_instance(CONTEXT_COURSE, $courseid)) return false;
            // Ensure we have up-to-date capabilities for the current user
            load_all_capabilities();
            
            // Check if the user can view the course, does not simply have guest access to it, *and* is staff
            return (has_capability('mod/sloodle:courseparticipate', $context) && has_capability('mod/sloodle:staff', $context));
        }
        
        /**
        * Enrols the current user in the specified course
        * NOTE: a side effect of this is that it logs-in the user
        * @param object $sloodle_course A {@link SloodleCourse} object setup for the necessary course. If null, then the {@link $_session} member is queried instead.
        * @param bool True if successful (or the user was already enrolled), or false otherwise
        * @access public
        */
        function enrol($sloodle_course = null)
        {
            global $USER, $CFG;
            // Attempt to log-in the user
            if (!$this->login()) return false;
            
            // Was course data provided?
            if (empty($sloodle_course)) {
                // No - attempt to get some from the Sloodle session
                if (empty($this->_session)) return false;
                if (empty($this->_session->course)) return false;
                $sloodle_course = $this->_session->course;
            }
            
            // NOTE: much of this stuff was lifted from the Moodle 1.8 "course/enrol.php" script
            
            // Fetch the Moodle course data, and a course context
            $course = $sloodle_course->get_course_object();
            if (!$context = get_context_instance(CONTEXT_COURSE, $course->id)) return false;
            
            // Ensure we have up-to-date capabilities for the current user
            load_all_capabilities();
            
            // Check if the user can view the course, and does not simply have guest access to it
            // (No point trying to enrol somebody if they are already enrolled!)
            if (has_capability('mod/sloodle:courseparticipate', $context) ) return true;
            
            // Make sure auto-registration is enabled for this site/course, and that the controller (if applicable) is enabled
            if (!$sloodle_course->check_autoreg()) return false;            
            
            // Can't enrol users on meta courses or the site course
            if ($course->metacourse || $course->id == SITEID) return false;
            
            // Is there an enrolment period in effect?
            if ($course->enrolperiod) {
                if ($roles = get_user_roles($context, $USER->id)) {
                    foreach ($roles as $role) {
                        if ($role->timestart && ($role->timestart >= time())) {
                            return false;
                        }
                    }
                }
            }
            // Make sure the course is enrollable
            if (!$course->enrollable ||
                    ($course->enrollable == 2 && $course->enrolstartdate > 0 && $course->enrolstartdate > time()) ||
                    ($course->enrollable == 2 && $course->enrolenddate > 0 && $course->enrolenddate <= time())
            ) {
                return false;
            }
            
            // Finally, after all that, enrol the user
            if (!enrol_into_course($course, $USER, 'manual')) return false;
        
            // Everything seems fine
            // Log the auto-enrolment
            add_to_log($course->id, 'sloodle', 'update', '', 'auto-enrolment');
            return true;
        }
    
    
    ///// PASSWORD /////
    
        /**
        * Resets the user's password
        * @param bool $require If true, then the script will be terminated if the operation fails
        * @return string|bool The new password if successful, or false otherwise (if $require was false).
        */
        function reset_password($require = true)
        {
            // Check that the user is loaded
            if (empty($this->user_data)) {
                if ($require) {
                    $this->_session->response->quick_output(-301, 'USER_AUTH', 'User data not loaded', false);
                    exit();
                }
                return false;
            }
            // If the user has an email address on file, then we can't reset the password
            if (!empty($this->user_data->email)) {
                if ($require) {
                    $this->_session->response->quick_output(-341, 'USER_AUTH', 'User has email address in database. Cannot use Sloodle password reset.', false);
                    exit();
                }
                return false;
            }
            
            // Generate a new random password
            $password = sloodle_random_web_password();
            // Update the user's password data
            if (!update_internal_user_password($this->user_data, $password)) {
                if ($require) {
                    $this->_session->response->quick_output(-103, 'SYSTEM', 'Failed to update user password', false);
                    exit();
                }
                return false;
            }
            
            return $password;
        }
        
        /**
        * If the system is waiting to send a password notification to this user, then remove it
        * @return void
        */
        function purge_password_notifications()
        {
            // Check that the user is loaded
            if (empty($this->user_data)) return;
            // Delete the database entries
            sloodle_delete_records('sloodle_login_notifications', 'username', $this->user_data->username);
        }
        
        
    ///// USER-CENTRIC OBJECTS /////
    
        /**
        * Authorises the given object for the current avatar.
        * Note: the object must already exist in the database.
        * @param int $authid The ID of the authorisation entry
        * @return bool True if successful, or false otherwise
        */
        function authorise_user_object($authid)
        {
            // Make sure an avatar is loaded
            if (!$this->is_avatar_loaded()) return false;
            
            // Does the object already exist in the database?
            $auth = sloodle_get_record('sloodle_user_object', 'id', $authid, 'avuuid', $this->get_avatar_uuid());
            if (!$auth) return false;
            // Update the existing record
            $auth->authorised = 1;
            $auth->timeupdated = time();
            
            return sloodle_update_record('sloodle_user_object', $auth);
        }
        
        
        /**
        * Adds or udpates the given user object as unauthorised.
        * (This function can be called statically).
        * @param string $avuuid UUID of the avatar the object will be authorised for
        * @param string $objuuid UUID of the object
        * @param string $objname Name of the object
        * @param string $password Password to store for the object
        * @return int|bool Integer ID of the authorisation entry, or false otherwise
        */
        function add_user_object($avuuid, $objuuid, $objname, $password)
        {
            // Make sure our other parameters are valid
            if (empty($objuuid) || empty($password)) return false;
            
            // Does the object already exist in the database?
            $auth = sloodle_get_record('sloodle_user_object', 'objuuid', $objuuid);
            $success = false;
            if (!$auth) {
                // No - insert a new record
                $auth = new stdClass();
                $auth->avuuid = $avuuid;
                $auth->objuuid = $objuuid;
                $auth->objname = $objname;
                $auth->password = $password;
                $auth->authorised = 0;
                $auth->timeupdated = time();
                $success = sloodle_insert_record('sloodle_user_object', $auth);
                
            } else {
                // Yes - update the existing record
                $auth->avuuid = $avuuid;
                $auth->objuuid = $objuuid;
                $auth->objname = $objname;
                $auth->password = $password;
                $auth->authorised = 0;
                $auth->timeupdated = time();
                
                if (sloodle_update_record('sloodle_user_object', $auth)) $success = $auth->id;
            }
            
            return $success;
        }
        
        
        /**
        * Gets a list of all user-centric objects authorised for the current avatar.
        * @return array A numeric array of {@link SloodleUserObject} objects
        */
        function get_user_objects()
        {
            // Make sure an avatar is loaded
            if (!$this->is_avatar_loaded()) return array();
            // Get all objects authorised for this avatar's UUID
            $recs = sloodle_get_records('sloodle_user_object', 'avuuid', $this->get_avatar_uuid());
            if (!$recs) return array();
            // Construct an array of SloodleUserObject's
            $output = array();
            foreach ($recs as $r) {
                $obj = new SloodleUserObject();
                $obj->id = $r->id;
                $obj->avuuid = $r->avuuid;
                $obj->objuuid = $r->objuuid;
                $obj->objname = $r->objname;
                $obj->password = $r->password;
                $obj->authorized = (bool)$r->authorised; // Note different spelling... oops! -PB
                $obj->timeupdated = $r->timeupdated;
                
                $output[] = $obj;
            }
            
            return $output;
        }
        
        
        /**
        * Deletes a user-centric object by UUID.
        * Note: the object must have been authorised for the current avatar.
        * @param string $uuid The UUID of the object to delete
        * @return void
        */
        function delete_user_object($uuid)
        {
            if (!$this->is_avatar_loaded()) return;
            sloodle_delete_records('sloodle_user_object', 'avuuid', $this->get_avatar_uuid(), 'objuuid', $uuid);
        }
        
    }
    

?>
