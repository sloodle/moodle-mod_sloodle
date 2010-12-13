<?php
// This file is part of the Sloodle project (www.sloodle.org) and is released under the GNU GPL v3.

/**
* Defines the SLOODLE Presenter plugin for showing video slides.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @since Sloodle 0.4.1
*
* @contributor Peter R. Bloomfield
* @contributor dz questi (YouTube link conversion)
*
*/


/**
* Presenter plugin for showing video slides.
*
* @package sloodle
*/
class SloodlePluginPresenterSlideVideo extends SloodlePluginBasePresenterSlide
{
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
        return 'video';
    }


    /**
    * Construct an absolute URL, based on the given source data.
    * Leaves existing absolute URLs alone, but converts relative URLs as necessary.
    * (This allows the site to be moved without disrupting these slides.)
    * @param string $source The source data from the slide.
    * @return string An absolute URL.
    */
    function get_absolute_url($source)
    {
        global $CFG;
        // If we have a protocol specifier, then assume this is already an absolute URL
        if (strpos($source, '://') !== false) return $source;
        // Assume the source URL is relative to the Moodle WWW root.
        // Make sure we don't duplicate a forward slash.
        if (strpos($source, '/') === 0) return $CFG->wwwroot.$source;
        return $CFG->wwwroot.'/'.$source;
    }

    /**
    * Render the given slide for browser output -- NOTE: render to a string, and return the string.
    * The title of the slide need not be included -- simply the basic iFrame or embedded player etc.
    * @param SloodlePresenterSlide $slide An object containing the raw slide data.
    * @return string
    */
    function render_slide_for_browser($slide)
    {
        $url = $this->get_absolute_url($slide->source);
        $framewidth = 500;
        $frameheight = 500;
        if (isset($this->presenter)) {
            $framewidth = $this->presenter->get_frame_width();
            $frameheight = $this->presenter->get_frame_height();
        }
        
        // Check to see if we can use a proper embedded player from a video sharing site
        if (strpos($url, '://www.youtube.com') !== false || strpos($url, '://youtube.com') !== false) {
            // Embed a YouTube player
            $index = strpos($url, 'v=');
            $vidid = substr($url, $index + 2, 11);
            $output = <<<XXXEODXXX
<object width="{$framewidth}" height="{$frameheight}">
 <param name="movie" value="http://www.youtube.com/v/{$vidid}"></param>
 <param name="allowFullScreen" value="true"></param>
 <param name="allowscriptaccess" value="always"></param>
 <embed src="http://www.youtube.com/v/{$vidid}" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="{$framewidth}" height="{$frameheight}"></embed>
</object>
XXXEODXXX;
        } else {
            // Just embed the video normally
            $output = "<embed src=\"{$url}\" align=\"center\" autoplay=\"true\" controller=\"true\" width=\"{$framewidth}\" height=\"{$frameheight}\" scale=\"aspect\" />";
        }

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
        $url = $this->get_absolute_url($slide->source);
        $type = 'video/*';
        
        // Check to see if we need to convert the video URL for video-sharing sites
        if (strpos($url, '://www.youtube.com') !== false || strpos($url, '://youtube.com') !== false) {
            $index = strpos($url, 'v=');
            $vidid = substr($url, $index + 2, 11);
            $url = "http://www.youtubemp4.com/video/".$vidid.".mp4";
            $type = "video/mp4";
        }

        return array($type, $url);
    }

    /**
    * Gets the human-readable name of this plugin.
    * This MUST be overridden by base classes. If not, it will just return the name of the class.
    * @param string $lang Optional -- can specify the language we want the plugin name in, as an identifier like "en_utf8". If unspecified, then the current Moodle language should be used.
    * @access public
    * @return string The human-readable name of this plugin 
    */
    function get_plugin_name($lang = null)
    {
        return 'Video';
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
        return 2009050600;
    }


}


?>
