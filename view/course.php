<?php
// This file is part of the Sloodle project (www.sloodle.org)
/**
* Defines a class to render a view of SLOODLE course information.
* Class is inherited from the base view class.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*
*/ 

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** SLOODLE course data structure */
require_once(SLOODLE_LIBROOT.'/course.php');

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_course extends sloodle_base_view
{
    /**
    * The VLE course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $course = 0;

    /**
    * SLOODLE course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $sloodle_course = null;

    /**
    * Course context for Moodle permissions.
    * @var object
    * @access private
    */
    var $course_context = null;


    /**
    * Constructor.
    */
    function sloodle_view_course()
    {
    }

    /**
    * Check the request parameters to see which course was specified.
    */
    function process_request()
    {
        $id = required_param('id', PARAM_INT);
        if (!$this->course = sloodle_get_record('course', 'id', $id)) error('Could not find course.');
        $this->sloodle_course = new SloodleCourse();
        if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));

    }

    /**
    * Check that the user is logged-in and has permission to alter course settings.
    */
    function check_permission()
    {
        // Ensure the user logs in
        require_login($this->course->id);
        if (isguestuser()) error(get_string('noguestaccess', 'sloodle'));
        add_to_log($this->course->id, 'course', 'view sloodle data', '', "{$this->course->id}");

        // Ensure the user is allowed to update information on this course
        $this->course_context = get_context_instance(CONTEXT_COURSE, $this->course->id);
        require_capability('moodle/course:update', $this->course_context);
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
        global $CFG;
        $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=course&id={$this->course->id}\">".get_string('courseconfig', 'sloodle')."</a>";


        print_header_simple(get_string('courseconfig','sloodle'), "&nbsp;", $navigation, "", "", true, '', navmenu($this->course));
    }


    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
        global $CFG;

        // Fetch string table text
        $strsloodle = get_string('modulename', 'sloodle');
        $strsloodles = get_string('modulenameplural', 'sloodle');
        $strsavechanges = get_string('savechanges');
        $stryes = get_string('yes');
        $strno = get_string('no');
        $strenabled = get_string('enabled','sloodle');
        $strdisabled = get_string('disabled','sloodle');
        $strsubmit = get_string('submit', 'sloodle');

    //------------------------------------------------------    
        
        // If the form has been submitted, then process the input
        if (isset($_REQUEST['submit_course_options'])) {
            // Get the parameters
            $form_autoreg = required_param('autoreg', PARAM_BOOL);
            $form_autoenrol = required_param('autoenrol', PARAM_BOOL);
            
            // Update the Sloodle course object
            if ($form_autoreg) $this->sloodle_course->enable_autoreg();
            else $this->sloodle_course->disable_autoreg();
            if ($form_autoenrol) $this->sloodle_course->enable_autoenrol();
            else $this->sloodle_course->disable_autoenrol();
            
            // Update the database
            if ($this->sloodle_course->write()) {
                redirect("view.php?_type=course&id={$this->course->id}", get_string('changessaved'), 4);
                exit();
            } else {
                sloodle_print_box(get_string('error'), 'generalbox boxwidthnarrow boxaligncenter');
            }
        }
        
    //------------------------------------------------------

        // Display info about Sloodle course configuration
        echo "<h1 style=\"text-align:center;\">".get_string('courseconfig','sloodle')."</h1>\n"; 
        echo "<h2 style=\"text-align:center;\">(".get_string('course').": \"<a href=\"{$CFG->wwwroot}/course/view.php?id={$this->course->id}\">".$this->sloodle_course->get_full_name()."</a>\")</h2>";
        

        sloodle_print_box(get_string('courseconfig:info','sloodle'), 'generalbox boxaligncenter boxwidthnormal');
        echo "<br/>\n";

    // Get the initial form values
        $val_autoreg = (int)(($this->sloodle_course->get_autoreg()) ? 1 : 0);
        $val_autoenrol = (int)(($this->sloodle_course->get_autoenrol()) ? 1 : 0);
        
        // Make the selection options for enabling/disabling items
        $selection_menu = array(0 => $strdisabled, 1 => $strenabled);
        
        // Start the box
        sloodle_print_box_start('generalbox boxaligncenter boxwidthnormal');
        echo '<div style="text-align:center;"><h3>'.get_string('coursesettings','sloodle').'</h3>';
        
        // Start the form (including a course ID hidden parameter)
        echo "<form action=\"view.php\" method=\"post\">\n";
        echo "<input type=\"hidden\" name=\"id\" value=\"{$this->course->id}\">\n";
        echo "<input type=\"hidden\" name=\"_type\" value=\"course\">\n";
        
    // AUTO REGISTRATION //
        echo "<p>\n";
        sloodle_helpbutton('auto_registration', get_string('help:autoreg','sloodle'), 'sloodle', true, false, '', false);
        echo get_string('autoreg', 'sloodle').': ';
        choose_from_menu($selection_menu, 'autoreg', $val_autoreg, '', '', 0, false);
        // Add the site status
        if (!sloodle_autoreg_enabled_site()) echo '<br/>&nbsp;<span style="color:red; font-style:italic; font-size:80%;">('.get_string('autoreg:disabled','sloodle').')</span>';
        echo "</p>\n";
        
    // AUTO ENROLMENT //
        echo "<p>\n";
        sloodle_helpbutton('auto_enrolment', get_string('help:autoenrol','sloodle'), 'sloodle', true, false, '', false);
        echo get_string('autoenrol', 'sloodle').': ';
        choose_from_menu($selection_menu, 'autoenrol', $val_autoenrol, '', '', 0, false);
        // Add the site status
        if (!sloodle_autoenrol_enabled_site()) echo '<br/>&nbsp;<span style="color:red; font-style:italic; font-size:80%;">('.get_string('autoenrol:disabled','sloodle').')</span>';
        echo '</p>';
        
        
        // Close the form, along with a submit button
        echo "<input type=\"submit\" value=\"$strsubmit\" name=\"submit_course_options\"\>\n</form>\n";
        
        // Finish the box
        echo '</div>';
        sloodle_print_box_end();

        
    //------------------------------------------------------

        // Loginzone information
        sloodle_print_box_start('generalbox boxaligncenter boxwidthnarrow');
        echo '<div style="text-align:center;"><h3>'.get_string('loginzonedata','sloodle').'</h3>';
        
        $lastupdated = '('.get_string('unknown','sloodle').')';
        if ($this->sloodle_course->get_loginzone_time_updated() > 0) $lastupdated = date('Y-m-d H:i:s', $this->sloodle_course->get_loginzone_time_updated());
            
        echo get_string('position','sloodle').': '.$this->sloodle_course->get_loginzone_position().'<br>';
        echo get_string('size','sloodle').': '.$this->sloodle_course->get_loginzone_size().'<br>';
        echo get_string('region','sloodle').': '.$this->sloodle_course->get_loginzone_region().'<br>';
        echo get_string('lastupdated','sloodle').': '.$lastupdated.'<br>';
        echo '<br>';
        
        
        // Have we been instructed to clear all pending allocations?
        if (isset($_REQUEST['clear_loginzone_allocations'])) {
            // Delete all allocations relating to this course
            sloodle_delete_records('sloodle_loginzone_allocation', 'course', $this->course->id);
        }
        
        // Create a form
        echo "<form action=\"view.php\" method=\"POST\">\n";
        echo "<input type=\"hidden\" name=\"id\" value=\"{$this->course->id}\">\n";
        echo "<input type=\"hidden\" name=\"_type\" value=\"course\">\n";
        // Determine how many allocations there are for this course
        $allocs = sloodle_count_records('sloodle_loginzone_allocation', 'course', $this->course->id);
        echo get_string('pendingallocations','sloodle').': '.$allocs.'&nbsp;&nbsp;';
        echo '<input type="submit" name="clear_loginzone_allocations" value="'.get_string('delete','sloodle').'"/>';
        echo "</form>\n";
        
        
        echo '</div>';
        sloodle_print_box_end();

        


   
//------------------------------------------------------

    $course = $this->course;

    }

    /**
    * Print the footer for this course.
    */
    function sloodle_print_footer()
    {
        global $CFG;
        echo "<p style=\"text-align:center; margin-top:32px; font-size:90%;\"><a href=\"{$CFG->wwwroot}/course/view.php?id={$this->course->id}\">&lt;&lt;&lt; ".get_string('backtocoursepage','sloodle')."</a></h2>";
        sloodle_print_footer($this->course);
    }

}


?>
