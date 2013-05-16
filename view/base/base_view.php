<?php
/**
* Defines a base class for views of SLOODLE modules and features.
* Module-/feature-specific functionality should be specified by inheriting and overidding specific functions.
* When this file is included, it expects the Moodle library and config info to already be included too.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/


/**
* The base class for viewing a SLOODLE module or feature.
* Should be inherited and overridden.
* Child class MUST be named "sloodle_view_NAME", where NAME replaces the name of the feature or module.
* For example, "sloodle_view_controller" or "sloodle_view_course".
* For modules, the NAME must match the "type" specifier in the "sloodle" table, such as "controller", "distributor", or "presenter".
* Modules should be automatically found, although special features (such as courses or users) will need to coded manually into the main view.php script.
* @package sloodle
*/
class sloodle_base_view
{
    /**
    * Constructor.
    */
    function sloodle_base_view()
    {
    }

    /**
    * The main viewing function.
    * This gets called by the system to render the view of the module.
    */
    function view()
    {
        // Process basic incoming data
        // (this fetches all necessary course and module data)
        $this->process_request();

        // Check user permissions to access this resource.
        // This first requires that the user is logged-in (for best results, DO NOT output anything before this).
        // It then checks that the user has permission to view the course and module.
        // It finally also checks to see if the user has edit permission.
        $this->check_permission();

        // Process any form submission.
        // It is useful to do this before any data is outputted, so that the user can be issued a header direct after form submission.
        // This can be used to get rid of any form-related request parameters which break forward/back navigation and manual refreshes.
        $this->process_form();

        // Output the page header.
        // This normally includes standard SLOODLE stuff, such as a note of whether or not the course allows auto-registration.
        $this->print_header();

        // Render the view of the module or feature itself
        $this->render();

        // Output the page footer.
        // This is normally very simple, but can include other data too.
        $this->sloodle_print_footer();
    }

    /**
    * Check for incoming request data identifying a particular course or module.
    * This must be overridden to add functionality.
    */
    function process_request()
    {
    }

    /**
    * Check that the user has permission to access the current resources.
    * This must be overridden to add functionality.
    */
    function check_permission()
    {
    }

    /**
    * Process any form data which has been submitted.
    * This must be overridden to add functionality.
    */
    function process_form()
    {
    }

    /**
    * Print the standard page header.
    * This should usually be overridden to add additional information, such as page title, header, and navigation links.
    */
    function print_header()
    {
        print_header_simple();
    }

    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
    }

    /**
    * Output the page footer.
    * This does not usually have to be overridden, unless there is something to be added or a block element to be closed.
    */
    function sloodle_print_footer()
    {
        sloodle_print_footer();
    }

}


?>
