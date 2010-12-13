<?php
// This file is part of the Sloodle project (www.sloodle.org) and is released under the GNU GPL v3.

/**
* Defines the base class for all SLOODLE Plugins.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @since Sloodle 0.4.1
*
* @contributor Peter R. Bloomfield
*
*/




/**
* Base class for all SLOODLE plugins.
* All SLOODLE plugins should be derived from this (directly or indirectly).
* Specific plugin types will likely have their own base classes, which should be sub-classes of this.
* For example, the Presenter has plugin base classes for "slide" and "import" plugins.
* New plugins should be derived directly from those.
*
* Plugin classes should have names starting with "SloodlePlugin".
* Make sure your class name does not conflict with any existing plugin classes, even if it is a different type of plugin.
* Instantiating a plugin class should require no parameters, and should perform minimal processing. This is to allow the plugin loader to be as efficient as possible.
*
* @package sloodle
*/
class SloodleApiPluginBase
{

    // DATA //


    // OVERRIDABLE FUNCTIONS //
    // These are functions which can be overridden by sub-classes.

    /**
    * Gets the human-readable name of this plugin.
    * This MUST be overridden by base classes. If not, it will just return the name of the class.
    * @param string $lang Optional -- can specify the language we want the plugin name in, as an identifier like "en_utf8". If unspecified, then the current Moodle language should be used.
    * @access public
    * @return string The human-readable name of this plugin 
    */
    function get_plugin_name($lang = null)
    {
        return strtolower(get_class($this));
    }

    /**
    * Gets the human-readable description of this plugin.
    * This should be overridden by base classes. If not, it will just return an empty string.
    * @param string $lang Optional -- can specify the language we want the description in, as an identifier like "en_utf8". If unspecified, then the current Moodle language should be used.
    * @access public
    * @return string The human-readable description of this plugin
    */
    function get_plugin_description($lang = null)
    {
        return '';
    }

    /**
    * Gets the identifier of this plugin.
    * This can be overridden, but should usually not be.
    * This ID is just the name of the class in LOWER CASE (for PHP4 compatibility).
    */
    function get_id()
    {
        $className = strtolower(get_class($this));
        if (strpos($className, 'sloodleapiplugin') === 0) return substr($className, 16);
        return $className;
    }

    /**
    * Gets the internal version number of this plugin.
    * This MUST be overridden.
    * This should be a number like the internal version number for Moodle modules, containing the date and release number.
    * Format is: YYYYMMDD##.
    * For example, "2009012302" would be the 3rd release on the 23rd January 2009.
    * @return int The version number of this module.
    */
    function get_version()
    {
        return 0;
    }

    /**
    * Checks the compatibility of this plugin with the current installation.
    * Override this for any plugin which has non-standard requirements, such as relying on particular PHP extensions.
    * Note that the default (base class) implementation of this function returns true.
    * @return bool True if plugin is compatible, or false if not.
    */
    function check_compatibility()
    {
        return true;
    }

}


?>
