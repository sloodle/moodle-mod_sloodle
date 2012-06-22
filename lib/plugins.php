<?php
/**
* Defines a library class for managing SLOODLE Plugins.
* It is constructed and used through a SloodleSession object.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/


// This library expects that the Sloodle config file has already been included
//  (along with the Moodle libraries)

/** Include the general Sloodle functionality. */
require_once(SLOODLE_DIRROOT.'/lib/general.php');


/**
* A class to load SLOODLE plugins, and provide a means to access them.
* @package sloodle
*/
class SloodlePluginManager
{
// DATA //

    /**
    * Internal only - reference to the containing {@link SloodleSession} object.
    * Note: always check that it is not null before use!
    * @var object
    * @access protected
    */
    var $_session = null;
    
    /**
    * 2d array of plugin class names.
    * The top level key gives the lower-case plugin category name, and the second level key gives the lower-case plugin ID. The value gives the name of the associated class.
    * This list exists to ensure compatibility with the different ways class name casing is handled on different platform configurations.
    * @var array
    * @access protected
    */
    var $plugin_class_names = array();

    /**
    * Plugin instance cache.
    * Stores the plugins which have already been created, to prevent new ones being instantiated unnecessarily.
    * Has the same 2d structure as $plugin_class_names, except the values are objects not class names.
    * i.e.: $plugin_cache['presenter-slide']['image'] = pluginobject;
    * @var array
    * @access protected
    */
    var $plugin_cache = array();

    
// FUNCTIONS //

    /**
    * Class constructor.
    * @param object &$_session Reference to the containing {@link SloodleSession} object, if available.
    * @access public
    */
    function SloodlePluginManager(&$_session)
    {
        if (!is_null($_session)) $this->_session = &$_session;
    }

    /**
    * Loads all available plugins from the specified folder.
    * @param string $folder Name of the folder to load plugins from. This is a sub-folder of the 'sloodle/plugin' folder. It will only load files which are directly contained inside it.
    * @return bool True if successful, or false if it fails. (It will only report failure if the folder does not exist, or there is an error accessing it.)
    */
    function load_plugins($folder)
    {
        if (empty($folder)) return false;

        // Get a list of all the files in the specified folder
        $pluginFolder = SLOODLE_DIRROOT.'/plugin/'.$folder;
        $files = sloodle_get_files($pluginFolder, true);
        if (!$files) return false;
        if (count($files) == 0) return true;

        // Start by including the relevant base class files, if they are available
        @include_once(SLOODLE_DIRROOT.'/plugin/_base.php');
        @include_once($pluginFolder.'/_base.php');

        // Go through each filename
        foreach ($files as $file) {
            // Include the specified file
            // Skip things that are usually backups etc.
            // Skip .files
            if (preg_match('/^\./', $file)) {
                continue;
            }
            // Skip non-php files
            if (!preg_match('/\.php$/', $file)) {
                continue;
            }
            include_once($pluginFolder.'/'.$file);
        }
        
        // Build a complete list of plugin class names
        $this->plugin_class_names = array();
        $allclasses = get_declared_classes();
        foreach ($allclasses as $c) {
            // Attempt to get the plugin ID.
            // If this operation fails, then the class is not a SLOODLE plugin.
            $pluginid = @call_user_func(array($c,'sloodle_get_plugin_id'));
            if (empty($pluginid)) continue;
            // Attempt to get the plugin category
            $plugincat = @call_user_func(array($c,'get_category'));
            if (empty($plugincat)) $plugincat = '';
            
            // Store the class name
            $this->plugin_class_names[strtolower($plugincat)][strtolower($pluginid)] = $c;
        }

        return true;
    }
    
    /**
    * Dummy function included for error checking.
    */
    function get_plugin_names($type = '')
    {
        exit("***** Call to \"get_plugin_names\". This function is no longer valid. Please edit the code. *****");
    }
    
    /**
    * Gets an array of the names of all SLOODLE plugins, optionally filtered to a specific category.
    * Plugin categories are reported by the plugin classes themselves.
    * NOTE: this will search all plugins loaded by all plugin managers in the current PHP execution.
    * (There is no way to tell which manager loaded which plugins.)
    * @param string $category If it is a string, it specifies the name of a category of plugins to get. If null (default) then it is ignored.
    * @return array Numeric array of plugin IDs. Will return an empty array if no matching plugins have been loaded.
    */
    function get_plugin_ids($category = null)
    {
        // Create an array to store our list of plugin IDs
        $plugins = array();
		// Has a particular category been provided?
        if (is_string($category))
        {
            // Down-case the category name for compatibility
            $category = strtolower($category);
            if (!is_array($this->plugin_class_names[$category])) return $plugins;
            
            // Fetch each plugin ID in this category
            foreach ($this->plugin_class_names[$category] as $pluginid => $pluginclass) {
                // Add the ID to our array
                $plugins[] = $pluginid;
            }
        } else {
            // Go through each category of plugins
            foreach ($this->plugin_class_names as $cat)
            {
                // Go through each plugin in this category
                foreach ($cat as $pluginid => $pluginclass) {
                    // Add the ID to our array
                    $plugins[] = $pluginid;
                }
            }
        }

        return $plugins;
    }
    
    /**
    * Gets an array of the names of all SLOODLE plugin categories.
    * Plugin categories are reported by the plugin classes themselves.
    * NOTE: this will search all plugins loaded by all plugin managers in the current PHP execution.
    * (There is no way to tell which manager loaded which plugins.)
    * @return array Numeric array of plugin IDs. Will return an empty array if no matching plugins have been loaded.
    */
    function get_plugin_categories()
    {
        // Create an array to store our list of plugin IDs
        $plugincats = array();
        if (!is_array($this->plugin_class_names)) return $plugincats;
        // Go through each category of plugins and add it to our list
        foreach ($this->plugin_class_names as $catname => $plugins)
        {
            $plugincats[] = $catname;
        }

        return $plugincats;
    }

    /**
    * Gets an instance of the specified plugin.
    * This only works if the plugin has already been loaded.
    * @param string $plugincat Name of the plugin category we are loading from.
    * @param string $pluginid ID of the plugin type to get.
    * @param bool $forcenew If false (default) then a cached instance of the plugin will be returned. Set this to true to force the manager to create a new plugin instance.
    * @return object|bool A suitable plugin object instance if successful, or false on failure.
    */
    function get_plugin($plugincat, $pluginid, $forcenew = false)
    {
		// Down-case the incoming category and ID for compatibility
        $plugincat = strtolower($plugincat);
		$pluginid = strtolower($pluginid);
        
        // Attempt to retrieve the name of the plugin class, and make sure it exists
        if (empty($this->plugin_class_names[$plugincat][$pluginid])) return false;
        $classname = $this->plugin_class_names[$plugincat][$pluginid];
        if (!class_exists($classname)) return false;
        
        // Return a cached instance if possible, or create a new one if necessary
        if ($forcenew == false && !empty($this->plugin_cache[$plugincat][$pluginid]) && is_a($this->plugin_cache[$plugincat][$pluginid], $classname)) return $this->plugin_cache[$plugincat][$pluginid];
        $plugin = new $classname();
        if (empty($this->plugin_cache[$plugincat][$pluginid])) $this->plugin_cache[$plugincat][$pluginid] = $plugin;
        return $plugin;
    }

}

?>
