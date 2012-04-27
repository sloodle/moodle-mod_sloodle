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
    // Status code 1 will be returned on success.
    // Each data line specifies one entry in the presetnation, as follows:
    //  type|url|name
    // The type may be "image", "video" or "web".
    // In future, scaling values may be applied.
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
    if (!$sloodle->plugins->load_plugins('presenter')) {
        $sloodle->response->quick_output(-131, 'PLUGIN', 'Failed to load any SLOODLE Presenter plugins. Please check your "sloodle/plugin" folder.', false);
        exit();
    }
    
    // Start preparing the response
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    
    // Output each URL and entry type
    $slides = $sloodle->module->get_slides();
    if (is_array($slides)) {
        foreach ($slides as $slide) {
            // This will store the source URL for the slide
            $slidesource = '';
            // Convert the plugin class names back to the simpler slide type name.
			$slidetype = strtolower($slide->type);
            switch ($slidetype)
            {
            case 'presenterslideimage': case 'sloodlepluginpresenterslideimage': $slidetype = 'image'; break;
            case 'presenterslideweb': case 'sloodlepluginpresenterslideweb': $slidetype = 'web'; break;
            case 'presenterslidevideo': case 'sloodlepluginpresenterslidevideo': $slidetype = 'video'; break;
            }
            // Attempt to load the plugin for this type
            $slideplugin = $sloodle->plugins->get_plugin('presenter-slide', $slidetype);
            if ($slideplugin === false) {
                // Indicate the error as a side effect, and specify the type as an error
                sloodle_debug("Failed to load Presenter slide plugin.\n");
                $sloodle->response->add_side_effect(-132);
                $entrytype = 'ERROR';
                $entrysource = '';
            } else {
                list($mimetype, $slidesource) = $slideplugin->render_slide_for_sl($slide);
            }

            $sloodle->response->add_data_line(array($slidetype, $slidesource, $slide->name));
        }
    }
    
    // Output our response
    $sloodle->response->render_to_output();
    
?>
