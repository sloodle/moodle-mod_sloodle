<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a choice module for Sloodle.
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
    
    /** Include the standard Moodle choice module library. */
    require_once($CFG->dirroot.'/mod/choice/lib.php');
    
    /**
    * The Sloodle choice module class.
    * @package sloodle
    */
    class SloodleModuleChoice extends SloodleModule
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
        * Internal only - Moodle choice module instance database object.
        * Corresponds to one record from the Moodle 'choice' table.
        * @var object
        * @access private
        */
        var $moodle_choice_instance = null;

        /**
        * The number of (non-admin) users on the course who have not yet answered this choice.
        * @var int
        * @access private
        */
        var $numunanswered = 0;
        
        /**
        * The options available for this choice, as an associative array of IDs to {@link SloodleChoiceOption} objects.
        * @var array
        * @access public
        */
        var $options = array();
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleChoice(&$_session)
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
            if (!($this->cm = get_coursemodule_from_id('choice', $id))) {
                sloodle_debug("Failed to load course module instance #$id.<br/>");
                return false;
            }
            // Make sure the module is visible
            if ($this->cm->visible == 0) {
                sloodle_debug("Error: course module instance #$id not visible.<br/>");
                return false;
            }
            
            // Load from the primary table: choice instance
            if (!($this->moodle_choice_instance = get_record('choice', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load choice with instance ID #{$cm->instance}.<br/>");
                return false;
            }

            // Fetch options
            $this->options = array();
            if ($options = get_records('choice_options', 'choiceid', $this->moodle_choice_instance->id)) {
                // Get response data (this uses the standard choice function, in "moodle/mod/choice/lib.php")
                $allresponses = choice_get_response_data($this->moodle_choice_instance, $this->cm, 0);

                foreach ($options as $opt) {
                    // Create our option object and add our data
                    $this->options[$opt->id] = new SloodleChoiceOption();
                    $this->options[$opt->id]->id = $opt->id;
                    $this->options[$opt->id]->text = $opt->text;
                    $this->options[$opt->id]->maxselections = $opt->maxanswers;
                    $this->options[$opt->id]->timemodified = (int)$opt->timemodified;

                    // Count the number of selections made
                    $numsels = 0;
                    if (isset($allresponses[$opt->id])) $numsels = count($allresponses[$opt->id]);
                    $this->options[$opt->id]->numselections = $numsels;
                }
            }
            
            // Determine how many people on the course have not yet answered
            $users = get_course_users($this->cm->course);
            if (!is_array($users)) $users = array();
            $num_users = count($users);
            $numanswers = (int)count_records('choice_answers', 'choiceid', $this->moodle_choice_instance->id);
            $this->numunanswered = max(0, $num_users - $numanswers);
            
            return true;
        }
        
        /**
        * Selects an option in this choice on behalf of the specified user.
        * Logs the user in to the VLE if necessary.
        * If a general error occurs, FALSE will be returned.
        * Otherwise, an integer {@link http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes status code} will be returned.
        * The following status codes are typical responses:
        *  * 10011 = added new choice selection
        *  * 10012 = updated existing choice selection
        *  * 10013 = user previously selected same option
        *  * -10011 = User already made a selection, and re-selection is not allowed
        *  * -10012 = max number of selections for this option already made
        *  * -10013 = choice is not yet open
        *  * -10014 = choice is already closed
        *
        * @param mixed $optionid The unique site-wide identifier of the option to be selected
        * @param mixed $user A SloodleUser identifying the current user; if omitted, the current {@link SloodleSession} will be used.
        * @return integer|false
        */
        function select_option($optionid, $user = null)
        {
            // Fetch a user if necessary
            if ($user === null) {
                // Make sure we have a session user
                if (!isset($this->_session->user)) return false;
                $user = $this->_session->user;
            }
            // Make sure we have a user loaded and logged-in
            if (!$user->is_user_loaded()) return false;
            if (!$user->login()) return false;
            
            // Make sure the user is permitted to select from this choice
            if (!has_capability('mod/choice:choose', get_context_instance(CONTEXT_MODULE, $this->cm->id))) return -331;
            // Make sure the choice is open
            if ($this->is_early()) return -10013;
            if ($this->is_late()) return -10014;
            
            // Has the user already made a selection for this choice?
            $update_selection = false;
            $previous_selection = get_record('choice_answers', 'choiceid', $this->moodle_choice_instance->id, 'userid', $user->get_user_id());
            if ($previous_selection) {
                // Was it a selection of the same option?
                if ($previous_selection->optionid == $optionid) {
                    // Yes - that's fine. Nothing to do.
                    return 10013;
                }
                // No - are re-selections allowed?
                if (!$this->allow_update()) {
                    // No - stop here
                    return -10011;
                }
                $update_selection = true;
            }
            
            // Fetch the option record
            $option = get_record('choice_options', 'id', $optionid, 'choiceid', $this->moodle_choice_instance->id);
            if (!$option) return false;
            
            // Make sure the maximum selections for the given option have not yet been made
            if (!empty($this->moodle_choice_instance->limitanswers)) {
                $numselections = count_records('choice_answers', 'optionid', $optionid);
                if (!$numselections) return false;
                if ($numselections >= $option->maxanswers) return -10012;
            }
            
            // If necessary, delete the existing selection
            if ($update_selection) delete_records('choice_answers', 'choiceid', $this->moodle_choice_instance->id, 'userid', $user->get_user_id());
            
            // Select the new option
            $selection = new stdClass();
            $selection->choiceid = $this->moodle_choice_instance->id;
            $selection->userid = $user->get_user_id();
            $selection->optionid = $optionid;
            $selection->timemodified = time();
            if (!insert_record('choice_answers', $selection)) return false;
            
            // Success!
            if ($update_selection) return 10012;
            return 10011;
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this controller
        */
        function get_name()
        {
            return $this->moodle_choice_instance->name;
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->moodle_choice_instance->text;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->moodle_choice_instance->course;
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
            return (int)$this->moodle_choice_instance->timemodified;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'choice';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('modulename', 'choice');
        }
        
        /**
        * Gets the time at which this choice opens.
        * @return int Timestamp. 0 if choice has no opening time.
        */
        function get_opening_time()
        {
            return (int)$this->moodle_choice_instance->timeopen;
        }
        
        /**
        * Gets the time at which this choice closes.
        * @return int Timestamp. 0 if choice has no closing time.
        */
        function get_closing_time()
        {
            return (int)$this->moodle_choice_instance->timeclose;
        }
        
        /**
        * Determines if the choice is currently open.
        * @param int $timestamp The time to test. Uses the current time if none is given.
        * @return bool
        */
        function is_open($timestamp = null)
        {
            // Use the current time if necessary
            if ($timestamp === null) $timestamp = time();
            // Check against the opening and closing times
            $open = $this->get_opening_time();
            $close = $this->get_closing_time();
            if ($open > 0 && $open > $timestamp) return false;
            if ($close > 0 && $close < $timestamp) return false;
            return true;
        }
        
        /**
        * Determines if the choice has not opened yet.
        * @param int $timestamp The time to test. Uses the current time if none is given.
        * @return bool
        */
        function is_early($timestamp = null)
        {
            // Use the current time if necessary
            if ($timestamp === null) $timestamp = time();
            // Check against the opening time
            $open = $this->get_opening_time();
            if ($open == 0) return false; // No opening time - can never be early
            return ($open > $timestamp);
        }
        
        /**
        * Determines if the choice has already closed.
        * @param int $timestamp The time to test. Uses the current time if none is given.
        * @return bool
        */
        function is_late($timestamp = null)
        {
            // Use the current time if necessary
            if ($timestamp === null) $timestamp = time();
            // Check against the closing time
            $close = $this->get_closing_time();
            if ($close == 0) return false; // No opening time - can never be early
            return ($close < $timestamp);
        }
        
        /**
        * Checks if users are allowed to re-select their answer in this choice.
        * @return bool
        */
        function allow_update()
        {
            return !empty($this->moodle_choice_instance->allowupdate);
        }
        
        /**
        * Checks if results are to be shown.
        * (Some choices only allow results after the choice is closed).
        * @return bool
        */
        function can_show_results()
        {
            if ($this->moodle_choice_instance->showresults == CHOICE_SHOWRESULTS_ALWAYS) return true;
            if ($this->moodle_choice_instance->showresults == CHOICE_SHOWRESULTS_AFTER_CLOSE && $this->is_late()) return true;
            return false;
        }
        
        /**
        * Gets the number of people who have not yet answered the choice.
        * Counts all users on the course, including students and teachers.
        * @return int
        */
        function get_num_unanswered()
        {
            return $this->numunanswered;
        }

    }
    
    
    /**
    * Class to represent a single available option for a choice.
    * @package sloodle
    */
    class SloodleChoiceOption
    {
        /**
        * The ID of the option (should be unique across the site).
        * @var mixed
        * @access public
        */
        var $id = 0;
        
        /**
        * The text of this option.
        * @var string
        * @access public
        */
        var $text = '';
        
        /**
        * Number of selections so far of this option.
        * @var int
        * @access public
        */
        var $numselections = 0;
        
        /**
        * Maximum allowed number of selections for this option.
        * Note: will be -1 if there is no limit.
        * @var int
        * @access public
        */
        var $maxselections = -1;
        
        /**
        * Timestamp of when this option was last modified.
        * $var int
        * @access public
        */
        var $timemodified = 0;
    }


?>
