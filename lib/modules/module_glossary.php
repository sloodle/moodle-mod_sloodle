<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a glossary module for Sloodle.
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
    * The Sloodle glossary module class.
    * @package sloodle
    */
    class SloodleModuleGlossary extends SloodleModule
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
        * Internal only - Moodle glossary module instance database object.
        * Corresponds to one record from the Moodle 'glossary' table.
        * @var object
        * @access private
        */
        var $moodle_glossary_instance = null;

                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleGlossary(&$_session)
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
            if (!($this->cm = get_coursemodule_from_id('glossary', $id))) {
                sloodle_debug("Failed to load course module instance #$id.<br/>");
                return false;
            }
            // Make sure the module is visible
            if ($this->cm->visible == 0) {
                sloodle_debug("Error: course module instance #$id not visible.<br/>");
                return false;
            }
            
            // Load from the primary table: glossary instance
            if (!($this->moodle_glossary_instance = sloodle_get_record('glossary', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load glossary with instance ID #{$cm->instance}.<br/>");
                return false;
            }
            
            return true;
        }
        
        
        /**
        * Searches all entries in the current glossary for the given term.
        * @param string $term The term to search for
        * @param bool $matchPartial If TRUE (default) then partial matches will be returned (e.g. 'vat' would partially match 'avatar')
        * @param bool $searchAliases If TRUE (not default) then aliases will be searched as well
        * @param bool $searchDefinitions If TRUE (not default) then definitions will be searched as well (can be SLOW, and always gets partial matches)
        * @return array An array of {@link SloodleGlossaryEntry} objects
        */
        function search($term, $matchPartial = true, $searchAliases = false, $searchDefinitions = false)
        {
            // This array will store the results associatively, ID => SloodleGlossaryDefinition
            $entries = array();
            // Get the glossary ID
            $glossaryid = (int)$this->moodle_glossary_instance->id;
            
            // Construct a query
            $sql_like = sloodle_sql_ilike();
            $termquery = "$sql_like '$term'";
            if ($matchPartial) $termquery = "$sql_like '%$term%'";
            
            // Search concepts
            $recs = sloodle_get_records_select('glossary_entries', "glossaryid = $glossaryid AND concept $termquery", 'concept');
            if (is_array($recs)) {
                foreach ($recs as $r) {
                    $entries[$r->id] = new SloodleGlossaryEntry($r->id, $r->concept, $r->definition);
                }
            }
            
            // Search aliases
            if ($searchAliases) {
                $recs = sloodle_get_records_select('glossary_alias', "alias $termquery");
                // Go through each alias found
                if (is_array($recs)) {
                    foreach ($recs as $r) {
                        // First check if we already had this entry
                        if (isset($entries[$r->entryid])) continue;
                        // Check if this alias refers to an entry in our desired glossary
                        $entry = sloodle_get_record('glossary_entries', 'glossaryid', $glossaryid, 'entryid', $r->entryid);
                        if (!$entry) continue;
                        // Store the entry
                        $entries[$entry->id] = new SloodleGlossaryEntry($entry->id, $entry->concept, $entry->definition);
                    }
                }
            }
            
            // Search definitions
            if ($searchDefinitions) {
                $recs = sloodle_get_records_select('glossary_entries', "glossaryid = $glossaryid AND definition $sql_like '%$term%'", 'concept');
                if (is_array($recs)) {
                    foreach ($recs as $r) {
                        if (!isset($entries[$r->id])) $entries[$r->id] = new SloodleGlossaryEntry($r->id, $r->concept, $r->definition);
                    }
                }
            }
            
            return $entries;
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this controller
        */
        function get_name()
        {
            return $this->moodle_glossary_instance->name;
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->moodle_glossary_instance->intro;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->moodle_glossary_instance->course;
        }
        
        /**
        * Gets the time at which this instance was created, or 0 if unknown.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return (int)$this->moodle_glossary_instance->timecreated;
        }
        
        /**
        * Gets the time at which this instance was last modified, or 0 if unknown.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return (int)$this->moodle_glossary_instance->timemodified;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'glossary';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('modulename', 'glossary');
        }

    }
    
    
    /**
    * Represents a single glossary entry
    * @package sloodle
    */
    class SloodleGlossaryEntry
    {
        /**
        * Constructor - initialises members.
        * @param mixed $id The ID of this message - type depends on VLE, but is typically an integer
        * @param string $concept The name of this entry
        * @param string $definition The definition of this entry
        */
        function SloodleGlossaryEntry($id, $concept, $definition)
        {
            $this->id = $id;
            $this->concept = $concept;
            $this->definition = $definition;
        }
        
        /**
        * Accessor - set all members in a single call.
        * @param mixed $id The ID of this message - type depends on VLE, but is typically an integer
        * @param string $concept The name of this entry
        * @param string $definition The definition of this entry
        */
        function set($id, $concept, $definition)
        {
            $this->id = $id;
            $this->concept = $concept;
            $this->definition = $definition;
        }
        
        /**
        * The ID of the entry.
        * The type depends on the VLE, but typically is an integer.
        * @var mixed
        * @access public
        */
        var $id = 0;
    
        /**
        * The name of this entry.
        * @var string
        * @access public
        */
        var $concept = '';
        
        /**
        * The definition of this entry.
        * @var string
        * @access public
        */
        var $definition = '';
    }


?>
