<?php
/**
* Defines a library class for managing SLOODLE API Plugins.
* It is constructed and used through a SloodleSession object.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
* @contributer Paul G. Preibisch (aka Fire Centaur in Second Life / Open Sim)
*/


// This library expects that the Sloodle config file has already been included
//  (along with the Moodle libraries)

/** Include the general Sloodle functionality. */
require_once(SLOODLE_DIRROOT.'/lib/general.php');


/**
* A class to load SLOODLE plugins, and provide a means to access them.
* @package sloodle
*/
class SloodleApiPluginManager
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
    * Plugin instance cache.
    * Stores the plugins which have already been created, to prevent new ones being instantiated unnecessarily.
    * Is an associative array of plugin names to plugin objects.
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
    function SloodleApiPluginManager(&$_session)
    {
        if (!is_null($_session)) $this->_session = &$_session;
    }

    /**
    * includes all files located in an api plugin folder that matches the $folder input. This ensures that we only ever
    * include files in our plugin folders, and not other misc potentially nasty files
    * @param string $folder Name of the folder we will will compare with our list of api plugin folders. 
    * If found, load api pluginsin that subfolder located in 'sloodle/plugin' . It will only load files which 
    * are directly contained inside it.
    * @return bool True if successful, or false if it fails. 
    * (It will only report failure if the folder does not exist, or there is an error accessing it.)
    */
    function get_api_plugin_path($folder){
        if (empty($folder)) return false;
        //first load the paths of all the defined plugins
        $apiDirectories= $this->sloodle_get_api_plugin_directories();
        //return false if folder specified is not in the list of our api folders
      
        //find the path to the $folder specified
        $apiPath=FALSE;
        foreach ($apiDirectories as $dir){
            if ($dir["name"]==$folder){
                $apiPath = $dir["path"]; //get include path
                 return $apiPath;
            }
        }
        return false;
       
    }
    /**
    * Return all sub directories in the /plugins 
    * @return bool false if it fails.     
    */
    
    function sloodle_get_api_plugin_directories(){
        
         $directory = SLOODLE_DIRROOT.'/plugin';
         // Open the directory
         // Make sure we have a valid directory
        if (empty($directory)) return false;
        // Open the directory
        if (!is_dir($directory)) return false;
        if (!$dh = opendir($directory)) return false;
        
        // Go through each item
        $output = array();
        while (($file = readdir($dh)) !== false) {
         $directory_list = opendir($directory);
         // and scan through the items inside
   
             // if the filepointer is not the current directory
             // or the parent directory
             if($file != '.' && $file != '..'){
                 // we build the new path to scan
                 $path = $directory.'/'.$file;
  
                 // if the path is readable
                 if(is_readable($path)){
                     // we split the new path by directories
                     $subdirectories = explode('/',$path);  
                     // if the new path is a directory
                     if(is_dir($path)){
                         // add the directory details to the file list
                         $directory_tree[] = array(
                             'path'    => $path,
                             'name'    => end($subdirectories),
                             'kind'    => 'directory');  
                             // we scan the new path by calling this function
                             //'content' => sloodle_scan_api_plugin_directory($path, $filter));
                     // if the new path is a file
                     }
                     elseif(is_file($path)){
                         // get the file extension by taking everything after the last dot
                         $extension = end(explode('.',end($subdirectories)));
                     }
                 }
             }
         }
         // close the directory
         closedir($directory_list);   
         // return file list
         return $directory_tree;
       
 }
    /**
    * Gets an array of the names of all SLOODLE api plugins derived from the specified type.
    * By default, this gets all api plugins. Specify a different base class to get others.
    * NOTE: this will search all api plugins loaded by all plugin managers in the current PHP script.
    * (There is no way to tell which manager loaded which plugins.)
    * Api Plugin names correspond to class names, with the 'SloodleApiPlugin' prefix.
    * @param string $type Name of a plugin base class.
    * @return array Numeric array of api plugin names. These names correspond to class names.
    */
    function get_plugin_names($type = 'SloodleApiPluginBase')
    {
        // We want to create an array of plugin names
        $apiPlugins = array();
		$type = strtolower($type);

        // Go through all declared classes
        $classes = get_declared_classes();
        foreach ($classes as $srcClassName) {
			// Down-case the class name for PHP4 compatibility
			$className = strtolower($srcClassName);
		
            // Make sure this is a SLOODLE plugin by checking that it starts "SloodleApiPlugin" but not "SloodleApiPluginbase"
            if (strpos($className, 'sloodleapiplugin') !== 0 || strpos($className, 'sloodleapipluginbase') === 0) continue;
            // Make sure this is not one of the supporting classes
            if ($className == 'sloodleapipluginbase' || $className == 'sloodleaplipluginmanager') continue;

            // Make sure it is in fact a plugin by ensuring it is appropriately derived from the given base plugin class
            $tempPlugin = @new $className();
            if (!is_subclass_of($tempPlugin, $type)) continue;

            // Remove the 'SloodleApiPlugin' prefix from the class name
            $className = substr($className, 16);
            $apiPlugins[] = strtolower($className);
        }

        return $apiPlugins;
    }

    /**
    * Gets an instance of the specified plugin type.
    * This only works if the api plugin has been loaded, and if it is derived from SloodleApiPluginBase.
    * @param string $name Name of the plugin type to get. If it does not start with "SloodleApiPlugin", then that is added to the start.
    * @param bool $forcenew If false (default) then a cached instance of the plugin will be returned. Set this to true to force the manager to create a new plugin instance.
    * @return object|bool An object descended from SloodleApiPluginBase if successful, or false on failure.
    */
    function get_plugin($name, $forcenew = false)
    {
		// Down-case the incoming plugin name for PHP4 compatibility
		$name = strtolower($name);
        // Prepend 'SloodlePlugin' if necessary
        if (strpos($name, 'sloodleapiplugin') !== 0) $name = 'sloodleapiplugin'.$name;
        // Make sure the specified class exists
        if (!class_exists($name)) return false;
        // Do we have a cached plugin of this type?
        if ($forcenew == false && !empty($this->plugin_cache[$name]) && is_a($this->plugin_cache[$name], $name)) return $this->plugin_cache[$name];

        // Attempt to construct an instance of the plugin
        $apiPlugin = new $name();
        // Make sure it is a valid plugin
        if (is_subclass_of($apiPlugin, 'sloodleapipluginbase')) {
            //$this->plugin_cache[$name] = $plugin;
            return $apiPlugin;
        }
        return false;
    }

}

?>
