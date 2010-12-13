<?php
// This file is part of the Sloodle project (www.sloodle.org) and is released under the GNU GPL v3.

/**
* Defines base classes for SLOODLE Presenter plugins.
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
* Base class for plugins which provide slide types for the SLOODLE Presenter.
* Sub-classes should override the essential functions, in addition to those in the SloodlePluginBase class.
* The purpose of the plugin is to render slides for output to a browser or to SL.
*
* @package sloodle
*/
class SloodlePluginBasePresenterSlide extends SloodlePluginBase
{

    // DATA //


    // OVERRIDABLE FUNCTIONS //
    // These are functions which can be overridden by sub-classes.

    /**
    * Render the given slide for browser output -- NOTE: render to a string, and return the string.
    * The title of the slide need not be included -- simply the basic iFrame or embedded player etc.
    * @param SloodlePresenterSlide $slide An object containing the raw slide data.
    * @return string
    */
    function render_slide_for_browser($slide)
    {
        // In case this function isn't overridden, just output a basic link.
        $output = "<a href=\"{$slide->source}\" title=\"\">".get_string('directlink', 'sloodle')."</a>";
        return $output;
    }

    /**
    * Render the given slide for virtual-world output.
    * This returns two items of data in a numeric array.
    * The first is the virtual world compatible type identifier: web, image, video, or audio (or a mime type).
    * The second is the absolute URL to give it.
    * @param SloodlePresenterSlide $slide An object containing the raw slide data.
    * @return array Numeric array containg (type, url)
    */
    function render_slide_for_sl($slide)
    {
        // In case this function isn't overridden, just output a basic web URL
        return array('web', $slide->source);
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
        return 'presenter-slide';
    }

}


/**
* Base class for plugins which provide slide importers for the SLOODLE Presenter.
* Sub-classes should override the essential functions, in addition to those in the SloodlePluginBase class.
* The purpose of the plugin is to take a specified file (locally), process it, and add slides to the Presentation at the given point.
*/
class SloodlePluginBasePresenterImporter extends SloodlePluginBase
{
    // DATA //


    // OVERRIDABLE FUNCTIONS //
    // These are functions which can be overridden by sub-classes.

    /**
    * Import the given file, and insert the new slides at the specified position in the Presentation.
    * The best approach to inserting slides is to insert the first one at the specified position,
    *  and then increment the position on each insertion.
    * Inserting at the same point repeatedly will cause the slides to appear in reverse order! :-)
    * @param string $file The path of the file to import.
    * @param int $position Position at which the first new slide should be imported. (If negative, then insert at end)
    * @return bool True if successful, or false otherwise.
    */
    function import($file, $position = -1)
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
        return 'presenter-importer';
    }
}


?>
