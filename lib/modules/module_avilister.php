<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines an AviLister module for Sloodle.
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
    
    
    /**
    * The Sloodle AviLister module class.
    * Search for real/avatar name associations.
    * @package sloodle
    */
    class SloodleModuleAviLister extends SloodleModule
    {
    // DATA //
    
        //... None...
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleAviLister(&$_session)
        {
            $constructor = get_parent_class($this);
            parent::$constructor($_session);
        }
        
        
        /**
        * Fetch the real name to match the given avatar.
        * Either parameter can be used. If the UUID is empty, then the name is used.
        * If both are specified, then the UUID is used first, but with the name as a fall-back.
        * @param string $avatar_uuid Avatar UUID
        * @param string $avatar_name Full avatar name
        * @return string|bool The full real name of the user if found, or FALSE otherwise.
        */
        function find_real_name($avatar_uuid, $avatar_name)
        {
            // Attempt to find an avatar
            $user = new SloodleUser($this->_session);
            if (!$user->load_avatar($avatar_uuid, $avatar_name)) return false;
            // Attempt to load a linked Moodle user
            if (!$user->load_linked_user()) return false;
            return ($user->get_user_firstname() .' '. $user->get_user_lastname());
        }
        
        
        /**
        * Lookup the realnames for all the given avatar names.
        * Note: the output array may not correspond to the input array, as avatars/users who are not found will not be returned.
        * @param array $avatar_names An array of avatar names
        * @return array An associative array of avatar names to (full) real names
        */
        function find_real_names($avatar_names)
        {
            // Make sure the input is an array
            if (!is_array($avatar_names)) return array();
            $user = new SloodleUser($this->_session);            
            $output = array();
            
            // Go through each input name
            foreach ($avatar_names as $avname) {
                // Attempt to load the given avatar and the linked user
                if (!$user->load_avatar(null, $avname)) continue;
                if (!$user->load_linked_user()) continue;
                // Store the name association
                $output[$avname] = ($user->get_user_firstname() .' '. $user->get_user_lastname());
            }
            
            return $output;
        }
        
        
        /**
        * Lookup the avatar/real name associations for everybody in the current course.
        * NOTE: fails if a course is not loaded in the current {@link SloodleSession}
        * @return array|bool An associative array of avatar names to (full) real names if successful, or false if a course is not available
        */
        function find_real_names_course()
        {
            // Make sure we have a course loaded
            if (!isset($this->_session)) return false;
            if (!$this->_session->course->is_loaded()) return false;
            $user = new SloodleUser($this->_session);            
            // Get a list of users of the course
            $courseusers = get_course_users($this->_session->course->get_course_id());
            if (!is_array($courseusers)) $courseusers = array();
            
            // Go through each user
            $output = array();
            foreach ($courseusers as $u) {
                // Attempt to fetch the avatar data for this Moodle user
                $user->load_user($u->id);
                if (!$user->load_linked_avatar()) continue;
                // Store the name association
                $output[$user->get_avatar_name()] = ($u->firstname.' '.$u->lastname);
            }
            
            return $output;
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this instance
        */
        function get_name()
        {
            return 'AviLister';
        }
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'avilister';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return 'AviLister';
        }

    }
    
    
    /**
    * Represents a single avatar list name association
    * @package sloodle
    */
    class SloodleAviListName
    {
        /**
        * Constructor - initialises members.
        * @param string $avatar_name The user's full avatar name
        * @param string $real_first_name The user's real first name
        * @param string $real_last_name The user's real last name
        */
        function SloodleChatMessage($avatar_name='', $real_first_name='', $real_last_name='')
        {
            $this->avatar_name = $avatar_name;
            $this->real_first_name = $real_first_name;
            $this->real_last_name = $real_last_name;
        }
        
        /**
        * Accessor - set all members in a single call.
        * @param string $avatar_name The user's full avatar name
        * @param string $real_first_name The user's real first name
        * @param string $real_last_name The user's real last name
        * @return void
        */
        function set($avatar_name, $real_first_name, $real_last_name)
        {
            $this->avatar_name = $avatar_name;
            $this->real_first_name = $real_first_name;
            $this->real_last_name = $real_last_name;
        }
        
        /**
        * Gets the full real name of the user ("firstname lastname")
        * @return string
        */
        function get_full_real_name()
        {
            return $this->real_first_name .' '. $this->real_last_name;
        }
        
                
        /**
        * Avatar name ("firstname lastname")
        * @var string
        * @access public
        */
        var $avatar_name = '';
    
        /**
        * Real first name
        * @var string
        * @access public
        */
        var $real_first_name = '';
        
        /**
        * Real last name
        * @var string
        * @access public
        */
        var $real_last_name = '';
    }


?>