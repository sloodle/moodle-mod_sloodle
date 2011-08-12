<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines the Sloodle Controller module sub-type.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 - 2011 various contributors
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    */
    
    
    /** General Sloodle functionality. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** The active object structure. */
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    
    /**
    * The data structure of a controller is as follows:
    *
    * coursemodule
    *  id 
    *  instance - refers to the ID in the sloodle table 
    *  
    * sloodle
    *  id
    *
    * sloodle_controller
    *  id - ID of this record, redundant as it's already uniquely identified by sloodleid?
    *  sloodleid - refers to the ID in the sloodle table  
    *
    */
    
    /**
    * Represents a Sloodle Controller, including data such as prim password.
    * @package sloodle
    */
    class SloodleController
    {
    // DATA //
    
        /**
        * Internal for Moodle only - course module instance.
        * Corresponds to one record from the Moodle 'course_modules' table.
        * @var object
        * @access private
        */
        var $cm = null;
    
        /**
        * Internal only - Sloodle module instance database object.
        * Corresponds to one record from the Moodle 'sloodle' table.
        * @var object
        * @access private
        */
        var $sloodle_module_instance = null;
        
        /**
        * Internal only - Sloodle Controller instance database object.
        * Corresponds to one record from the Moodle 'sloodle_controller' table.
        * @var object
        * @access private
        */
        var $sloodle_controller_instance = null;
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleController()
        {
        }
        
        /**
        * DEPRECATED in an attempt to make the use of various IDs around the controller less baffling. Use load_by_course_module_id instead.
        * Loads data from the database based on the course module id.
        * Note: even if the function fails, it may still have overwritten some or all existing data in the object.
        * @param mixed $id The site-wide unique identifier for all modules. Course module identifier ('id' field of 'course_modules' table)
        * @return bool True if successful, or false otherwise
        */
        function load($id)
        {
            return $this->load_by_course_module_id($id);
        }
        
 
        /**
        * Loads data from the database.
        * Note: even if the function fails, it may still have overwritten some or all existing data in the object.
        * @param mixed $id The site-wide unique identifier for all modules. Course module identifier ('id' field of 'course_modules' table)
        * @return bool True if successful, or false otherwise
        */
	function load_by_course_module_id($cmid) {

            // Make sure the ID is valid
            $cmid = (int)$cmid;
            if ($cmid <= 0) return false;
            
            // Fetch the course module data
            if (!($this->cm = get_coursemodule_from_id('sloodle', $cmid))) {
                sloodle_debug("Failed to load controler course module.<br>");
                return false;
            }
            
            // Load from the primary table: Sloodle instance
            if (!($this->sloodle_module_instance = sloodle_get_record('sloodle', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load controller Sloodle module instance.<br>");
                return false;
            }
            // Check that it is the correct type
            if ($this->sloodle_module_instance->type != SLOODLE_TYPE_CTRL) {
                sloodle_debug("Loaded Sloodle module instance is not a controller.<br>");
                return false;
            }
            
            // Load from the secondary table: Controller instance
            if (!($this->sloodle_controller_instance = sloodle_get_record('sloodle_controller', 'sloodleid', $this->cm->instance))) {
                sloodle_debug("Failed to load controller secondary data table.<br>");
                return false;
            }
            
            return true;

	}

        /**
        * Updates the currently loaded entry in the database.
        * Note: the data *must* have been previously loaded using {@link load_from_db()}.
        * This function cannot be used to create new entries.
        * @return bool True if successful, or false otherwise
        */
        function write()
        {
            // Make sure we have all the necessary data
            if (empty($this->sloodle_module_instance) || empty($this->sloodle_controller_instance)) return false;
            // Attempt to update the primary table
            $this->sloodle_module_instance->timemodified = time();
            if (!sloodle_update_record('sloodle', $this->sloodle_module_instance)) return false;
            // Attempt to update the secondary table
            if (!sloodle_update_record('sloodle_controller', $this->sloodle_controller_instance)) return false;
            
            // Everything seems OK
            return true;
        }
        
        
    // ACCESSORS //
    
        /**
        * Determines whether or not this controller is loaded.
        * @return bool
        */
        function is_loaded()
        {
            if (empty($this->cm) || empty($this->sloodle_module_instance) || empty($this->sloodle_controller_instance)) return false;
            return true;
        }
    
        /**
	* DEPRECATED - use get_course_module_id instead
        * Gets the site-wide unique identifier for this module.
        * @return mixed Identifier representing the course module identifier.
        */
        function get_id()
        {
            return $this->get_course_module_id();
        }
        
        /**
        * Gets the site-wide unique identifier for this module.
        * @return mixed Identifier. Type is dependent on VLE. On Moodle, it is an integer course module identifier.
        */
        function get_course_module_id()
        {
            return $this->cm->id;
        }
 
        /**
        * Gets the identifier for controller.
	* DEPRECATED to make it less ambiguous how we're identifying controllers, since we have at least 3 different IDs that can refer to the same thing.
	* If you need this, use get_controller_instance_id instead.
	* TODO (Ed): We shouldn't really need to use this at all or even have it in the database, as the record was already uniquely identified by "sloodleid".
        * @return mixed Identifier. 'id' field of the 'sloodle_controller' table
        */
        function get_controller_id()
        {
            return $this->get_controller_instance_id();
        }
    
        /**
        * Gets the identifier for controller instance.
	* NB Elsewhere when we have a variable called "sloodlecontrollerid", that refers to the course module ID, not the instance ID.
        * @return mixed Identifier. 'id' field of the 'sloodle_controller' table
        */
        function get_controller_instance_id()
        {
            return $this->sloodle_controller_instance->id;
        }

        /**
        * Gets the name of this controller.
        * @return string The name of this controller
        */
        function get_name()
        {
            return $this->sloodle_module_instance->name;
        }
        
        /**
        * Sets the name of this controller.
        * @param string $name The new name for this controller - ignored if empty
        * @return void
        */
        function set_name($name)
        {
            if (!empty($name)) $this->sloodle_module_instance->name = $name;
        }
        
        /**
        * Gets the intro description of this controller.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->sloodle_module_instance->intro;
        }
        
        /**
        * Sets the intro description of this controller.
        * @param string $intro The new intro for this controller - ignored if empty
        * @return void
        */
        function set_intro($intro)
        {
            if (!empty($intro)) $this->sloodle_module_instance->intro = $intro;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->sloodle_module_instance->course;
        }
        
        /**
        * Gets the time at which this controller was created.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return $this->sloodle_module_instance->timecreated;
        }
        
        /**
        * Gets the time at which this controller was last modified.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return $this->sloodle_module_instance->timemodified;
        }
        
        /**
        * Determines whether or not this controller is available (i.e. not hidden).
        * Note: this is separate from being enabled or disabled.
        * @return bool True if the controller is available.
        */
        function is_available()
        {
            //return (bool)($this->cm->visible);
                        return true;
        }
        
        /**
        * Determines if this controller is enabled or not.
        * @return bool True if the controller is enabled, or false otherwise.
        */
        function is_enabled()
        {
            return (bool)($this->sloodle_controller_instance->enabled);
        }
        
        /**
        * Enables this controller
        * @return void
        */
        function enable()
        {
            $this->sloodle_controller_instance->enabled = true;
        }
        
        /**
        * Disables this controller
        * @return void
        */
        function disable()
        {
            $this->sloodle_controller_instance->enabled = false;
        }
        
        /**
        * Gets the prim password of this controller.
        * @return string The current prim password.
        */
        function get_password()
        {
            return $this->sloodle_controller_instance->password;
        }
        
        /**
        * Sets the prim password of this controller.
        * Also checks for validity before storing.
        * @param string $password The new prim password
        * @return bool True if successfully stored, or false if the password is invalid
        */
        function set_password($password)
        {
            // Check validity
            if (!sloodle_validate_prim_password($password)) return false;
            // Store it
            $this->sloodle_controller_instance->password = $password;
            return true;
        }

        
        /**
        * Registers a new active object (or renew an existing authorisation) with this controller.
        * @param string $uuid The UUID of the object to be registered
        * @param string $name Name of the object to be registered
        * @param SloodleUser $user The user who is authorising the object
        * @param string $password The password for the object
        * @param string $type Type identifier of the object to be registered
        * @param int $timestamp The timestamp of the object's registration, or null to use the current time.
        * @return int|bool The new authorisation ID if successful, or false if not
        */
        function register_object($uuid, $name, $user, $password, $httpinpassword = '', $type = '', $timestamp = null)
        {
            // Use the current timestamp if necessary
            if ($timestamp == null) $timestamp = time();
            // Extract the user ID, if available
            $userid = 0;
            if ($user->is_user_loaded()) $userid = $user->get_user_id();
            
            // Check to see if an entry already exists for this object
            $entry = sloodle_get_record('sloodle_active_object', 'uuid', $uuid);
            if (!$entry) {
                // Create a new entry
                $entry = new stdClass();
                $entry->controllerid = $this->cm->id;
                $entry->uuid = $uuid;
                $entry->name = $name;
                $entry->userid = $userid;
                $entry->password = $password;
                $entry->httpinpassword = $httpinpassword;
                $entry->type = $type;
                $entry->timeupdated = $timestamp;
                // Attempt to insert the entry
                $entry->id = sloodle_insert_record('sloodle_active_object', $entry);
                if (!$entry->id) return false;
                
            } else {
                // Update the existing entry
                $entry->controllerid = $this->cm->id;
                $entry->name = $name;
                $entry->userid = $userid;
                $entry->password = $password;
                $entry->httpinpassword = $httpinpassword;
                $entry->type = $type;
                $entry->timeupdated = $timestamp;
                // Attempt to update the database
                if (!sloodle_update_record('sloodle_active_object', $entry)) return false;
            }
            
            return $entry->id;
        }
        
        /**
        * Configures a registered object based on the defaults for its layout entry id
        * @param int $authid The ID of the object as registered by register_object in the active_objects table
        * @param int $layout_entry_id The ID of the layout entry corresponding to this object
        * NB The reverse of this process, where we create a layout entry config based on the active object,
        * ...is in the SloodleLayoutEntry class.
        * TODO: Would this be better there?
        */
        function configure_object_from_layout_entry($authid, $layout_entry_id, $rezzeruuid = null) {

            $ao = new SloodleActiveObject();
            if (!$ao->load($authid)) {
                return false;
            }
 
            $entry = sloodle_get_record('sloodle_layout_entry', 'id', $layout_entry_id);
            if (!$entry) {
                return false;
            }

            $ao->layoutentryid = $entry->id;
            $ao->rotation = $entry->rotation;
            $ao->position = $entry->position;
            $ao->rezzeruuid = $rezzeruuid;
            if (!$ao->save()) {
               return false;
            }

           $configs = sloodle_get_records('sloodle_layout_entry_config','layout_entry',$layout_entry_id);
           $ok = true;
           if (count($configs) > 0) {
              foreach($configs as $config) {
                 $config->id = null;
                 $config->object = $authid;
                 if (!sloodle_insert_record('sloodle_object_config',$config)) {
                    $ok = false;
                 }
              }
           }

        /*
         $lconfig = new stdClass();
         $lconfig->id = null;
         $lconfig->object = $authid;
         $lconfig->name = 'sloodlelayoutentryid';
         $lconfig->value = $layout_entry_id;
         sloodle_insert_record('sloodle_object_config',$lconfig);
        */

           return $ok;

        }
        
        function configure_object_from_parent($authid, $parent_object) {

           // Fetch the UUID of the current object from the header
           // ...then clone its config

           // Check to see if an entry already exists for this object
           $parententry = sloodle_get_record('sloodle_active_object', 'uuid', $parent_object);
/*
           if (!$parententry) {
              return false;
           }
*/

           $parentconfigs = sloodle_get_records('sloodle_object_config','object',$parententry->id);
           $ok = true;
           if (count($parentconfigs) > 0) {
              $clonedconfig = new stdClass();
              foreach($parentconfigs as $config) {
                 $clonedconfig->object = $authid;
                 $clonedconfig->name = $config->name;
                 $clonedconfig->value = $config->value;
                 if (!sloodle_insert_record('sloodle_object_config',$clonedconfig)) {
                    $ok = false;
                 }
              }
           }

           return $ok;

        }

        /**
        * Registers a new unauthorised object.
        * (Can be called statically).
        * Creates a new active object entry, not linked to any user or controller.
        * @param string $uuid The UUID of the object to be registered
        * @param string $name Name of the object to be registered
        * @param string $password The password for the object
        * @param string $type Type identifier of the object to be registered
        * @param int $timestamp The timestamp of the object's registration, or null to use the current time.
        * @return int|bool The integer ID of the active object entry, or false if not
        */
        function register_unauth_object($uuid, $name, $password, $type = '', $timestamp = null)
        {
            // Use the current timestamp if necessary
            if ($timestamp == null) $timestamp = time();
            
            // Check to see if an entry already exists for this object
            $entry = sloodle_get_record('sloodle_active_object', 'uuid', $uuid);
            if (!$entry) {
                // Create a new entry
                $entry = new stdClass();
                $entry->controllerid = 0;
                $entry->uuid = $uuid;
                $entry->name = $name;
                $entry->userid = 0;
                $entry->password = $password;
                $entry->type = $type;
                $entry->timeupdated = $timestamp;
                // Attempt to insert the entry
                $entry->id = sloodle_insert_record('sloodle_active_object', $entry);
                if (!$entry->id) return false;
                
            } else {
                // Update the existing entry
                $entry->controllerid = 0;
                $entry->name = $name;
                $entry->password = $password;
                $entry->type = $type;
                $entry->userid = 0;
                $entry->timeupdated = $timestamp;
                // Attempt to update the database
                if (!sloodle_update_record('sloodle_active_object', $entry)) return false;
            }
            
            return $entry->id;
        }
        
        /**
        * Updates the type of a given active object to the specified type.
        * @param string $uuid The UUID of the object being updated
        * @param string $type Name of the new type identifier
        * @return bool True if successful, or false if not
        */
        function update_object_type($uuid, $type)
        {
            // Attempt to find an entry for the object
            $entry = sloodle_get_record('sloodle_active_object', 'uuid', $uuid);
            if (!$entry) return false;
            // Update the type and time
            $entry->type = $type;
            $entry->timeupdated = time();
            if (!sloodle_update_record('sloodle_active_object', $entry)) return false;
            return true;
        }
        
        /**
        * Authorises an otherwise unauthorised active object against the given user and the current controller.
        * (NOTE: the object must previously have been registered using {@link register_object()}).
        * <b>Must not be called statically.</b>
        * @param string $uuid The UUID of the object being updated
        * @param SloodleUser $user The user to authorise the object against
        * @param string $type (Optional). Specifies the type to store for this object. Ignored if null.
        * @return bool True if successful, or false if not
        */
        function authorise_object($uuid, $user, $type = null)
        {
            // Attempt to find an unauthorised entry for the object
            $entry = sloodle_get_record('sloodle_active_object', 'uuid', $uuid);
            if (!$entry) return false;
            // Update the controller, user and time
            $entry->controllerid = $this->get_course_module_id();
            $entry->userid = $user->get_user_id();
            if (!empty($type)) $entry->type = $type;
            $entry->timeupdated = time();
            if (!sloodle_update_record('sloodle_active_object', $entry)) return false;
            return true;
        }
        
        /**
        * Checks if the specified object is authorised for this controller with the given password.
        * @param object SloodleActiveObject $active_object The active object representing the prim that is talking to us.
        * @param string $password The password to check
        * @return bool True if object is authorised, or false if not
        */
        function check_authorisation($active_object, $password)
        {
            if (is_null($active_object)) {
                return false;
            }
            if ($active_object->controllerid != $this->get_course_module_id()) {
                return false;
            }

            // Make sure we have the type data
            // Edmund Edgar, 2009-01-31: 
            // The type-checking is breaking the auto-configuration based on a profile.
            // It should probably already have been filled in somewhere, so this is probably an auto-configuration bug.
            // But we should probably be doing this check somewhere else, as it's not an authorization check.
            // Maybe it needs its own error code?
            //if (empty($entry->type)) return false;
            
            // Verify the password
            return ($password == $active_object->password);
        }
        
        /**
        * Gets the ID of the user who authorised the specified object.
        * @return mixed|bool Returns the user ID if successful, or FALSE if not
        */
        function get_authorizing_user($uuid)
        {
            // Attempt to find an entry for the object
            $entry = sloodle_get_record('sloodle_active_object', 'controllerid', $this->get_course_module_id(), 'uuid', $uuid);
            if (!$entry) return false;
            return (int)$entry->userid;
        }
        
        
        /**
        * Removes an active object and all its related items.
        * @param mixed $id If it is an integer, then it is treated as the active object ID. If a string, it is treated as the object UUID.
        * @return void
        */
        // TODO: This is now duplicated by delete() in the SloodleActiveObject class. 
        // That seems like a better place to do this.
        // We should either change whatever's calling this to use SloodleActiveObject instead 
        // ...or change this function to call SloodleActiveObject->delete().
        function remove_object($id)
        {
            // Check what type the ID is
            if (is_string($id)) $entry = sloodle_get_record('sloodle_active_object', 'uuid', $id);
            else $entry = sloodle_get_record('sloodle_active_object', 'id', (int)$id);
            if (!$entry) return;
            
            // Delete all config entries and the object record itself
            sloodle_delete_records('sloodle_object_config', 'object', $entry->id);
            sloodle_delete_records('sloodle_active_object', 'id', $entry->id);
        }
        
        /**
        * Gets data about an active object.
        * @param mixed $id If an integer, it is the ID of an active object. If it is a string it is the object's UUID.
        * @return SloodleActiveObject|bool Returns false on failure
        * TODO: Refactor this if anything's using it - it's got nothing to do with the controller, and shouldn't be in here.
        */
        function get_object($id)
        {
            // Check what type the ID is
            if (is_string($id)) $entry = sloodle_get_record('sloodle_active_object', 'uuid', $id);
            else $entry = sloodle_get_record('sloodle_active_object', 'id', (int)$id);
            if (!$entry) return false;
            
            // Create a dummy SloodleSession
            $sloodle = new SloodleSession(false);
            
            // Construct a structure
            $obj = new SloodleActiveObject();
            $obj->uuid = $entry->uuid;
            $obj->name = $entry->name;
            $obj->password = $entry->password;
            $obj->type = $entry->type;
            
            $obj->course = $sloodle->course;
            $obj->course->load_by_controller($entry->controllerid);
            
            $obj->user = $sloodle->user;
            if ($entry->id > 0) {
                $obj->user->load_user($entry->userid);
                $obj->user->load_linked_avatar();
            }
            
            return $obj;
        }
       
        
        /**
        * Returns an array of active object records, or false if something went wrong.
        * (Cannot be called statically... object must be authorised for this controller).
        * @param string $rezzeruuid: The uuid of the rezzer which rezzed the object, or null for all active objects, regardless of rezzer.
        * @param int $layoutentryid: The layout entry id object, or null for all active objects, regardless of layout entry.
        * @return array() active object objects, or false on failure
        */
        function get_active_objects( $rezzeruuid = null, $layoutentryid = null ) {

            $id = $this->get_course_module_id();
            $aos = array();
            if (!$id) {
               return false;
            }
            $recs = array();
 
            $params = array();
            $select = 'controllerid = ?';
            $params[] =intval($id);

            if ($rezzeruuid) {
               $select .= " and rezzeruuid = ?";
               $params[] = $rezzeruuid;
            }
            if ($layoutentryid) {
               $select .= " and layoutentryid = ?";
               $params[] = intval($layoutentryid);
            }

            $recs = sloodle_get_records_select_params('sloodle_active_object', $select, $params);
            if (!$recs) {
                return false;        
            }
            foreach($recs as $rec) {
                if ($rec && $rec->id) {
                    $ao = new SloodleActiveObject();
                    $ao->loadFromRecord($rec);
                    $aos[] = $ao;
               }
            }
            return $aos; 
        }

        /*
        * Return the ID of the currently active round for the controller.
        * @return int $roundid or null if there isn't one
        */
        function get_active_roundid($force_create = false) {
 
            $open_rounds = sloodle_get_records( 'sloodle_award_rounds', 'controllerid', $this->get_course_module_id() );
            foreach($open_rounds as $or ) {
                if ($or->timeended > 0) { // closed
                    continue;
                }
                return $or->id;
            }

            if ($force_create) {
                $created_round = $this->make_new_round();
                return $created_round->id;
            }

            return 0;
 
        }

        function clone_round_participation($fromroundid, $toroundid) {
            
            global $CFG;
            $prefix = $CFG->prefix;
        
            $user_curr = array();
            $scores = sloodle_get_records('sloodle_award_points', 'roundid', $fromroundid);
            if ($scores) {
                foreach($scores as $score) {
                    $userid = $score->userid;
                    $currencyid = $score->currencyid;
                    if (isset($user_curr[ $userid ][$currencyid] )) {
                        continue;
                    }
                    $score->amount = 0;
                    $score->id = null;
                    $score->description = null;
                    $score->roundid = $toroundid;
                    sloodle_insert_record( 'sloodle_award_points', $score );
                    $user_curr[ $userid ] = array();
                    $user_curr[ $userid ][$currencyid] = true;
                }
            }

            return true;

        }

        function make_new_round( $clone_active_round_participation = false ) {

            if (!$courseid = intval($this->get_course_id())) {
                return false;
            }

            $previous_round_id = 0;
            if ($clone_active_round_participation) {
                $previous_round_id = $this->get_active_roundid();
            }
           
            $round = new stdClass();
            $round->timestarted = time();
            $round->timeended = 0;
            $round->name = '';
            $round->controllerid = $this->get_course_module_id();
            $round->courseid = $courseid; // We specify this too so that you can delete the controller but keep the scores.

            if (!$roundid = sloodle_insert_record('sloodle_award_rounds', $round)) {
                return false;
            }

            if ($clone_active_round_participation) {
                $this->clone_round_participation( $previous_round_id, $roundid );
            }

            $round->id = $roundid;

            $this->close_rounds_except( $roundid );

            return $round;

        }

        function close_rounds_except( $roundid ) {

            $open_rounds = sloodle_get_records( 'sloodle_award_rounds', 'controllerid', $this->get_course_module_id() );
            foreach($open_rounds as $or ) {
                if ($or->id == $roundid) {
                   continue;
                }
                if ($or->timeended > 0) {
                    continue;
                }
                $or->timeended = time();
                sloodle_update_record( 'sloodle_award_rounds', $or );
            }

            return true;

        }

    }

