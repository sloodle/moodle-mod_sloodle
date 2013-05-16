<?php
/**
* Defines a class to render a page for adding avatar details into SLOODLE manually.
* Class is inherited from the base view class.
*
* @package sloodle
* @copyright Copyright (c) 2008-10 SLOODLE community (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*
*/ 

// Under all circumstances:
// This page expects to be accessed with an HTTP parameter 'user', indicating the ID of the Moodle user to add an avatar to.
// Optionally, a 'course' parameter can specify the course ID we came from to facilitate breadcrumb linking. (It will default to the site course without it.)

// When submitting avatar data in a form:
// Parameter 'sloodleuuid' and 'sloodleavname' must specify the UUID and name of the avatar being added.
// Additionally, the 'sesskey' parameter should specify the user's session key to prevent XSS-style attacks.


/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');

/** Include our general SLOODLE functionality */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_addavatar extends sloodle_base_view
{    
    /**
    * The VLE course object, retrieved directly from database.
    * Corresponds to the course the user came from, and is used only to facilitate navigation.
    * @var object
    * @access private
    */
    var $course = 0;

    /**
    * The user to whom we are adding an avatar. (A SloodleUser object)
    * @var object
    * @access private
    */
    var $user = null;
    
    /**
    * Indicates if an avatar is already registered to this user.
    * 0 means no, 1 means one avatar is registered, and 2 means more than 1 avatar is registered.
    * @var integer
    * @access private
    */
    var $has_avatar = 0;
    
    /**
    * This array will store a list of error messages to report to the user when the page is rendered.
    * @var array
    * @access private
    */
    var $msg_error = array();
    
    /**
    * This array will store a list of information messages (such as success repots) to display to the user when the page is rendered.
    * @var array
    * @access private
    */
    var $msg_info = array();
    
    /**
    * Indicates the status of the avatar add operation. 0 = nothing was done, -1 = attempted but failed, 1 = attempted and succeeded
    * @var integer
    * @var private
    */
    var $add_status = 0;


    /**
    * Constructor.
    */
    function sloodle_view_addavatar()
    {
        // Setup a dummy SloodleSession and use its user object
        $dummysession = new SloodleSession(false);
        $this->user = $dummysession->user;
    }

    /**
    * Check the request parameters to see which course was specified.
    */
    function process_request()
    {
        // Load the requested user
        $userid = required_param('user', PARAM_INT);
        if (!$this->user->load_user($userid)) error('User not found.');
        // Look for any existing registered avatars
        $linked_avatar = $this->user->load_linked_avatar();
        if ($linked_avatar === true) $this->has_avatar = 1;
        else if ($linked_avatar === 'multi') $this->has_avatar = 2;
        
        // Fetch the Moodle course data
        $courseid = optional_param('course', SITEID, PARAM_INT);
        if (!$this->course = sloodle_get_record('course', 'id', $courseid)) error('Could not find course.');

	// Moodle 2 rendering functions like to know the course.
	// They get upset if you try to pass a course into sloodle_print_footer() that isn't what they were expecting.
	if ($this->course) {
		global $PAGE;
		if (isset($PAGE) && method_exists($PAGE, 'set_course')) {
			$PAGE->set_course($this->course);
		}
	}
    }

    /**
    * Check that the user is logged-in and has permission to alter course settings.
    */
    function check_permission()
    {
	$system_context = get_context_instance(CONTEXT_SYSTEM);
 	
        // Only allow admins to do this.
        if (!has_capability('moodle/user:editprofile', $system_context)) print_error('Only site administrators have access to this page.');
    }
    
    /**
    * Process any form data which has been submitted.
    * This must be overridden to add functionality.
    */
    function process_form()
    {
        // Was a form submitted?
        if (empty($_REQUEST['submit'])) return;
        
        // Make sure the correct session key was specified.
        $form_sesskey = required_param('sesskey', PARAM_RAW);
        if ($form_sesskey != sesskey())
        {
            $this->msg_error[] = get_string('invalidsesskey', 'sloodle');
            $this->add_status = -1;
            return;
        }
        
        // Grab the avatar data
        $form_uuid = required_param('sloodleuuid', PARAM_TEXT);
        $form_avname = required_param('sloodleavname', PARAM_TEXT);
        
        // Make sure the given UUID doesn't already exist in the database
        if (sloodle_count_records('sloodle_users', 'uuid', $form_uuid))
        {
            $this->msg_error[] = get_string('avataruuidalreadyindb', 'sloodle');
            $this->add_status = -1;
            return;
        }
        
        // Register the avatar to the user
        if ($this->user->add_linked_avatar($this->user->get_user_id(), $form_uuid, $form_avname))
        {
            $this->msg_info[] = get_string('addavatar:success', 'sloodle');
            $this->add_status = 1;
        } else {
            $this->msg_info[] = get_string('addavatar:fail', 'sloodle');
            $this->add_status = -1;
        }
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
        global $CFG;
        
        // Construct the breadcrumb links
        $userid = $this->user->get_user_id();
        $navigation = "";
        if ($this->course->id != SITEID) $navigation .= "<a href=\"{$CFG->wwwroot}/course/view.php?_type=user&amp;id={$this->course->id}\">{$this->course->shortname}</a> -> ";
        $navigation .= "<a href=\"".SLOODLE_WWWROOT."/view.php?_type=users&amp;course={$this->course->id}\">".get_string('sloodleuserprofiles', 'sloodle') . '</a> -> ';
        $navigation .= "<a href=\"".SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$userid}&amp;course={$this->course->id}\">".$this->user->get_user_firstname()." ".$this->user->get_user_lastname()."</a> -> ";
        $navigation .= get_string('addavatar', 'sloodle');
        
        // Display the header
        print_header(get_string('addavatar', 'sloodle'), get_string('addavatar','sloodle'), $navigation, "", "", true);
    }


    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
        global $CFG;

        // Fetch string table text
        $stravatarname = get_string('avatarname', 'sloodle');
        $stravataruuid = get_string('avataruuid', 'sloodle');
        $strsubmit = get_string('submit', 'sloodle');
        $struser = get_string('user', 'sloodle');

    //------------------------------------------------------    
        
        // Display any information messages
        if (count($this->msg_info) > 0)
        {
            sloodle_print_box_start('generalbox boxwidthwide boxaligncenter centerpara');
            echo "<ul style=\"list-style:none;\">\n";
            foreach ($this->msg_info as $msg)
            {
                echo "<li><img src=\"{$CFG->wwwroot}/pix/i/tick_green_big.gif\" alt=\"[tick icon]\" /> <strong>{$msg}</strong></li>\n";
            }
            echo "</ul>\n";
            sloodle_print_box_end();
        }
        
        // Display any error messages
        if (count($this->msg_error) > 0)
        {
            sloodle_print_box_start('generalbox boxwidthwide boxaligncenter centerpara');
            echo "<ul style=\"list-style:none;\">\n";
            foreach ($this->msg_error as $msg)
            {
                echo "<li><img src=\"{$CFG->wwwroot}/pix/i/cross_red_big.gif\" alt=\"[error icon]\" /> {$msg}</li>\n";
            }
            echo "</ul>\n";
            sloodle_print_box_end();
        }
        
        // Prepare the form default values
        $form_default_avname = '';
        $form_default_uuid = '';
        if ($this->add_status == -1)
        {
            $form_default_avname = optional_param('sloodleavname', '', PARAM_TEXT);
            $form_default_uuid = optional_param('sloodleuuid', '', PARAM_TEXT);
        }
        
        
        // Display the form
        $sk = sesskey();
        $userid = $this->user->get_user_id();
        $userfullname = $this->user->get_user_firstname().' '.$this->user->get_user_lastname();
        
        sloodle_print_box_start('generalbox boxwidthwide boxaligncenter centerpara');
        echo "<h2>",get_string('addavatar', 'sloodle'),"</h2>\n";
        
        echo <<<ADD_AVATAR_FORM
        
