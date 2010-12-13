<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a Sloodle Object assignment module for Sloodle.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    /** The Sloodle module base. */
    require_once(SLOODLE_LIBROOT.'/modules/module_base.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    
    // Make sure the Sloodle Object assignment type is installed
    $incfile = $CFG->dirroot.'/mod/assignment/type/sloodleobject/assignment.class.php';
    if (!file_exists($incfile)) return; // Leaves this script, but does not terminate execution
    
    /** The Sloodle Object assignment type. */
    require_once($incfile);
    
    /**
    * The Sloodle Object assignment module class.
    * @package sloodle
    */
    class SloodleModuleSloodleObject extends SloodleModule
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
        * Internal only - Moodle assignment module instance database object.
        * Corresponds to one record from the Moodle 'assignment' table.
        * @var object
        * @access private
        */
        var $moodle_assignment_instance = null;

        /**
        * Internal only - the Moodle assignment structure.
        * @var assignment_sloodleobject
        * @access private
        */
        var $assignment = null;
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleSloodleObject(&$_session)
        {
            $constructor = get_parent_class($this);
            parent::$constructor($_session);
        }
        
        /**
        * Loads data from the database.
        * Note: even if the function fails, it may still have overwritten some or all existing data in the object.
        * @param mixed $id The site-wide unique identifier for all modules. Type depends on VLE. On Moodle, it is an integer course module identifier ('id' field of 'course_modules' table)
        * @return bool True if successful, or false otherwise
        */
        function load($id)
        {
            // Make sure the ID is valid
            $id = (int)$id;
            if ($id <= 0) return false;
            
            // Fetch the course module data
            if (!($this->cm = get_coursemodule_from_id('assignment', $id))) {
                sloodle_debug("Failed to load course module instance #$id.<br/>");
                return false;
            }
            // Make sure the module is visible
            if ($this->cm->visible == 0) {
                sloodle_debug("Error: course module instance #$id not visible.<br/>");
                return false;
            }
            
            // Load from the primary table: assignment instance
            if (!($this->moodle_assignment_instance = get_record('assignment', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load assignment with instance ID #{$cm->instance}.<br/>");
                return false;
            }
            
            // Make sure this assignment is of the correct type
            if ($this->moodle_assignment_instance->assignmenttype != 'sloodleobject') {
                sloodle_debug("ERROR assignment \"{$this->moodle_assignment_instance->name}\" is not of type 'sloodleobject' (actual type: '{$this->moodle_assignment_instance->assignmenttype}').");
                return false;
            }
            
            // Attempt to construct the assignment object
            $this->assignment = new assignment_sloodleobject($this->cm->id, $this->moodle_assignment_instance, $this->cm);
            
            return true;
        }
        
        /**
        * Checks if the specified user is permitted to submit to this assignment.
        * (Note: this only checks permissions, and no other settings, such as submission times).
        * @param SloodleUser $user The user to be checked
        * @return bool True if the user has permission to submit to this assignment, or false otherwise.
        */
        function user_can_submit($user)
        {
            // Make sure a user is loaded
            if (!$user->is_user_loaded()) return false;
            // Login the current user, and check capabilities
            if (!$user->login()) return false;
            return has_capability('mod/assignment:submit', get_context_instance(CONTEXT_MODULE, $this->cm->id));
        }
        
        /**
        * Checks if the specified user is permitted to view submissions to this assignment.
        * @param SloodleUser $user The user to be checked
        * @return bool True if the user has permission to view the submissions, or false otherwise.
        */
        function user_can_view($user)
        {
            // Make sure a user is loaded
            if (!$user->is_user_loaded()) return false;
            // Login the current user, and check capabilities
            if (!$user->login()) return false;
            return has_capability('mod/assignment:view', get_context_instance(CONTEXT_MODULE, $this->cm->id));
        }
        
        /**
        * Checks if the specified user has submitted to this assignment already.
        * @param SloodleUser $user The user to be checked
        * @return bool True if the user has previously attempted this assignment, or false otherwise
        */
        function user_has_submitted($user)
        {
            // Make sure a user is loaded
            if (!$user->is_user_loaded()) return false;
            // Check for a submission by this user
            if (record_exists('assignment_submissions', 'assignment', $this->moodle_assignment_instance->id, 'userid', $user->get_user_id())) return true;
            return false;
        }
        
        /**
        * Checks if re-submissions are permitted.
        * @return bool True if resubmissions are permitted, or false otherwise
        */
        function resubmit_allowed()
        {
            if (empty($this->moodle_assignment_instance->resubmit)) return false;
            return true;
        }
        
        /**
        * Checks if an assignment submitted at the specified time would be too early for submission.
        * @param int $timestamp A timestamp giving the time to check (if omitted, it defaults to the current timestamp)
        * @return bool True if assignment would be too early, or false if it's OK.
        */
        function is_too_early($timestamp = null)
        {
            // If no 'available' time is set, then nothing is too early
            if (empty($this->moodle_assignment_instance->timeavailable) || $this->moodle_assignment_instance->timeavailable <= 0) return false;
            // Use the current timestamp if need be
            if ($timestamp == null) $timestamp = time();
            // Check the time
            return ($timestamp < $this->moodle_assignment_instance->timeavailable);
        }
        
        /**
        * Checks if an assignment submitted at the specified time would be too late for submission.
        * @param int $timestamp A timestamp giving the time to check (if omitted, it defaults to the current timestamp)
        * @return int 1 if assignment would be too late and cannot be accepted, 0 if it is OK, or -1 if it would be late but still accepted
        */
        function is_too_late($timestamp = null)
        {
            // If no 'due' time is set, then nothing is too early
            if (empty($this->moodle_assignment_instance->timedue) || $this->moodle_assignment_instance->timedue <= 0) return false;
            // Use the current timestamp if need be
            if ($timestamp == null) $timestamp = time();
            
            // Check the time
            if ($timestamp > $this->moodle_assignment_instance->timedue) {
                // It's late... check if late submissions are prevented
                if (empty($this->moodle_assignment_instance->preventlate)) {
                    return -1;
                } else {
                    return 1;
                }
            }
            // It's OK
            return 0;
        }
        
        /**
        * Add a new submission (or replace an existing one).
        * Ignores all submission checks, such as permissions and time.
        * @param SloodleUser $user The user making the submission
        * @param string $obj_name Name of the object being submitted
        * @param int $num_prims Number of prims in the object being submitted
        * @param string $primdrop_name Name of the PrimDrop being submitted to
        * @param string $primdrop_uuid UUID of the PrimDrop being submitted to
        * @param string $primdrop_region Region of the PrimDrop being submitted to
        * @param string $primdrop_pos Position vector (<x,y,z>) of the PrimDrop being submitted to
        * @return bool True if successful, or false otherwise
        */
        function submit($user, $obj_name, $num_prims, $primdrop_name, $primdrop_uuid, $primdrop_region, $primdrop_pos)
        {
            // Make sure the user is loaded
            if (!$user->is_user_loaded()) return false;
            // Construct a submission object
            $sloodle_submission = new assignment_sloodleobject_submission();
            $sloodle_submission->obj_name = $obj_name;
            $sloodle_submission->num_prims = $num_prims;
            $sloodle_submission->primdrop_name = $primdrop_name;
            $sloodle_submission->primdrop_uuid = $primdrop_uuid;
            $sloodle_submission->primdrop_region = $primdrop_region;
            $sloodle_submission->primdrop_pos = $primdrop_pos;
            
            // Update the submission
            return $this->assignment->update_submission($user->get_user_id(), $sloodle_submission);
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this controller
        */
        function get_name()
        {
            return $this->moodle_assignment_instance->name;
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->moodle_assignment_instance->description;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->moodle_assignment_instance->course;
        }
        
        /**
        * Gets the time at which this instance was created, or 0 if unknown.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return 0;
        }
        
        /**
        * Gets the time at which this instance was last modified, or 0 if unknown.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return (int)$this->moodle_assignment_instance->timemodified;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'sloodleobject';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('typesloodleobject', 'assignment');
        }

    }

?>