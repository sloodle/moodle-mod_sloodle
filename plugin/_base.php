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
class SloodlePluginBase
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
    * This function MUST be overridden by sub-classes to return an ID that is unique to the category.
    * It is possible to have different plugins of the same ID in different categories.
    * This function is given a very explicitly sloodley name as it lets us ignore any classes which don't declare it.
    * @access public
    * @return string|bool The ID of this plugin, or boolean false if this is a base class and should not be instantiated as a plugin.
    */
    function sloodle_get_plugin_id()
    {
        return false;
    }
    
    /**
    * Gets the category to which this plugin belongs.
    * For example, Presenters have two plugin categories: slides, and importers.
    * This function must be overriden.
    * A useful approach would be to have a derived plugin base class for a particular category of plugins.
    * Each derived base class would report the appropriate category by overriding this function.
    * The actual plugin classes would simply have to inherit that derived base, without needing to specify their own category.
    * @access public
    * @return string The name of this category of plugin.
    */
    function get_category()
    {
        return 'base';
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
    
    /**
    * After check_compatibility() has been called, this function will return a string summarising the compatibility of the plugin.
    * For example, it may explain that a particular extension is being used, or that it could not be loaded.
    * @return string A summary of the compatibility of the plugin.
    */
    function get_compatibility_summary()
    {
        return '';
    }
    
    /**
    * Run a full compatibility test and output the results to the webpage.
    * @return void
    */
    function run_compatibility_test()
    {
        return get_string('nocompatibilityproblems', 'sloodle');
    }

}


?>
