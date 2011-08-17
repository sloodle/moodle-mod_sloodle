<?php
/**
* Defines a base class for viewing information about SLOODLE users (avatars).
* Class is inherited from the base view class.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** SLOODLE course data structure */
require_once(SLOODLE_LIBROOT.'/course.php');
/** Sloodle Session code. */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
/** General Sloodle functionality. */
require_once(SLOODLE_LIBROOT.'/general.php');

/**
* Class for rendering a view of SLOODLE users.
* @package sloodle
*/
class sloodle_view_users extends sloodle_base_view
{
    /**
    * Integer ID of the course which is being accessed.
    * @var integer
    * @access private
    */
    var $courseid = 0;
    
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
    * The search string for users where appropriate.
    * @var string
    * @access private
    */
    var $searchstr = '';

    /**
    * Moodle permissions context for the current course.
    * @var object
    * @access private
    */
    var $course_context = null;
    
    /**
    * Moodle permissions context for the system.
    * @var object
    * @access private
    */
    var $system_context = null;
    
    /**
    * Indicates if we should only show users who have avatars. Fetched from request parameters where given.
    * @var bool
    * @access private
    */
    var $sloodleonly = true;
    
    /**
    * URL for accessing the current course.
    * @var string
    * @access private
    */
    var $courseurl = '';
    
    /**
    * Short name of the current course.
    * @var string
    * @access private
    */
    var $courseshortname = '';
    
    /**
    * Full name of the current course.
    * @var string
    * @access private
    */
    var $coursefullname = '';
    
    /**
    * The result number to start displaying from
    * @var integer
    * @access private
    */
    var $start = 0;


    /**
    * Constructor.
    */
    function sloodle_view_users()
    {
    }

    /**
    * Check and process the request parameters.
    */
    function process_request()
    {
        global $CFG, $USER;
    
        // Fetch our Moodle and SLOODLE course data
        $this->courseid = optional_param('course', SITEID, PARAM_INT);
        if (!$this->course = sloodle_get_record('course', 'id', $this->courseid)) error('Could not find course.');
        $this->sloodle_course = new SloodleCourse();
        if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));
        
        // Construct the course URL, and fetch the names
        $this->courseurl = $CFG->wwwroot.'/course/view.php?id='.$this->courseid;
        $this->courseshortname = $this->course->shortname;
        $this->coursefullname = $this->course->fullname;
        
        // Fetch the other parameters
        $this->searchstr = addslashes(optional_param('search', '', PARAM_TEXT));
        $this->sloodleonly = optional_param('sloodleonly', false, PARAM_BOOL);
        $this->start = optional_param('start', 0, PARAM_INT);
        if ($this->start < 0) $this->start = 0;


        // Moodle 2 rendering functions like to know the course.
        // They get upset if you try to pass a course into print_footer() that isn't what they were expecting.
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
        global $CFG, $USER;
    
        // Ensure the user logs in
        require_login();
        if (isguestuser()) error(get_string('noguestaccess', 'sloodle'));
        //add_to_log($this->course->id, 'course', 'view sloodle user', '', "{$this->course->id}");

        
        // We need to establish some permissions here
        $this->course_context = get_context_instance(CONTEXT_COURSE, $this->courseid);
        $this->system_context = get_context_instance(CONTEXT_SYSTEM);
        // Make sure the user has permission to view this course (but let anybody view the site course details)
        if ($this->courseid != SITEID) require_capability('mod/sloodle:courseparticipate', $this->course_context);
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
        $navigation = '';
        if ($this->courseid != SITEID) $navigation .= "<a href=\"{$this->courseurl}\">{$this->courseshortname}</a> -> ";
        $navigation .= get_string('sloodleuserprofiles', 'sloodle');
        print_header(get_string('sloodleuserprofiles', 'sloodle'), get_string('sloodleuserprofiles', 'sloodle'), $navigation, "", "", false);
    }

    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
        global $CFG, $USER;
        
        // Get the localization strings
        $strsloodle = get_string('modulename', 'sloodle');
        $strsloodles = get_string('modulenameplural', 'sloodle');
        
        // Open the main body section
        echo '<div style="text-align:center;padding-left:8px;padding-right:8px;">';
        
        
//------------------------------------------------------
        
        print_box_start('generalbox boxwidthwide boxaligncenter');
        echo '<table style="text-align:left; vertical-align:top; margin-left:auto; margin-right:auto;">';
