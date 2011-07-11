<?php
/**
* Defines a base class for viewing sub-types of the SLOODLE module, such as the Controller and the Distributor.
* Class is inherited from the base view class, and should be further derived for module-specific functionality.
* This simply provides a common framework for initially handling requests and displaying common header/footer.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** The SLOODLE course data structure */
require_once(SLOODLE_LIBROOT.'/course.php');

/**
* The base class for viewing a SLOODLE module.
* Should be inherited and overridden.
* Child class MUST be named "sloodle_view_NAME", where NAME replaces the name of the feature or module.
* For example, "sloodle_view_controller" or "sloodle_view_course".
* For modules, the NAME must match the "type" specifier in the "sloodle" table, such as "controller", "distributor", or "presenter".
* @package sloodle
*/
class sloodle_base_view_module extends sloodle_base_view
{
    /**
    * The course module instance, retrieved directly from the database (table: course_modules)
    * @var object
    * @access private
    */
    var $cm = null;

    /**
    * The main SLOODLE module instance, retreived directly from the database (table: sloodle)
    * @var object
    * @access private
    */
    var $sloodle = null;

    /**
    * The VLE course object, retrieved directly from the database (table: course)
    * @var object
    * @access private
    */
    var $course = null;

    /**
    * The SLOODLE course object.
    * @var SloodleCourse
    * @access private
    */
    var $sloodle_course = null;

    /**
    * Context object for permissions in the Moodle course.
    * @var object
    * @access private
    */
    var $course_context = null;

    /**
    * Context object for permissions in the Moodle module.
    * @var object
    * @access private
    */
    var $module_context = null;

    /**
    * Indicates whether or the user can edit (or 'manage') this module, according to the VLE permissions.
    * @var bool
    * @access private
    */
    var $canedit = false;


    /**
    * Constructor.
    */
    function sloodle_base_view_module()
    {
    }

    /**
    * Checks for incoming request data identifying a particular module (parameter 'id').
    * Loads the relevant course module and SLOODLE module instances.
    * This should be overridden to add functionality to load any module-specific data.
    * However, you can simply call the parent function (i.e. this one) first to load the basic data.
    */
    function process_request()
    {
        // Note: some modules prefer 's' to indicate the instance number... may need to implement that as well.
        // Fetch the course module instance
        $id = required_param('id', PARAM_INT);
        if (!$this->cm = get_coursemodule_from_id('sloodle', $id)) error('Course module ID was incorrect.');
        // Fetch the course data
        if (!$this->course = sloodle_get_record('course', 'id', $this->cm->course)) error('Failed to retrieve course.');
        $this->sloodle_course = new SloodleCourse();
        if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));

        // Fetch the SLOODLE instance itself
        if (!$this->sloodle = sloodle_get_record('sloodle', 'id', $this->cm->instance)) error('Failed to find SLOODLE module instance');
    }

    /**
    * Check that the user has permission to view this module, and check if they can edit it too.
    */
    function check_permission()
    {
        // Make sure the user is logged-in
        require_course_login($this->course, true, $this->cm);

        add_to_log($this->course->id, 'sloodle', 'view sloodle module', "view.php?id={$this->cm->id}", "{$this->sloodle->id}", $this->cm->id);
        
        // Check for permissions
        $this->module_context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
        $this->course_context = get_context_instance(CONTEXT_COURSE, $this->course->id);
        if (has_capability('moodle/course:manageactivities', $this->module_context)) $this->canedit = true;

        // If the module is hidden, then can the user still view it?
        if (empty($this->cm->visible) && !has_capability('moodle/course:viewhiddenactivities', $this->module_context)) notice(get_string('activityiscurrentlyhidden'));
    }

    /**
    * Process any form data which has been submitted.
    */
    function process_form()
    {
    }

    /**
    * Print module header info.
    */
    function print_header()
    {
        global $CFG;

        // Offer the user an 'update' button if they are allowed to edit the module
        $editbuttons = '';
        if ($this->canedit) {
            $editbuttons = update_module_button($this->cm->id, $this->course->id, get_string('modulename', 'sloodle'));
        }
        // Display the header
        $navigation = "<a href=\"index.php?id={$this->course->id}\">".get_string('modulenameplural','sloodle')."</a> ->";
        print_header_simple(format_string($this->sloodle->name), "", "{$navigation} ".format_string($this->sloodle->name), "", "", true, $editbuttons, navmenu($this->course, $this->cm));

        // Display the module name
        $img = '<img src="'.$CFG->wwwroot.'/mod/sloodle/icon.gif" width="16" height="16" alt=""/> ';
        print_heading($img.$this->sloodle->name, 'center');
    
        // Display the module type and description
        $fulltypename = get_string("moduletype:{$this->sloodle->type}", 'sloodle');
        echo '<h4 style="text-align:center;">'.get_string('moduletype', 'sloodle').': '.$fulltypename;
        echo helpbutton("moduletype_{$this->sloodle->type}", $fulltypename, 'sloodle', true, false, '', true).'</h4>';
        // We'll apply a general introduction to all Controllers, since they seem to confuse lots of people!
        $intro = $this->sloodle->intro;
        if ($this->sloodle->type == SLOODLE_TYPE_CTRL) $intro = '<p style="font-style:italic;">'.get_string('controllerinfo','sloodle').'</p>' . $this->sloodle->intro;
		// Display the intro in a box, if we have an intro
		if (!empty($intro)) print_box($intro, 'generalbox', 'intro');
    
    }

    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
    }

    /**
    * Print the footer for this course.
    */
    function print_footer()
    {
        print_footer($this->course);
    }
}


?>
