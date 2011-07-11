<?php
    // This file is part of the Sloodle project (www.sloodle.org)
   
    /**
    * This file defines a structure for Sloodle data about a particular Moodle course.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
   
    /** Include the general Sloodle library. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Include the Sloodle controller structure. */
    require_once(SLOODLE_LIBROOT.'/controller.php');
    /** Include the layout profile management stuff. */
    require_once(SLOODLE_LIBROOT.'/layout_profile.php');
   
    /**
    * The Sloodle course data class
    * @package sloodle
    */
    class SloodleCourse
    {
    // DATA //
   
        /**
        * The database object of the course to which this object relates.
        * Corresponds to the "course" table in Moodle.
        * Is null if not yet set
        * @var object
        * @access private
        */
        var $course_object = null;
   
        /**
        * The Sloodle course data object, if it exists.
        * Is null if not yet set.
        * @var object
        * @var private
        */
        var $sloodle_course_data = null;
       
        /**
        * The {@link SloodleController} object being used to access this course, if available.
        * @var SloodleController
        * @var public
        */
        var $controller = null;
       
       
    // FUNCTIONS //
   
        /**
        * Constructor
        */
        function SloodleCourse()
        {
            $this->controller = new SloodleController();
        }
       
        /**
        * Determines whether or not course data has been loaded.
        * @return bool
        */
        function is_loaded()
        {
            if (empty($this->course_object) || empty($this->sloodle_course_data)) return false;
            return true;
        }
       
        /**
        * Gets the identifier of the course in the VLE.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->course_object->id;
        }
       
        /**
        * Gets the VLE course object.
        * WARNING: this should only be used when ABSOLUTELY necessary.
        * The contents are specific to the VLE.
        * @return mixed Type and content depends upon VLE. In Moodle, it is an object representing a record from the 'course' table.
        */
        function get_course_object()
        {
            return $this->course_object;
        }
       
       
        /**
        * Gets the short name of this course in the VLE.
        * @return string Shortname of this course.
        */
        function get_short_name()
        {
            return $this->course_object->shortname;
        }
       
        /**
        * Gets the full name of this course in the VLE.
        * @return string Fullname of this course.
        */
        function get_full_name()
        {
            return $this->course_object->fullname;
        }
       
        /**
        * Is auto registration permitted on this site AND course?
        * Takes into account the site-wide setting as well.
        * @return bool
        */
        function check_autoreg()
        {
            // Check the site *and* the course value
            return ((bool)sloodle_autoreg_enabled_site() && (bool)$this->get_autoreg());
        }
       
        /**
        * Gets the autoregistration value for this course only.
        * (Ignores the site setting).
        * @return bool
        */
        function get_autoreg()
        {
            return (!empty($this->sloodle_course_data->autoreg));
        }
       
        /**
        * Enables auto-registration for this course.
        * NOTE: it may still be disabled at site-level.
        * @return void
        */
        function enable_autoreg()
        {
            $this->sloodle_course_data->autoreg = 1;
        }
       
        /**
        * Disables auto-registration for this course.
        * NOTE: does not affect the site setting.
        * @return void
        */
        function disable_autoreg()
        {
            $this->sloodle_course_data->autoreg = 0;
        }
       
       
       
        /**
        * Is auto enrolment permitted on this site AND course?
        * Takes into account the site-wide setting as well.
        * @return bool
        */
        function check_autoenrol()
        {
            // Check the site *and* the course value
            return ((bool)sloodle_autoenrol_enabled_site() && $this->get_autoenrol());
        }
       
        /**
        * Gets the auto enrolment value for this course only.
        * (Ignores the site setting).
        * @return bool
        */
        function get_autoenrol()
        {
            return (!empty($this->sloodle_course_data->autoenrol));
        }
       
        /**
        * Enables auto-enrolment for this course.
        * NOTE: it may still be disabled at site-level.
        * @return void
        */
        function enable_autoenrol()
        {
            $this->sloodle_course_data->autoenrol = 1;
        }
       
        /**
        * Disables auto-enrolment for this course.
        * NOTE: does not affect the site setting.
        * @return void
        */
        function disable_autoenrol()
        {
            $this->sloodle_course_data->autoenrol = 0;
        }
       
       
       
        /**
        * Determines whether or not the course is available.
        * Checks that the course has not been disabled or hidden etc..
        * @return bool True if the course is available
        */
        function is_available()
        {
            // Check visbility
            if (empty($this->course_object->visible)) return false;
           
            return true;
        }
       
       
        /**
        * Gets the position of the loginzone as a string vector <x,y,z>
        * @return string
        */
        function get_loginzone_position()
        {
            if (isset($this->sloodle_course_data->loginzonepos)) return $this->sloodle_course_data->loginzonepos;
            return '';
        }
       
        /**
        * Sets the position of the loginzone as a string vector <x,y,z>
        * @param string $pos A string position vector <x,y,z>
        * @return void
        * @todo Update to handle arrays as well
        */
        function set_loginzone_position($pos)
        {
            $this->sloodle_course_data->loginzonepos = $pos;
        }
       
        /**
        * Sets the position of the loginzone as a set of components
        * @param float $x
        * @param float $y
        * @param float $z
        * @return void
        */
        function set_loginzone_position_xyz($x, $y, $z)
        {
            $this->sloodle_course_data->loginzonepos = "<$x,$y,$z>";
        }
       
       
        /**
        * Gets the size of the loginzone as a string vector <x,y,z>
        * @return string
        */
        function get_loginzone_size()
        {
            if (isset($this->sloodle_course_data->loginzonesize)) return $this->sloodle_course_data->loginzonesize;
            return '';
        }
       
        /**
        * Sets the size of the loginzone as a string vector <x,y,z>
        * @param string $size A string size vector <x,y,z>
        * @return void
        * @todo Update to handle arrays as well
        */
        function set_loginzone_size($size)
        {
            $this->sloodle_course_data->loginzonesize = $size;
        }
       
        /**
        * Sets the size of the loginzone as a set of components
        * @param float $x
        * @param float $y
        * @param float $z
        * @return void
        */
        function set_loginzone_size_xyz($x, $y, $z)
        {
            $this->sloodle_course_data->loginzonesize = "<$x,$y,$z>";
        }
       
       
        /**
        * Gets the region of the loginzone
        * @return string
        */
        function get_loginzone_region()
        {
            if (isset($this->sloodle_course_data->loginzoneregion)) return $this->sloodle_course_data->loginzoneregion;
            return '';
        }
       
        /**
        * Sets the region of the loginzone
        * @param string $region A string naming a region
        * @return void
        */
        function set_loginzone_region($region)
        {
            $this->sloodle_course_data->loginzoneregion = $region;
        }
       
       
        /**
        * Gets the timestamp of the last time the loginzone was updated
        * @return int
        */
        function get_loginzone_time_updated()
        {
            if (isset($this->sloodle_course_data->loginzoneupdated)) return $this->sloodle_course_data->loginzoneupdated;
            return 0;
        }
       
        /**
        * Sets the timestamp of the last time the loginzone was updated
        * @param int $timestamp A unix timestamp. If null, the current timestamp is used
        * @return void
        */
        function set_loginzone_time_updated($timestamp = null)
        {
            if ($timestamp == null) $timestamp = time();
            $this->sloodle_course_data->loginzoneupdated = $timestamp;
        }



        /**
        * Generates a new LoginZone allocation for the specified user.
        * @param SloodleUser $user The user for whom this allocation should be made
        * @return string|false A SLurl for the allocation, or false if it was unsuccessful
        */
        function generate_loginzone_allocation($user)
        {
            // Make sure the necessary data is available
            if (!(isset($this->sloodle_course_data->loginzonepos) && isset($this->sloodle_course_data->loginzonesize) && isset($this->sloodle_course_data->loginzoneregion))) return false;
            // Delete any existing LoginZone allocation for this user
            sloodle_delete_records('sloodle_loginzone_allocation', 'userid', $user->get_user_id());
           
            // We will try up to 10 times to find a new available position
            $loginzonesize = sloodle_vector_to_array($this->sloodle_course_data->loginzonesize);
            $maxtries = 10;
            $success = false;
            for ($i = 0; $i < $maxtries && $success == false; $i++) {
                // Generate a new random position
                $rndpos_arr = sloodle_random_position_in_zone($loginzonesize);
                // Make sure the Z parameter is even - round it if not
                if ($rndpos_arr['z'] % 2 != 0) $rndpos_arr['z'] += 1;

                $rndpos_str = sloodle_array_to_vector($rndpos_arr);
                // Is the position already taken?
                if (!sloodle_get_record('sloodle_loginzone_allocation', 'course', $this->get_course_id(), 'position', $rndpos_str)) {
                    // Nobody has the position
                    $success = true;
                }
            }
            // Did we succeed in generating it?
            if (!$success) return false;
           
            // Create a new one
            $alloc = new stdClass();
            $alloc->course = $this->get_course_id();
            $alloc->userid = $user->get_user_id();
            $alloc->position = $rndpos_str;
            $alloc->timecreated = time();
            // Attempt to insert it into the database
            if (!sloodle_insert_record('sloodle_loginzone_allocation', $alloc)) return false;
            return true;
        }
       
        /**
        * Gets the SLurl for the specified user's loginzone alloation
        * @param SloodleUser $user The user whose allocation is to be retrieved
        * @return string|bool The SLurl string if successful, or false if the user has no allocation or the loginzone does not exist
        */
        function get_loginzone_allocation($user)
        {
            // Make sure the necessary data is available
            if (!(isset($this->sloodle_course_data->loginzonepos) && isset($this->sloodle_course_data->loginzonesize) && isset($this->sloodle_course_data->loginzoneregion))) return false;
            // Attempt to fetch the data
            $alloc = sloodle_get_record('sloodle_loginzone_allocation', 'course', $this->get_course_id(), 'userid', $user->get_user_id());
            if (!$alloc) return false;
            $relpos = sloodle_vector_to_array($alloc->position);
            // Calculate the absolute position of the allocation
            $loginzonepos= sloodle_vector_to_array($this->sloodle_course_data->loginzonepos);
            $abspos = array('x'=>$loginzonepos['x'] + $relpos['x'], 'y'=>$loginzonepos['y'] + $relpos['y'], 'z'=>$loginzonepos['z'] + $relpos['z']);
           
            // Construct and return the SLurl
            return "secondlife://{$this->sloodle_course_data->loginzoneregion}/{$abspos['x']}/{$abspos['y']}/{$abspos['z']}";
        }
       
        /**
        * Finds the user identified by LoginZone allocation, and loads it into the given user object.
        * Note: does not delete the allocation.
        * @param string $pos Absolute position vector (relative to sim, not to LoginZone)
        * @param SloodleUser &$user The user object which will be manipulated (by reference)
        * @return bool True if successful, or false otherwise
        */
        function load_user_by_loginzone($pos, &$user)
        {
            // Calculate the relative position of the allocation
            $abspos = sloodle_vector_to_array($pos);
            $loginzonepos= sloodle_vector_to_array($this->sloodle_course_data->loginzonepos);
            $relpos = array('x'=>$abspos['x'] - $loginzonepos['x'], 'y'=>$abspos['y'] - $loginzonepos['y'], 'z'=>$abspos['z'] - $loginzonepos['z']);
            $relposstr = sloodle_array_to_vector($relpos);
            // Generate an alternate LoginZone position 1 unit downwards, in case the SL teleport glitch has happened.
            // (Note that LoginZone positions are generate on even Z units only, so an offset of 1 shouldn't cause a problem)
            $altrelpos = array('x'=>$relpos['x'], 'y'=>$relpos['y'], 'z'=>$relpos['z'] - 1);
            $altrelposstr = sloodle_array_to_vector($altrelpos);
       
            // Attempt to find a matching LoginZone position in the database
            $rec = sloodle_get_record('sloodle_loginzone_allocation', 'course', $this->get_course_id(), 'position', $relposstr);
            if (!$rec)
            {
                $rec = sloodle_get_record('sloodle_loginzone_allocation', 'course', $this->get_course_id(), 'position', $altrelposstr);
            }
            if (!$rec) return false;
            // Load the user
            return $user->load_user($rec->userid);
        }
       
        /**
        * Deletes any loginzone allocations for the given user
        * If there are multiple for the same user (which there should never be) it will delete them all.
        * @param SloodleUser $user The user whose allocation is to be deleted
        * @return void
        */
        function delete_loginzone_allocation($user)
        {
            sloodle_delete_records('sloodle_loginzone_allocation', 'userid', $user->get_user_id());
        }
       
        /**
        * Determines whether or not LoginZone data exists for this course.
        * @return bool True if there is complete data, or false otherwise
        */
        function has_loginzone_data()
        {
            return (!(empty($this->sloodle_course_data->loginzonepos) || empty($this->sloodle_course_data->loginzonesize) || empty($this->sloodle_course_data->loginzoneregion)));
        }
       
       
        /**
        * Reads fresh data into the structure from the database.
        * Fetches Moodle and Sloodle data about the course specified.
        * If necessary, it creates a new Sloodle entry with default settings.
        * Returns true if successful, or false on failure.
        * @param mixed $course Either a unique course ID, or a course data object. If the former, then VLE course data is read from the database. Otherwise, the data object is used as-is.
        * @return bool
        */
        function load($course)
        {
            // Reset everything
            $this->course_object = null;
            $this->sloodle_course_data = null;
       
            // Check what we are dealing with
            if (is_int($course)) {
                // It is a course ID - make sure it's valid
                if ($course <= 0) return false;
                // Load the course data
                $this->course_object = sloodle_get_record('course', 'id', $course);
                if (!$this->course_object) {
                    $this->course_object = null;
                    return false;
                }
            } else if (is_object($course)) {
                // It is an object - make sure it has an ID
                if (!isset($course->id)) return false;
                $this->course_object = $course;
            } else {
                // Don't know what it is - do nothing
                return false;
            }
           
            // Fetch the Sloodle course data
            $this->sloodle_course_data = sloodle_get_record('sloodle_course', 'course', $this->course_object->id);
            // Did it fail?
            if (!$this->sloodle_course_data) {
                // Create the new entry
                $this->sloodle_course_data = new stdClass();
                $this->sloodle_course_data->course = $this->course_object->id;
                $this->sloodle_course_data->autoreg = 0;
                $this->sloodle_course_data->loginzonepos = '';
                $this->sloodle_course_data->loginzonesize = '';
                $this->sloodle_course_data->loginzoneregion = '';
                $this->sloodle_course_data->id = sloodle_insert_record('sloodle_course', $this->sloodle_course_data);
                // Did something go wrong?
                if (!$this->sloodle_course_data->id) {
                    $this->course_object = null;
                    $this->sloodle_course_data = null;
                    return false;
                }
            }
           
            return true;
        }
       
        /**
        * Loads course and controller data by the unqiue site-wide identifier of a Sloodle controller.
        * @param mixed $controllerid The unique site-wide identifier for a Sloodle Controller. (For Moodle, an integer cmi)
        * @return bool True if successful, or false on failure.        
        */
        function load_by_controller($controllerid)
        {
            // Clear out all our data
            $this->course_object = null;
            $this->sloodle_course_data = null;
           
            // Construct a new controller object, and attempt to load its data
            $this->controller = new SloodleController();
            if (!$this->controller->load($controllerid)) {
                sloodle_debug("Failed to load controller.<br>");
                return false;
            }
           
            // Now attempt to load all the course data
            if (!$this->load($this->controller->get_course_id())) {
                sloodle_debug("Failed to load course data.<br>");
                return false;
            }
           
            return true;
        }
       
        /**
        * Writes current Sloodle course data back to the database.
        * Requires that a course structure has already been retrieved.
        * @return bool True if successful, or false on failure
        */
        function write()
        {
            // Make sure the course data is valid
            if (empty($this->course_object) || $this->course_object->id <= 0) return false;
            if (empty($this->sloodle_course_data) || $this->sloodle_course_data->id <= 0) return false;
            // Update the Sloodle data
            return sloodle_update_record('sloodle_course', $this->sloodle_course_data);
        }
       
        /**
        * Gets an array associating layout ID's to names
        * @return array
        */
        function get_layout_names()
        {
            // Fetch the layout records
            $layouts = sloodle_get_records('sloodle_layout', 'course', $this->course_object->id, 'name');
            if (!$layouts) return array();
            // Construct the array of names
            $layout_names = array();
            foreach ($layouts as $l) {
                $layout_names[$l->id] = $l->name;
            }
           
            return $layout_names;
        }


        /**
        * Gets all the entries in the named layout.
        * @param string $name The name of the layout to query
        * @return array|bool A numeric array of {@link SloodleLayoutEntry} objects if successful, or false if the layout does not exist
        */
        function get_layout_entries($name)
        {
            // Attempt to find the relevant layout
            $layout = sloodle_get_record('sloodle_layout', 'course', $this->course_object->id, 'name', $name);
            if (!$layout) return false;
           
            return $this->get_layout_entries_for_layout_id($layout->id);
        }

        /**
        * Gets all the entries in the named layout.
        * @param string $name The name of the layout to query
        * @return array|bool A numeric array of {@link SloodleLayoutEntry} objects if successful, or false if the layout does not exist
        */
        function get_layout_entries_for_layout_id($id)
        {
            // Fetch all entries
            $recs = sloodle_get_records('sloodle_layout_entry', 'layout', $id);
            if (!$recs) return array();
           
            // Construct the array of SloodleLayoutEntry objects
            $entries = array();
            foreach ($recs as $r) {
                $entry = new SloodleLayoutEntry($r);
                $entries[] = $entry;
            }
           
            return $entries;
        }

        /**
        * Gets SloodleLayout objects for all the layouts in the course.
        */
        function get_layouts() {
            // Fetch the layout records
            $layoutrecs = sloodle_get_records('sloodle_layout', 'course', $this->course_object->id, 'name');
            $layouts = array();

            if (!$layoutrecs) return array();

            foreach ($layoutrecs as $r) {
                $layouts[] = new SloodleLayout($r);
            }

            return $layouts;
        }
       
        /**
        * Deletes the named layout.
        * @param string $name The name of the layout to delete
        * @return void
        */
        function delete_layout($name)
        {
            // Attempt to find the relevant layout
            $layout = sloodle_get_record('sloodle_layout', 'course', $this->course_object->id, 'name', $name);
            if (!$layout) return;
           
            // Delete all related entries
            sloodle_delete_records('sloodle_layout_entry', 'layout', $layout->id);
            // Delete the layout itself
            sloodle_delete_records('sloodle_layout', 'course', $this->course_object->id, 'name', $name);
        }
       
        /**
        * Save the given entries in the named profile.
        * @param string $name The name of the layout to query
        * @param array $entries A numeric array of {@link SloodleLayoutEntry} objects to store
        * @param bool $add (Default: false) If true, then the entries will be added to the layout instead of replacing existing entries
        * @return bool True if successful, or false otherwise
        */
        function save_layout($name, $entries, $add = false)
        {
            // Attempt to find the relevant layout
            $layout = sloodle_get_record('sloodle_layout', 'course', $this->course_object->id, 'name', $name);
            $lid = 0;
            if ($layout) {
               $lid = $layout->id;
            }

            return $this->save_layout_by_id($lid, $name, $entries, $add);
        }
         
        /**
        * Save the given entries in the profile specified by id.
        * @param string $id The id of the layout to query. 0 to add a new layout.
        * @param string $name The new name of the layout.  
        * @param array $entries A numeric array of {@link SloodleLayoutEntry} objects to store
        * @param bool $add (Default: false) If true, then the entries will be added to the layout instead of replacing existing entries
        * @return bool True if successful, or false otherwise
        */
        function save_layout_by_id($id, $name, $entries, $add = false)
        {
            // Attempt to find the relevant layout
            if ($id > 0) {

/*
                // Delete all existing entries if necessary
                // This will happen when we save
                // TODO: make add-only functionality for backwards compatibility
                if (!$add) {
                        sloodle_delete_records('sloodle_layout_entry', 'layout', $layout->id);
                }
*/

                $layout = $this->get_layout($id);
                $layout->name = $name;
                $layout->timeupdated = time();
                $layout->entries = $entries;
                $layout->populate_entries_from_active_objects(); // where the records have objectuuids set, copy their settings
                if (!$layout->update()) {
                   return false;
                }
                $this->layout = $layout;
            } else {
                $layout = new SloodleLayout();
                $layout->name = $name;
                $layout->course = $this->course_object->id;
                $layout->timeupdated = time();
                $layout->entries = $entries;
                $layout->populate_entries_from_active_objects();
                $layout->id = $layout->insert();  #sloodle_insert_record('sloodle_layout', $layout);
                if (!$layout->id) return false;
                $this->layout = $layout;
            }
           
/*
            // This should have been done by the layout
            // Insert each new entry
            $success = true;
            foreach ($entries as $e) {
                $rec = new stdClass();
                $rec->layout = $layout->id;
                $rec->name = $e->name;
                $rec->position = $e->position;
                $rec->rotation = $e->rotation;

                // TODO EDE: If there's an objectuuid for the entry, copy the entries from the active object table to the layout config table
                if ($objectuuid != '') {
                   $rec->copy_active_object_with_uuid($e->objectuuid);
                }
               
                $entry_id = sloodle_insert_record('sloodle_layout_entry', $rec);
               
            }
*/
           
            return $layout->id;

        }
        function get_enrolled_users(){
            global $CFG;          
             $contextid = get_context_instance(CONTEXT_COURSE,$this->course_object->id);
             $cid=$contextid->id;
             $sql= "SELECT distinct sl.*,sl.uuid as avuuid,u.id, u.firstname, u.lastname FROM {$CFG->prefix}user u INNER JOIN {$CFG->prefix}sloodle_users sl ON sl.userid=u.id INNER JOIN {$CFG->prefix}role_assignments ra ON ra.userid=u.id AND ra.contextid={$cid}";
             
             $enrolledUsers = sloodle_get_records_sql($sql);
            //return $enrolledUsers
            return $enrolledUsers;
        }
            
        function get_layout($layoutid) {

            $rec = sloodle_get_record('sloodle_layout', 'course', $this->course_object->id, 'id', $layoutid);
            return new SloodleLayout($rec);

        }

        // Make sure the course has at least one layout, creating one if necessary using the prefix $nameprefix
        // Returns true on success, false on failure
	function ensure_at_least_one_layout($nameprefix) {

            if ( count($this->get_layouts()) > 0 ) {
                return true;
            }

            if (!$layoutname = SloodleLayout::UniqueName($nameprefix)) {
                return false;
            }

            $l = new SloodleLayout();
            $l->name = $layoutname;
            $l->course = $this->course_object->id;
            return $l->insert();


	}

        /**
        * Checks whether or not the CURRENTLY LOGGED-IN user can authorise objects on this course.
        * @return bool True if the user has object authorisation permission, or false otherwise.
        */
        function can_user_authorise_objects()
        {
            global $USER;
            // Make sure some user data
            if (empty($USER) || $USER->id == 0) return FALSE;
           
            // Check the capability
            return has_capability('mod/sloodle:objectauth', get_context_instance(CONTEXT_COURSE, $this->get_course_id()));
        }
   
    }
?>
