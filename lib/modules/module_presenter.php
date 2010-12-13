<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a Presenter module for Sloodle.
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
    * The Sloodle presenter module class.
    * @package sloodle
    */
    class SloodleModulePresenter extends SloodleModule
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
        * Internal only - a database objects representing the Presenter itself.
        * Corresponds to one record from the Moodle 'mdl_sloodle_presenter' table.
        * @var object
        * @access private
        */
        var $presenter = null;

                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModulePresenter(&$_session)
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
                sloodle_debug("Error: course module instance #$id not visible.<br/>");
                return false;
            }
            
            // Load from the primary table: sloodle instance
            if (!($this->sloodle_instance = get_record('sloodle', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load Sloodle module with instance ID #{$cm->instance}.<br/>");
                return false;
            }

            // Load from the secondary table: sloodle_presenter
            if (!($this->presenter = get_record('sloodle_presenter', 'sloodleid', $this->cm->instance))) {
                sloodle_debug("Failed to load secondary module table with instance ID #{$this->cm->instance}.<br/>");
                return false;
            }
            
            return true;
        }
        
        
        /**
        * Gets an array of absolute URLs to images in this slideshow, all correctly ordered.
        * @return 2d numeric array, each element associates an entry ID to a numeric array of URL string, the name of the source type, and the name of the slide.
        */
        function get_entry_urls()
        {
            // Search the database for entries
            $recs = get_records_select('sloodle_presenter_entry', "sloodleid = {$this->sloodle_instance->id}", 'ordering');
            if (!$recs) return array();
            // Format it all nicely into a simple array
            $output = array();
            foreach ($recs as $r) {
				// Substitute the source data for the name if no name is given.
                $name = '';
                if (isset($r->name)){
                    $name = $r->name;
                }
                if (empty($name)) $name = $r->source;
                $output[$r->id] = array($r->source, $r->type, $name);
            }
            return $output;
        }
        
        /**
        * Gets a specific slide from the presentation, identified by its database ID.
        * Note that the slide position is NOT determined by this function so it will be given as -1.
        * Use "get_slides()" to fetch an array with valid slide positions.
        * @param int $id The record ID of the sldie in the database.
        * @return SloodlePresenterSlide|bool A slide object if successful, or false if it could not be found.
        */
        function get_slide($id)
        {
            // Sanitize the data
            $id = (int)$id;
       
            // Fetch the requested slide
            $rec = get_record('sloodle_presenter_entry', 'id', $id);
            if (!$rec) return false;
            
            // Substitute the source data for the name if no name is given.
			$name = '';
			if (isset($rec->name)){
				$name = $rec->name;
			}
			if (empty($name)) $name = $rec->source;
            
            // Convert plugin class names back to legacy slide types.
            // (The class names were used temporarily, but deemed unnecessary.)
            $type = strtolower($rec->type);
            switch ($type)
            {
            case 'sloodlepluginpresenterslideimage': case 'presenterslideimage': $type = 'image'; break;
            case 'sloodlepluginpresenterslideweb': case 'presenterslideweb': $type = 'web'; break;
            case 'sloodlepluginpresenterslidevideo': case 'presenterslidevideo': $type = 'video'; break;
            }
            
            return new SloodlePresenterSlide($rec->id, $this, $name, $rec->source, $type, $rec->ordering, -1);
        }

        /**
        * Gets an ordered associative array of slides in presentation order.
        * @return Array associating slide IDs to SloodlePresenterSlide objects if successful, or false if not.
        */
        function get_slides()
        {
            // Make sure we have valid ordering
            $this->validate_ordering();
            // Fetch the database records
            $recs = get_records_select('sloodle_presenter_entry', "sloodleid = {$this->sloodle_instance->id}", 'ordering');
            if (!$recs) return array();
            // Construct the array of objects
            $output = array();
            $slideposition = 1;
            foreach ($recs as $r) {
                // Substitute the source data for the name if no name is given.
                $name = '';
                if (isset($r->name)){
                    $name = $r->name;
                }
                if (empty($name)) $name = $r->source;
                
                // Convert plugin class names back to legacy slide types.
                // (The class names were used temporarily, but deemed unnecessary.)
                $type = strtolower($r->type);
                switch ($r->type)
                {
                case 'sloodlepluginpresenterslideimage': case 'presenterslideimage': $type = 'image'; break;
                case 'sloodlepluginpresenterslideweb': case 'presenterslideweb': $type = 'web'; break;
                case 'sloodlepluginpresenterslidevideo': case 'presenterslidevideo': $type = 'video'; break;
                }

                // Add the slide to our list
                $output[$r->id] = new SloodlePresenterSlide($r->id, $this, $name, $r->source, $type, $r->ordering, $slideposition);
                $slideposition++;
            }
            return $output;
        }
       
        /**
        * Adds a new entry to the presentation.
        * @param string $source A string containing the source address -- must start with http for absolute URLs
        * @param string $type Name of the type of source, e.g. "web", "image", or "video"
        * @param string $name Name of the slide
        * @param integer $position Integer indicating the position of the new entry. If negative, then it is placed last in the presentation.
        * @return True if successful, or false on failure.
        */
        function add_entry($source, $type, $name, $position = -1)
        {
            // Make sure our entry ordering is valid before we start
            $this->validate_ordering();
 
            // Construct and attempt to insert the new record
            $rec = new stdClass();
            $rec->sloodleid = $this->sloodle_instance->id;
            $rec->source = $source;
            $rec->name = $name;
            $rec->type = $type;
            if ($position < 0) {
                $num = count_records('sloodle_presenter_entry', 'sloodleid', $this->sloodle_instance->id);
                $rec->ordering = ((int)$num + 1) * 10;
            } else {
                $rec->ordering = ($position * 10) - 1; // Ordering works in multiples of 10, starting at 10.
            }
            $result = (bool)insert_record('sloodle_presenter_entry', $rec, false);
            
            // Make sure our entry ordering is valid again now
            $this->validate_ordering();
            return $result;
        }
       
 
        /**
        * Edits an existing entry in the presentation.
        * @param int $id The ID of the entry in the database.
        * @param string $source A string containing the source address -- must start with http for absolute URLs
        * @param string $type Name of the type of source, e.g. "web", "image", or "video"
        * @param string $name Name of the slide
        * @param integer $position Integer indicating the desired position of the entry. If negative, then its position is left unchanged.
        * @return True if successful, or false on failure.
        */
        function edit_entry($id, $source, $type, $name, $position = -1)
        {
            // Ensure we have valid ordering to begin with
            $this->validate_ordering();

            // Attempt to fetch the existing entry from the database
            $id = (int)$id;
            $rec = get_record('sloodle_presenter_entry', 'id', $id, 'sloodleid', $this->sloodle_instance->id);
            if (!$rec) return false;

            // Apply the changes to the record
            $rec->source = $source;
            $rec->name = $name;
            $rec->type = $type;
            if ($position > 0) {
                $rec->ordering = ($position * 10) - 1; // Ordering works in multiples of 10, starting at 10.
            }
            // Update the database
            $result = (bool)update_record('sloodle_presenter_entry', $rec);
			
			// Make sure our entry ordering is valid
            $this->validate_ordering();
            return $result;
        }
        
        /**
        * Deletes the identified entry by ID.
        * Only works if the entry is part of this presentation.
        * @param int $id The ID of an entry record to delete
        * @return bool True if successful or false otherwise.
        */
        function delete_entry($id)
        {
           $result = delete_records('sloodle_presenter_entry', 'sloodleid', $this->sloodle_instance->id, 'id', $id);
           // Fix the ordering
           $this->validate_ordering();
           
           if ($result === false) return false;
           return true;
        }

        /**
        * Moves the ID'd entry forward or back in the presentation ordering.
        * Only works if the entry is part of this presentation.
        * @param int $id The ID of the entry to move.
        * @param bool $forward TRUE to move the entry forward (closer to the beginning) or FALSE to push it back (closer to the end)
        * @return void
        */
        function move_entry($id, $forward)
        {
            // Start by ensuring uniform ordering, starting at 10.
            $this->validate_ordering();
            // Attempt to move the specified entry in the appropriate direction
            $entry = get_record('sloodle_presenter_entry', 'sloodleid', $this->sloodle_instance->id, 'id', $id);
            if (!$entry) return;
            if ($forward) {
                // Avoid a negative ordering value.
                if ($entry->ordering >= 20) $entry->ordering -= 15;
            } else {
                $entry->ordering += 15;
            }
            update_record('sloodle_presenter_entry', $entry);
            // Re-validate the entry ordering
            $this->validate_ordering();
        }
		
		/**
		* Relocates the identified entry to the specified position in the presentation.
		* Positions count from 1 upwards. If an entry already exists in that location, then the existing entry is pushed to the next position.
		* @param int $id The ID of the entry to relocate
		* @param int $pos The position in the presentation to move the slide to
		* @return void
		*/
		function relocate_entry($id, $pos)
		{
			// Start by ensuring uniform ordering, starting at 10.
            $this->validate_ordering();
			// Calculate the ordering value for our entry.
			// The first entry in a presentation has ordering 10, and subsequent entries increment by 10.
			// Therefore, we can insert an entry before an existing slot by moving it to one BEFORE the appropriate multiple of 10.
			$newordering = ($pos * 10) - 1;
			
			// Write the new ordering to the database, and re-validate the order
			$entry = get_record('sloodle_presenter_entry', 'sloodleid', $this->sloodle_instance->id, 'id', $id);
            if (!$entry) return;
			$entry->ordering = $newordering;
			update_record('sloodle_presenter_entry', $entry);
            
            $this->validate_ordering();
		}
        
        /**
        * Validates the ordering value of all entries in the presenter.
        * Gives each record an ordering value from 10 upwards, incrementing by 10 each time.
        * @return void
        */
        function validate_ordering()
        {
            // Get all entries in this presentation
            $entries = get_records('sloodle_presenter_entry', 'sloodleid', $this->sloodle_instance->id, 'ordering');
            if (!$entries || count($entries) <= 1) return;

            // Go through each entry in our array, and give it a valid ordering value.
            $ordering = 10;
            foreach ($entries as $entry) {
                $entry->ordering = $ordering;
                update_record('sloodle_presenter_entry', $entry);
                $ordering += 10;
            }
        }
        
        
    // BACKUP AND RESTORE //
        
        /**
        * Backs-up secondary data regarding this module.
        * That includes everything except the main 'sloodle' database table for this instance.
        * @param $bf Handle to the file which backup data should be written to.
        * @param bool $includeuserdata Indicates whether or not to backup 'user' data, i.e. any content. Most SLOODLE tools don't have any user data.
        * @return bool True if successful, or false on failure.
        */
        function backup($bf, $includeuserdata)
        {
            // Data about the Presenter itself
            fwrite($bf, full_tag('ID', 5, false, $this->presenter->id));
            fwrite($bf, full_tag('FRAMEWIDTH', 5, false, $this->presenter->framewidth));
            fwrite($bf, full_tag('FRAMEHEIGHT', 5, false, $this->presenter->frameheight));
            
            // Attempt to fetch all the slides in the presentation
            $slides = $this->get_slides();
            if (!$slides) return false;
            
            // Data about the slides in the presenter.
            // Currently this will only backup the raw URLs, and won't transfer any files.
            // In future, it should backup any files which are on the same server.
            fwrite($bf, start_tag('SLIDES', 5, true));
            foreach ($slides as $slide) {
                fwrite($bf, start_tag('SLIDE', 6, true));
                
                // Convert plugin class names back to simple slide types
                switch ($slide->type) {
                    case 'SloodlePluginPresenterSlideImage': case 'PresenterSlideImage': $slide->type = 'image'; break;
                    case 'SloodlePluginPresenterSlideVideo': case 'PresenterSlideVideo': $slide->type = 'video'; break;
                    case 'SloodlePluginPresenterSlideWeb': case 'PresenterSlideWeb': $slide->type = 'web'; break;
                }
                
                fwrite($bf, full_tag('ID', 7, false, $slide->id));
                fwrite($bf, full_tag('NAME', 7, false, $slide->name));
                fwrite($bf, full_tag('SOURCE', 7, false, $slide->source));
                fwrite($bf, full_tag('TYPE', 7, false, $slide->type));
                fwrite($bf, full_tag('ORDERING', 7, false, $slide->ordering));
                
                fwrite($bf, end_tag('SLIDE', 6, true));
            }
            fwrite($bf, end_tag('SLIDES', 5, true));
            
            
            return true;
        }
        
        /**
        * Restore this module's secondary data into the database.
        * This ignores any member data, so can be called statically.
        * @param int $sloodleid The ID of the primary SLOODLE entry this restore belongs to (i.e. the ID of the record in the "sloodle" table)
        * @param array $info An associative array representing the XML backup information for the secondary module data
        * @param bool $includeuserdata Indicates whether or not to restore user data
        * @return bool True if successful, or false on failure.
        */
        function restore($sloodleid, $info, $includeuserdata)
        {
            // Construct the database record for the Presenter itself
            $presenter = new object();
            $presenter->sloodleid = $sloodleid;
            $presenter->framewidth = $info['FRAMEWIDTH']['0']['#'];
            $presenter->frameheight = $info['FRAMEHEIGHT']['0']['#'];
            
            $presenter->id = insert_record('sloodle_presenter', $presenter);
            
            // Go through each slide in the presenter backup
            $numslides = count($info['SLIDES']['0']['#']['SLIDE']);
            $curslide = null;
            for ($slidenum = 0; $slidenum < $numslides; $slidenum++) {
                // Get the current slide data
                $curslide = $info['SLIDES']['0']['#']['SLIDE'][$slidenum]['#'];
                // Construct a new Presenter slide database object
                $slide = new object();
                $slide->sloodleid = $sloodleid;
                $slide->name = $curslide['NAME']['0']['#'];
                $slide->source = $curslide['SOURCE']['0']['#'];
                $slide->type = $curslide['TYPE']['0']['#'];
                $slide->ordering = $curslide['ORDERING']['0']['#'];
                
                $slide->id = insert_record('sloodle_presenter_entry', $slide);
            }
        
            return true;
        }
        
        
        /**
        * Gets the name of the user data required by this type, or an empty string if none is required.
        * For example, a chatroom would use the name "Messages" for user data.
        * Note that this should respect current language settings in Moodle.
        * @return string Localised name of the user data.
        */
        function get_user_data_name()
        {
            return '';
        }
        
        /**
        * Gets the number of user data records to be backed-up.
        * @return int A count of the number of user data records which can be backed-up.
        */
        function get_user_data_count()
        {
            return 0;
        }
        
        
    // ACCESSORS //

        /**
        * Gets the width of the Presenter frame (for viewing in Moodle).
        * @return int Width of the Presenter frame.
        */
        function get_frame_width()
        {
            return (int)$this->presenter->framewidth;
        }

        /**
        * Gets the height of the Presenter frame (for viewing in Moodle).
        * @return int Height of the Presenter frame.
        */
        function get_frame_height()
        {
            return (int)$this->presenter->frameheight;
        }
    
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
            return SLOODLE_TYPE_PRESENTER;
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('moduletype:'.SLOODLE_TYPE_PRESENTER, 'sloodle');
        }

    }

    /**
    * Defines a single slide from a presentation, containing raw data.
    * The data will usually need to interpreted by a slide plugin.
    * @package sloodle
    */
    class SloodlePresenterSlide
    {
    // FUNCTIONS //

        // Constructor
        function SloodlePresenterSlide($id=0, $presenter=null, $name='', $source='', $type='', $ordering=0, $slideposition=0)
        {
            $this->id = $id;
            $this->presenter = $presenter;
            $this->name = $name;
            $this->source = $source;
            $this->type = $type;
            $this->ordering = $ordering;
            $this->slideposition = $slideposition;
        }

    // DATA //

        /**
        * The ID of this slide in the DB table of slides.
        * @access public
        * @var int
        */
        var $id = 0;
    
        /**
        * The SloodleModulePresenter object relating the presentation this slide is in
        * @access public
        * @var SloodleModulePresenter
        */
        var $presenter = null;

        /**
        * The name of this slide
        * @access public
        * @var string
        */
        var $name = '';

        /**
        * The source data for this slide. Normally this would be an absolute url (starting with a protocol specifier like HTTP),
        *  or a relative path, in which case it is treated as an internal Moodle file.
        * Plugins may alternatively use this to store data which is to be rendered.
        * @access public
        * @var string
        */
        var $source = '';

        /**
        * The type of this slide. This will be the ID of a plugin in the "presenter-slide" category, such as "web", "image", or "video".
        * @access public
        * @var string
        */
        var $type = '';

        /**
        * The ordering value for this slide. This should not generally be used. Refer to 'slideposition' instead.
        * @access public
        * @var integer
        */
        var $ordering = 0;

        /**
        * The position of this slide in the presentation. This is a 1-based count.
        * @access public
        * @var integer
        */
        var $slideposition = 0;

    }



?>