// // SEARCH FORMS // //
        echo '<tr>';

        // COURSE SELECT FORM //
        echo '<td style="width:350px; border:solid 1px #bbbbbb; padding:4px; vertical-align:top; width:33%;">';
        
        echo "<form action=\"{$CFG->wwwroot}/mod/sloodle/view.php\" method=\"get\">";
        echo '<input type="hidden" name="_type" value="users" />';
        echo '<span style="font-weight:bold;">'.get_string('changecourse','sloodle').'</span><br/>';
        
        echo '<select name="course" size="1">';
        
        // Get a list of all courses
        $allcourses = get_courses('all', 'c.shortname', 'c.id, c.shortname, c.fullname');
        if (!$allcourses) $allcourses = array();
        foreach ($allcourses as $as) {
            // Is the user able to view this particular course?
            if ($as->id == SITEID || has_capability('mod/sloodle:courseparticipate', get_context_instance(CONTEXT_COURSE, $as->id))) {
                // Output this as an option
                echo "<option value=\"{$as->id}\"";
                if ($as->id == $this->courseid) echo "selected";
                echo ">{$as->fullname}</option>";
            }
        }
        echo '</select><br/>';
        
        echo '<input type="checkbox" value="true" name="sloodleonly"';
        if ($this->sloodleonly) echo "checked";
        echo '/>'.get_string('showavatarsonly','sloodle').'<br/>';
        echo '<input type="submit" value="'.get_string('submit','sloodle').'" />';
        
        echo '</form>';
        
        echo '</td>';
        
        // USER SEARCH FORM //
        echo '<td style="width:350px; border:solid 1px #bbbbbb; padding:4px; vertical-align:top; width:33%;">';    
        
        echo "<form action=\"{$CFG->wwwroot}/mod/sloodle/view.php\" method=\"get\">";
        echo '<input type="hidden" name="_type" value="users" />';
        
        echo '<span style="font-weight:bold;">'.get_string('usersearch','sloodle').'</span><br/>';
        
        echo '<input type="hidden" value="'.s($this->courseid).'" name="course"/>';
        echo '<input type="text" value="'.$this->searchstr.'" name="search" size="30" maxlength="30"/><br/>';
        
        echo '<input type="checkbox" value="true" name="sloodleonly"';
        if ($this->sloodleonly) echo "checked";
        echo '/>'.get_string('showavatarsonly','sloodle').'<br/>';
        
        echo '<input type="submit" value="'.get_string('submit','sloodle').'" />';
        echo '</form>';
        
        echo '</td>';
        
        
        
        // AVATAR SEARCH //
        echo '<td style="width:350px; border:solid 1px #bbbbbb; padding:4px; vertical-align:top; width:33%;">';
        //echo '<span style="font-weight:bold;">'.get_string('specialpages','sloodle').'</span><br/>';        
        echo "<form action=\"{$CFG->wwwroot}/mod/sloodle/view.php\" method=\"get\">";
        echo '<input type="hidden" name="_type" value="user" />';
        
        echo '<span style="font-weight:bold;">'.get_string('avatarsearch','sloodle').'</span><br/>';
        
        echo '<input type="hidden" value="search" name="id"/>';
        echo '<input type="hidden" value="'.s($this->courseid).'" name="course"/>';
        echo '<input type="text" value="'.s($this->searchstr).'" name="search" size="30" maxlength="30"/><br/>';
        echo '<br/><input type="submit" value="'.get_string('submit','sloodle').'" />';
        echo '</form>';
        echo '</td>';
        
        
        
// // - END FORMS - // //
        echo '</tr>';
        echo '</table>';
        

        // Provide some admin-only links
	$system_context = get_context_instance(CONTEXT_SYSTEM);
        if ( has_capability('moodle/site:viewparticipants', $system_context) ) {
            echo '<p>';
            
            /*
            // Might be useful to add a "show admins" link, since they are not normally 'enrolled' in any course
            
            echo '&nbsp;&nbsp;|&nbsp;&nbsp;';*/
            
            // Link to view all avatars on the site
            echo "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=user&amp;id=all\" title=\"".get_string('viewall','sloodle')."\">";
            print_string('viewall','sloodle');
            echo '</a>';
            
            echo '</p>';
        }
        
        print_box_end();

        
