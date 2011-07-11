<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a map resource module for Sloodle.
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
    * The Sloodle map resource module class.
    * @package sloodle
    */
    class SloodleModuleMap extends SloodleModule
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
        * Corresponds to one record from the Moodle 'mdl_sloodle' table.
        * @var object
        * @access private
        */
        var $sloodle_instance = null;
        
        /**
        * Instance of the extra Map data from the sloodle_map table.
        * @var object
        * @access private
        */
        var $sloodle_map = null;
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleMap(&$_session)
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
            if (!($this->cm = get_coursemodule_from_id('sloodle', $id))) {
                sloodle_debug("Failed to load course module instance #$id.<br/>");
                return false;
            }
            // Make sure the module is visible
            if ($this->cm->visible == 0) {
                // Ignore visibility - teachers may want to setup map when it's invisible.
                //sloodle_debug("Error: course module instance #$id not visible.<br/>");
                //return false;
            }
            
            // Load from the primary table: sloodle instance
            if (!($this->sloodle_instance = sloodle_get_record('sloodle', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load Sloodle module with instance ID #{$cm->instance}.<br/>");
                return false;
            }
            
            // Load from the secondary table: sloodle map
            if (!($this->sloodle_map = sloodle_get_record('sloodle_map', 'sloodleid', $this->sloodle_instance->id))) {
                sloodle_debug("Failed to load Sloodle map with sloodleid #{$this->sloodle_instance->id}.<br/>");
                return false;
            }
            
            return true;
        }
        
        /**
        * Gets the initial coordinates of the map.
        * @return array Numeric array (or list) containing X and Y floating point components, as global coordinates.
        */
        function get_initial_coordinates()
        {
            return array((float)$this->sloodle_map->initialx, (float)$this->sloodle_map->initialy);
        }
        
        /**
        * Sets the initial coordinates of the map.
        * @par int $x The global X coordinate for the map's initial location
        * @par int $y The global Y coordinate for the map's initial location
        * @return bool True if successful, or false if not.
        */
        function set_initial_coordinates($x, $y)
        {
            // Clean the data
            $x = (float)$x;
            $y = (float)$y;
            // Update the data
            $this->sloodle_map->initialx = $x;
            $this->sloodle_map->initialy = $y;
            return sloodle_update_record('sloodle_map', $this->sloodle_map);
        }
        
        /**
        * Gets the initial zoom factor of the map (1 - 6).
        * @return integer
        */
        function get_initial_zoom()
        {
            return (int)$this->sloodle_map->initialzoom;
        }
        
        /**
        * Checks if the pan controls should be visible.
        * @return bool
        */
        function check_pan_controls()
        {
            return (!empty($this->sloodle_map->showpan));
        }
        
        /**
        * Checks if map dragging should be enabled.
        * @return bool
        */
        function check_allow_drag()
        {
            return (!empty($this->sloodle_map->allowdrag));
        }
        
        /**
        * Checks if the zoom controls should be visible.
        * @return bool
        */
        function check_zoom_controls()
        {
            return (!empty($this->sloodle_map->showzoom));
        }
        
        
        /**
        * Returns a numeric array of locations associated with this map. Sorted by name.
        * Each element is an object direct from the sloodle_map_location table.
        * @return array
        */
        function get_locations()
        {
            $results = sloodle_get_records('sloodle_map_location', 'sloodleid', $this->sloodle_instance->id, 'name');
            if (!$results) return array();
            return $results;
        }
        
        /**
        * Adds a new location to this map.
        * @par float $globalx Global X coordinate for map location.
        * @par float $globaly Global Y coordinate for map location.
        * @par string $region Name of the region this location is in.
        * @par int $localx Local X coordinate for SLurl (local to region).
        * @par int $localy Local Y coordinate for SLurl (local to region).
        * @par int $localz Local Z coordinate for SLurl (local to region).
        * @par string $name Name of the location.
        * @par string $desc Description of the location (optional).
        * @return bool True if successful or false if not.
        */
        function add_location($globalx, $globaly, $region, $localx, $localy, $localz, $name, $desc = '')
        {
            // Prepare a database record
            $rec = new stdClass();
            $rec->sloodleid = $this->sloodle_instance->id;
            // Clean all the data and add it
            $rec->globalx = (float)$globalx;
            $rec->globaly = (float)$globaly;
            $rec->region = clean_text($region, FORMAT_PLAIN);
            $rec->localx = (int)$localx;
            $rec->localy = (int)$localy;
            $rec->localz = (int)$localz;
            $rec->name = clean_text($name, FORMAT_PLAIN);
            $rec->description = clean_text($desc, FORMAT_PLAIN);
            
            return sloodle_insert_record('sloodle_map_location', $rec, false);
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this module
        */
        function get_name()
        {
            return $this->sloodle_instance->name;
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->sloodle_instance->intro;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->sloodle_instance->course;
        }
        
        /**
        * Gets the time at which this instance was created, or 0 if unknown.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return (int)$this->sloodle_instance->timecreated;
        }
        
        /**
        * Gets the time at which this instance was last modified, or 0 if unknown.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return (int)$this->sloodle_instance->timemodified;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return SLOODLE_TYPE_MAP;
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('moduletype:'.SLOODLE_TYPE_MAP, 'sloodle');
        }

    }
?>