<form action="{$CFG->wwwroot}/mod/sloodle/view.php" method="GET">
 
 <fieldset> 

  <input type="hidden" name="_type" value="addavatar"/>
  <input type="hidden" name="user" value="{$userid}"/>
  <input type="hidden" name="course" value="{$this->course->id}"/>
  <input type="hidden" name="sesskey" value="{$sk}"/>
  
  {$struser}: <strong>{$userfullname}</strong><br/><br/>
 
  <label for="sloodleavname">{$stravatarname}: </label>
  <input type="text" name="sloodleavname" id="sloodleavname" value="{$form_default_avname}" size="45" /><br/><br/>
 
  <label for="sloodleuuid">{$stravataruuid}: </label>
  <input type="text" name="sloodleuuid" id="sloodleuuid" value="{$form_default_uuid}" size="45" /><br/><br/>
 
  <input type="submit" name="submit" value="{$strsubmit}" />

 </fieldset>
</form>
ADD_AVATAR_FORM;
        
        sloodle_print_box_end();
        
        
        echo "<div style=\"text-align:center;\">\n";
        echo "<a href=\"".SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$userid}&amp;course={$this->course->id}\">&lt;&lt;&lt; ".get_string('backtoavatarpage','sloodle')."</a>";
        echo "</div>\n";
    }

    /**
    * Print the footer for this course.
    */
    function sloodle_print_footer()
    {
        sloodle_print_footer($this->course);
    }

}


?>