//------------------------------------------------------

        
        // Are we searching for users?
        if ($this->searchstr != NULL)
        {
            // Display the search term
            echo '<br/><span style="font-size:16pt; font-weight:bold;">'.get_string('usersearch','sloodle').': '.$this->searchstr.'</span><br/><br/>';
            // Search the list of users
            $fulluserlist = get_users(true, $this->searchstr);
            if (!$fulluserlist) $fulluserlist = array();
            $userlist = array();
            // Filter it down to members of the course
            foreach ($fulluserlist as $ful) {
                if (has_capability('mod/sloodle:courseparticipate', $this->course_context, $ful->id)) {
                    // Copy it to our filtered list
                    $userlist[] = $ful;
                } else {
		}
            }
            
            
        } else {
            // Getting all users in a course
            // Display the name of the course
            echo '<br/><span style="font-size:18pt; font-weight:bold;">'.s($this->coursefullname).'</span><br/><br/>';
            // Obtain a list of all Moodle users enrolled in the specified course
            $userlist = get_course_users($this->courseid, 'lastname, firstname', '', 'u.id, firstname, lastname');
        }
        
        // Construct and display a table of Sloodle entries
        if ($userlist) {
            $sloodletable = new stdClass();
            $sloodletable->head = array(    get_string('user', 'sloodle'),
                                            get_string('avatar', 'sloodle')
                                        );
            $sloodletable->align = array('left', 'left');
            $sloodletable->size = array('50%', '50%');
            
            // Check if our start is past the end of our results
            if ($this->start >= count($userlist)) $this->start = 0;
            
            // Go through each entry to add it to the table
            $resultnum = 0;
            $resultsdisplayed = 0;
            $maxperpage = 20;
            foreach ($userlist as $u) {
                // Only display this result if it is after our starting result number
                if ($resultnum >= $this->start) {
                    // Reset the line's content
                    $line = array();
                    
                    // Construct URLs to this user's Moodle and SLOODLE profile pages
                    $url_moodleprofile = $CFG->wwwroot."/user/view.php?id={$u->id}&amp;course={$this->courseid}";
                    $url_sloodleprofile = SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$u->id}&amp;course={$this->courseid}";

                    // Add the Moodle name
                    $line[] = "<a href=\"{$url_moodleprofile}\">{$u->firstname} {$u->lastname}</a>";
                    
                    // Get the Sloodle data for this Moodle user
                    $sloodledata = sloodle_get_records('sloodle_users', 'userid', $u->id);
                    if ($sloodledata) {
                        // Display all avatars names, if available
                        $avnames = '';
                        $firstentry = true;
                        foreach ($sloodledata as $sd) {
                            // If this entry is empty, then skip it
                            if (empty($sd->avname) || ctype_space($sd->avname)) continue;
                            // Comma separated entries
                            if ($firstentry) $firstentry = false;
                            else $avnames .= ', ';
                            // Add the current name
                            $avnames .= $sd->avname;
                        }
                        // Add the avatar name(s) to the line
                        $line[] = "<a href=\"{$url_sloodleprofile}\">{$avnames}</a>";
                        
                    } else {
                        // The query failed - if we are showing only Sloodle-enabled users, then skip the rest
                        if ($this->sloodleonly) continue;
                        $line[] = '-';
                    }
                    
                    // Add the line to the table
                    $sloodletable->data[] = $line;
                    $resultsdisplayed++;
                }
                
                // Have we displayed the maximum number of results for this page?
                $resultnum++;
                if ($resultsdisplayed >= $maxperpage) break;
            }
            
            // Construct our basic URL to this page
            $basicurl = SLOODLE_WWWROOT."/view.php?_type=users&amp;course={$this->courseid}";
            if ($this->sloodleonly) $basicurl .= "&amp;sloodleonly=true";
            if (!empty($this->searchstr)) $basicurl .= "&amp;search={$this->searchstr}";
            
            // Construct the next/previous links
            $previousstart = max(0, $this->start - $maxperpage);
            $nextstart = $this->start + $maxperpage;
            $prevlink = null;
            $nextlink = null;
            if ($previousstart != $this->start) $prevlink = "<a href=\"{$basicurl}&amp;start={$previousstart}\" style=\"color:#0000ff;\">&lt;&lt;</a>&nbsp;&nbsp;";            
            if ($nextstart < count($userlist)) $nextlink = "<a href=\"{$basicurl}&amp;start={$nextstart}\" style=\"color:#0000ff;\">&gt;&gt;</a>";
            
            // Display the next/previous links, if we have at least one
            if (!empty($prevlink) || !empty($nextlink)) {
                echo '<p style="text-align:center; font-size:14pt;">';
                if (!empty($prevlink)) echo $prevlink;
                else echo '<span style="color:#777777;">&lt;&lt;</span>&nbsp;&nbsp;';
                if (!empty($nextlink)) echo $nextlink;
                else echo '<span style="color:#777777;">&gt;&gt;</span>&nbsp;&nbsp;';
                echo '</p>';
            }
            
            // Display the table
            print_table($sloodletable);
            
        } else {
            // Failed to query for list of users
            echo '<div style="font-weight:bold; color:red;">';
            print_string('nouserdata','sloodle');
            echo '</div>';
        }
        echo '</div>';
        
        
        // Close the main body section
        echo '</div>';

    }

    /**
    * Print the page footer.
    */
    function print_footer()
    {
        print_footer($this->course);
    }

}


?>
