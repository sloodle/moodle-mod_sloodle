<?php

    /**
    * Sloodle Presenter linker.
    * Allows a Sloodle Presenter object in-world to request a list of entries for a presentation.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = ID of a presenter
    //
    // The following parameter is optional:
    //  sloodleslidenum = the number of a slide within a presentation (this is a 1 based number, so 1 is the first slide, 2 is the second, and so on)
    //
    // Status code 1 will be returned on success of any request.
    // The first line will always contain the following data:
    //
    //  num_slides|name
    //
    // "name" is the name of the presentation, and "num_slides" is the total number of slides currently in the presentation.
    // The second data line will contain data about a particular slide in the presentation, as follows:
    //
    //  num|type|source|name
    //
    // num = the number of slide within the presentation, starting at 1
    // type = the mimetype of the slide, such as "video/*"
    // source = the source of the slide, which will usually be a URL (although we might use it for other things later)
    // name = the name of the slide
    //
    // By default, the first slide's data will always be returned.
    // However, by including the "sloodleslidenum" parameter in the request, a specific slide can be requested.i
    //
    // In the event that the Presenter plugins fail to load at all, the response will be status code -131.
    // If the presentation is empty (no slides at all) then the response will be status code -10501.
    // If a particular slide's plugin cannot be loaded, then the main status code will still be 1 and the basic presenter data will be given. But there will be side effect code -132, and the 'type' field for the slide will say 'ERROR'. (This allows the presentation to continue to work -- the specific slide can simply be skipped.)
    //
    // Future modifications may include:
    //  - text-based display in SL
    //  - UUID-based texture or object loading in SL
    //  - aspect ratio specified for each slide
    //
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, and load a slideshow module
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->load_module(SLOODLE_TYPE_PRESENTER, true);

    // Load the necessary Presenter plugins
    sloodle_debug("Loading Presenter plugins\n");
    if (!$sloodle->plugins->load_plugins('presenter')) {
        $sloodle->response->quick_output(-131, 'PLUGIN', 'Failed to load any SLOODLE Presenter plugins. Please check your "sloodle/plugin" folder.', false);
        exit();
    }

    // Get all the slides in this presentation
    $slides = $sloodle->module->get_slides();
    if (!is_array($slides) || count($slides) == 0) {
        $sloodle->response->quick_output(-10501, 'PRESENTER', 'There are no slides in this presentation', false);
        exit();
    }
    $numslides = count($slides);
  
    // Has a particular slide been requested?
    $sloodleslidenum = (int)$sloodle->request->optional_param('sloodleslidenum', 0);
    if ($sloodleslidenum < 1 || $sloodleslidenum > $numslides) $sloodleslidenum = 1;
    
    // Figure out which slide we are going to output
    $outputslide = null;
    $curslidenum = 1;
    foreach ($slides as $curslide) {
        // If this is the current slide we are after, then output it
        if ($curslidenum == $sloodleslidenum) {
            $outputslide = $curslide;
            break;
        }
        $curslidenum++;
    }


    // Output the basic presenter information
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    $sloodle->response->add_data_line(array($numslides, sloodle_clean_for_output($sloodle->module->get_name())));
    
    // Our plugin data will be store in these variables
    $slidetype = ''; $slidesource = '';
    // Attempt to load the plugin required by our current slide
    sloodle_debug("Attempting to load plugin \"{$outputslide->type}\"...");
    $slideplugin = $sloodle->plugins->get_plugin('presenter-slide', $outputslide->type);
    if ($slideplugin === false) {
        // Indicate the error as a side effect, and specify the type as an error
        sloodle_debug("Failed to load Presenter slide plugin.\n");
        $sloodle->response->add_side_effect(-132);
        $slidetype = 'ERROR';
        $slidesource = '';
    } else {
        // Load the slide data from the plugin
        sloodle_debug("Loaded plugin OK\n");
        list($slidetype, $slidesource) = $slideplugin->render_slide_for_sl($outputslide);
    }

    // Output the slide data
    $sloodle->response->add_data_line(array($sloodleslidenum, sloodle_clean_for_output($slidetype), sloodle_clean_for_output($slidesource), sloodle_clean_for_output($outputslide->name)));
    $sloodle->response->render_to_output();
    exit();

?>
