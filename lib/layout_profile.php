<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines structures for managing Sloodle layout profiles.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-2010 various contributors
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    */
    
    class SloodleLayout
    {
        var $name;
        var $id;
        var $course; // NB This is an ID of the course, not an object representing the course

        var $entries = array();
        var $originalentries = array();

        function SloodleLayout($r = null) {

            if ($r != null) {
                return $this->load_from_row($r);
            }
            return null;

        }

	// return a name for the layout, numbering based on the prefix
	function UniqueName($prefix) {

    	    for ($i=1; $i<100000; $i++) {
                 $candidate = $prefix.$i;
                 if (!$rec = get_record('sloodle_layout','name',$candidate)) {
                     return $candidate;
                 }
	    }
            return false;
	
	}

        function load_from_row($r) {

            if (!$r) return null;

            $this->name = $r->name;
            $this->id = $r->id;
            $this->course = $r->course;

            $this->originalentries = $this->get_entries($store = false);

            return true;

        }

        function load($id) {

            $rec = sloodle_get_record('sloodle_layout','id',$id); 
            if (!$rec) return null;
            $loaded = $this->load_from_row($rec);
            return true;

        }

	function populate_entries_from_active_objects() {
           $entries = $this->entries;     
           $ok = true;
	   for ($i=0; $i<count($entries); $i++) {
              $entry = $entries[$i];
              if ( (isset($entry->objectuuid)) && ($entry->objectuuid != null) && ($entry->objectuuid != '') ) {
                 $entry->populate_from_active_object();
              }
	   }
           return $ok;
	}

	function has_active_objects_rezzed_by_rezzer( $rezzeruuid ) {

		global $CFG;
		$rezzeruuid = addslashes($rezzeruuid);
		$layoutid = intval($this->id);
		$select = "select count(*) as cnt from {$CFG->prefix}sloodle_active_object a inner join {$CFG->prefix}sloodle_layout_entry le on a.layoutentryid=le.id where a.rezzeruuid='$rezzeruuid' and le.layout=$layoutid";
		$recs = get_records_sql( $select );
		if (!$recs) {
			return false;
		}
		$rec = array_pop($recs);
		$cnt = $rec->cnt;
		return ( $cnt > 0 );

        }

	function rezzed_active_objects( $rezzeruuid = null ) {

		global $CFG;

		$layoutid = intval($this->id);
		$select = "select a.* from {$CFG->prefix}sloodle_active_object a inner join {$CFG->prefix}sloodle_layout_entry le on a.layoutentryid=le.id where le.layout=$layoutid";
		if ($rezzeruuid) {
			$rezzeruuid = addslashes($rezzeruuid);
			$select .= " and rezzeruuid='$rezzeruuid'";
		}
		$recs = get_records_sql( $select );
		if (!$recs) {
			return false;
		}

		$aos = array();
		foreach($recs as $rec) {
			$ao = new SloodleActiveObject();
			$ao->loadFromRecord($rec);
			$aos[] = $ao;
		}
	
		return $aos;

	}

	// return a has of rezzed objects with the layout entry id as the key
	function rezzed_active_objects_by_layout_entry_id( $rezzeruuid = null ) {

		$aos = $this->rezzed_active_objects( $rezzeruuid );
		$aohash = array();
		foreach($aos as $ao) {
			$leid = $ao->layoutentryid;
			if (!isset($aohash[ $leid ])) {
				$aohash[ $leid ] = array();
			} 
			$aohash[ $leid ][] = $ao;
		}
		return $aohash;

	}

        function get_sloodle_course() {

            $course = new SloodleCourse();
            if ($course->load($this->course)) {
                return $course;
            }
            return null;

        }

        function get_course() {

            return sloodle_get_record('course','id',$this->course);

        }

        // return a set of SloodleLayoutEntry objects for the layout.
 	// store parameter indicates whether they should be stored as instance variables.
	// set $store=false if you're planning to update the object entries and you're only reading them in so the object will know what is already there and what to insert and delete.
        function get_entries($store = true) {

            $rows = sloodle_get_records('sloodle_layout_entry','layout',$this->id);
            $entries = array();
            if ($rows && ( count($rows) > 0) ) {
               foreach($rows as $row) {
                  $entries[] = new SloodleLayoutEntry($row);
               }
            }

            if ($store) {
               $this->entries = $entries;
            }

//print "<h4>layout.get_entries returning ".count($entries)."entries</h4>";
            return $entries;

        }

        function add_entry($entry) {

           $entries = $this->entries;
           $entries[] = $entry;
           $this->entries = $entries;

        }

        function insert() {

            $this->id = sloodle_insert_record('sloodle_layout', $this);
            $this->save_entries();
            return $this->id;

        }

        function update() {

            if (!sloodle_update_record('sloodle_layout', $this)) {
               return false;
            }
            return $this->save_entries();

        }

        function delete() {

            $this->delete_entries();
            if (!delete_records('sloodle_layout', 'id', $this->id)) {
               return false;
            }
            return true;

        }

	function delete_entries() {

            $this->entries = array();
            $this->save_entries();

	}

	function save_clone( $name ) {

            $clone = new SloodleLayout();
            $clone->name = $name;
            $clone->course = $this->course;
            if (!$cloneid = insert_record('sloodle_layout', $clone)) {
                return false;
            }
	    $clone->id = $cloneid;
            $clone->entries = array();
            foreach($this->originalentries as $entry) {
	        $cloneentry =  ( version_compare(phpversion(), '5.0') ) ? clone($entry) : $entry;
                $cloneentry->id = null; 
                $clone->entries[] = $cloneentry;
            }
            $clone->save_entries();
            return $cloneid; 
	
	}

        function save_entries() {

            $neededids = array();
            foreach($this->entries as $entry) {
               $entry->layout = $this->id;
               if (!$entry->id) {
                  $entry->id = $entry->insert();
               } else {
                  $entry->update();
               }
               $neededids[] = $entry->id;
            }

	    if (count($this->originalentries) > 0) {
               foreach($this->originalentries as $entry) {
                  $entryid = $entry->id;
                  if (!in_array($entryid,$neededids)) {
                     $entry->delete();
                  }
               }
	    }

           return true;

        }

    }
    
    /**
    * Stores data for a single entry in a layout profile.
    * Used with {@link SloodleCourse}
    * @package sloodle
    */
    class SloodleLayoutEntry
    {
    // DATA //
    
        /**
        * The name of the object this entry represents.
        * @var string
        * @access public
        */
        var $name = '';
        
        /**
        * The position of the object, as a 3d vector, in string format "<x,y,z>"
        * @var string
        * @access public
        */
        var $position = '<0.0,0.0,0.0>';
        
        /**
        * The rotation of the object, as a 3d vector of Euler angles, in string format "<x,y,z>"
        * @var string
        * @access public
        */
        var $rotation = '<0.0,0.0,0.0>';

        var $id;
        var $layout;
        var $configs;
        var $originalconfigs;
      
        function SloodleLayoutEntry($r = null) {

             if ($r != null) {
                return $this->load_from_row($r);
             }

             return true;

        }

	// returns an objectconfig object for the tool, based on the name of the entry
	// returns null if it can't find one.
	function get_object_config() {
		
             if ( !$name = $this->name ) {
                 return null;
             }
             return SloodleObjectConfig::ForObjectName( $name );

	}

        function load_from_row($r) {

            if (!$r) return null;

            $this->name = $r->name;
            $this->position = $r->position;
            $this->rotation = $r->rotation;
            $this->id = $r->id;
            $this->layout = $r->layout;
            if (isset($r->objectuuid)) {
                $this->objectuuid = $r->objectuuid; // not saved - just used to populate defaults
            }

            $this->configs = $this->get_layout_entry_configs();
            $this->originalconfigs = $this->configs; // save the original configs so we know what to delete, what to update and what to add

            return true;

        }

        function load($id) {

	    $rec = sloodle_get_record('sloodle_layout_entry', 'id', $id);
            if (!$rec) return null;
            return $this->load_from_row($rec);
            
        }

	function populate_from_active_object() {

           if (!$objectuuid = $this->objectuuid) {
              return false;
           }

           $object = sloodle_get_record('sloodle_active_object','uuid',$this->objectuuid); 
           $object_id = $object->id;
           if (!$object_id) return false;

           $configs = sloodle_get_records('sloodle_object_config','object',$object_id); 
           foreach($configs as $config) {
              $this->set_config($config->name,$config->value);
           }

           return true;
           
       	}

        function get_layout() {

            if ($this->layout != null) {

               $layout = new SloodleLayout();
               if ( $layout->load($this->layout) ) {
                   return $layout;
               }

            }
            return null;
        }

	/**
        * Return an array of layout_entry_config objects
        * @param integer $layout_entry_id The ID of the layout entry
        * @return array Array if successful (empty if there are no entries) , or null otherwise
        */
	function get_layout_entry_configs() {
            
	    $recs = sloodle_get_records('sloodle_layout_entry_config', 'layout_entry', $this->id);
            if (!$recs) return null;
            
            // Construct the array of SloodleLayoutEntry objects
            $entryconfigs = array();
            foreach ($recs as $r) {
                $entryconfigs[] = new SloodleLayoutEntryConfig($r);
            } 
            return $entryconfigs;

	}

        function get_layout_entry_configs_as_hidden_fields($prefix, $suffix) {
           
           $str = '';
           foreach($this->get_layout_entry_configs_as_name_value_hash() as $n=>$v) {
              $fieldname = $prefix.$n.$suffix;
              $str .= '<input type="hidden" name="'.$fieldname.'" value="'.$v.'" />';
           }
           return $str;

	}

 	function get_layout_entry_configs_as_name_value_hash() {

	    $objs = $this->get_layout_entry_configs();
            $configs = array();
            if (count($objs) > 0) {
               foreach($objs as $obj) {
                  $configs[$obj->name] = $obj->value;
               }
            }
            return $configs;

	}

        /**
        * Sets the position as separate X,Y,Z components
        * @param float $x The X component to set
        * @param float $y The Y component to set
        * @param float $z The Z component to set
        * @return void
        */
        function set_position_xyz($x, $y, $z)
        {
            $this->position = "<$x,$y,$z>";
        }
        
        /**
        * Sets the rotation as separate X,Y,Z components
        * @param float $x The X component to set
        * @param float $y The Y component to set
        * @param float $z The Z component to set
        * @return void
        */
        function set_rotation_xyz($x, $y, $z)
        {
            $this->rotation = "<$x,$y,$z>";
        }
        
	function get_config($name) {
            $configs = $this->get_layout_entry_configs_as_name_value_hash();
            if (!isset($configs[$name])) {
                return null;
            }
            return $configs[$name];
	}

        function set_config($name, $value) { // add config with given name/value, overwriting if necessary
            $configs = $this->configs;
            $done = false;
            if ( is_array($configs) ) {
                for( $i=0; $i<count($configs); $i++) {
                    $config = $configs[$i];
                    if ($config->name == $name) {
                         $config->value = $value;
                         $configs[$i] = $config;
                         $done = true;
                    }
                }  
            } else {
                $configs = array();
            }
            if (!$done) {
                $config = new SloodleLayoutEntryConfig();
                $config->layout_entry = $this->id;
                $config->name = $name;
                $config->value = $value;
                $configs[] = $config;
            }
            $this->configs = $configs;

        }

        function insert() {

            $this->id = sloodle_insert_record('sloodle_layout_entry', $this);
            if (!$this->id) {
               return false;
            }
            if ( $this->save_configs() ) {
		return $this->id;
	    }

        }

        function update() {

            if (!sloodle_update_record('sloodle_layout_entry', $this)) {
               return false;
            }
            return $this->save_configs();

        }

        function delete() {

           if (!$this->id) return false;

           if (!$this->delete_configs()) {
              return false;
           }           

           $result = sloodle_delete_records('sloodle_layout_entry', 'id', $this->id);
           return $result;

        }

        function delete_configs() {

            return sloodle_delete_records('sloodle_layout_entry_config', 'layout_entry', $this->id);

        }

        function save_configs() {

 	    if (count($this->configs) == 0) {
 	       return true;
	    }

            foreach($this->configs as $config) {
               $config->layout_entry = $this->id; 

               if (!$config->id) {
                  $entry_id = $config->insert();
               } else {
                  $config->update();
               }
            }

            return true;

        }

	function active_objects() {
            $recs = get_records('sloodle_active_object','layout_entry',intval($this->id));

            $aos = array();
            if ($rec) {
		foreach($recs as $rec) {
                    $ao = new SloodleActiveObject();
                    $ao->loadFromRecord($rec);
                    $aos[] = $ao;
		}
            }
            return $aos;

	}

        // returns an instance of SloodleLayoutEntry with the default config for an object with the specified name
	// is_dummy means we have a non-sloodle object with no particular fields.
        function ForConfig( $name, $is_dummy = false ) {
            if ($is_dummy) {
		    if ( !$obj = SloodleObjectConfig::ForNonSloodleObjectWithName( $name ) ) {
			return null;
		    }
	    } else {
		    if ( !$obj = SloodleObjectConfig::ForObjectName( $name ) ) {
			return null;
		    }
	    }
            $le = new SloodleLayoutEntry();
            $le->name = $name;        
            foreach( $obj->field_sets as $grp ) {
                 foreach($grp as $n => $op) {
                     $le->set_config($n, $op->default);
                 }
            }
            return $le;
        }

	function objectDefinition() {
            return SloodleObjectConfig::ForObjectName( $this->name );
	}

        function get_course_module_instance() {
	    if (!$defn = $this->objectDefinition() ) {
                return null;
            }
            if (!$modtype = $defn->module) {
                return null;
            }
            if (!$sloodlemoduleid = intval($this->get_config('sloodlemoduleid'))){
                return null;
            }
            if (!$cm = get_record('course_modules', 'id', $sloodlemoduleid)) {
                return null;
            }
            if (!$inst = get_record($modtype, 'id', $cm->instance)) {
	        return null;
            }
            return $inst;
        }
	function get_course_module_title() {
            if (!$inst = $this->get_course_module_instance()) {
                return null;
            }
            return $inst->name;
	}

    }

    class SloodleLayoutEntryConfig
    {

        var $id;
        var $layout_entry;
        var $name;
        var $value;

        function SloodleLayoutEntryConfig($row = null) {

            if ($row != null) {
                return $this->load_from_row($row);
            }

            return null;

        }

        function load_from_row($row) {

            if (!$row) return null;

            $this->id = $row->id;
            $this->layout_entry = $row->layout_entry;
            $this->name = $row->name;
            $this->value = $row->value;

        }

        function load($id) {
	    $rec = sloodle_get_record('sloodle_layout_entry_config', 'id', $id);
            if (!$rec) return null;
            return $this->load_from_row($rec);
        }

        function insert() {

            return $this->id = sloodle_insert_record('sloodle_layout_entry_config', $this);

        }

        function update() {

            return sloodle_update_record('sloodle_layout_entry_config', $this);

        }

    }
?>
