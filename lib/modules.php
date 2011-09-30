<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file brings all of the Sloodle module classes together.
    * It also provides functionality to create and load different module types.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    
    /** Base module. */
    require_once(SLOODLE_LIBROOT.'/modules/module_base.php');
    require_once(SLOODLE_LIBROOT.'/general.php');

    
    // Now we will go through every file in the "lib/modules" folder which starts "module_", and include it.
    $MODULESPATH = SLOODLE_LIBROOT.'/modules';
    $modulefiles = sloodle_get_files($MODULESPATH, true);
    // Go through each file
    if (is_array($modulefiles)) {
    	foreach ($modulefiles as $mf) {
    		// Does this filename start with "module_" and end with ".php"?
    		if (strcasecmp(substr($mf, 0, 7), 'module_') == 0 && strcasecmp(substr($mf, -4), '.php') == 0) {
    			// Yes - include it
    			include_once($MODULESPATH.'/'.$mf);
    		}
    	}
    }
    
    // We will store an associative array of module types to module class names
    // e.g. { 'chat'=>'SloodleModuleChat', 'distributor'=>'SloodleModuleDistributor', ...}
    global $SLOODLE_MODULE_CLASS;
    $SLOODLE_MODULE_CLASS = array();
    // Go through each declared class
    $allclasses = get_declared_classes();
    foreach ($allclasses as $c) {
        // Is this class a subclass of the Sloodle Module type?
        if (strcasecmp(get_parent_class($c), 'SloodleModule') == 0) {
            // Fetch the type name
            $curtype = call_user_func(array($c, 'get_type'));
            if (!empty($curtype)) {
                // Add it to our array with its type
                $SLOODLE_MODULE_CLASS[$curtype] = $c;
            }
        }
    }

    /*
    Static method to return a list of available module types => module names.
    Avoids having to use the global variable elsewhere.
    */
    function sloodle_available_modules() {
        global $SLOODLE_MODULE_CLASS;
        return $SLOODLE_MODULE_CLASS;
    }
    
    
    /**
    * Constructs a appropriate Sloodle module object based on the named type.
    * @param string $type The type of module to construct - typically a short name, such as 'chat' or 'blog'
    * @param SloodleSession &$_session The {@link SloodleSession} object to pass to the module on construction, or just null
    * @param mixed $id The identifier of the module instance to load from the database (or null if there is no module data)
    * @return SloodleModule|bool Returns the cosntructed module object, or false if it fails
    */
    function sloodle_load_module($type, &$_session, $id = null)
    {
        global $SLOODLE_MODULE_CLASS;
        
        // Abort if the type is not recognised
        if (!array_key_exists($type, $SLOODLE_MODULE_CLASS)) {
            sloodle_debug("Module load failed - type \"$type\" not recognised.<br/>");
            return false;
        }
        // Construct the object, based on the class name in our array
        $module = new $SLOODLE_MODULE_CLASS[$type]($_session);
        
        // Load the data from the database, if necessary
        if ($id != null) {
            if ($module->load((int)$id)) return $module;
            sloodle_debug("Failed to load module data from database with ID $id.<br/>");
            return false;
        }
        
        // Everything seems OK
        return $module;
    }
    
    /**
    * Constructs and loads an appropriate SLOODLE module object, based on the 'sloodle' record (that is, the instance or instance ID).
    * The appropriate type is detected from the instance data.
    * The object is provided with a dummy SloodleSession object.
    * @param int|object $instance Either an integer instance ID, or a record from the 'sloodle' table.
    * @return SloodleModule|bool Returns the constructed module object, or false if it fails.
    */
    function sloodle_quick_load_module_from_instance($instance)
    {
        // Get an instance record if necessary
        if (is_numeric($instance)) {
            $instance = sloodle_get_record('sloodle', 'id', (int)$instance);
            if ($instance === false) return false;
        }
        
        // Attempt to get the course module ID
        $cm = get_coursemodule_from_instance('sloodle', $instance->id);
        if ($cm === false) return false;
        
        // Attempt to load the module
        $dummysession = new SloodleSession(false);
        return sloodle_load_module($instance->type, $dummysession, (int)$cm->id);
    }
    
    /**
    * Constructs and loads an appropriate SLOODLE module object, based on the course module or course module ID.
    * The appropriate type is detected automatically.
    * The object is provided with a dummy SloodleSession object.
    * @param int|object $cm Either an integer course module ID, or a course module record.
    * @return SloodleModule|bool Returns the constructed module object, or false if it fails.
    */
    function sloodle_quick_load_module_from_cm($cm)
    {
        // Obtain a course module object if necessary
        if (is_numeric($cm)) {
            $cm = get_coursemodule_from_id('sloodle', $cm);
            if ($cm === false) return false;
        }
    
        // Get an instance record
        $instance = sloodle_get_record('sloodle', 'id', (int)$cm->instance);
        if ($instance === false) return false;
        
        // Attempt to load the module
        $dummysession = new SloodleSession(false);
        return sloodle_load_module($instance->type, $dummysession, (int)$cm->id);
    }

?>
