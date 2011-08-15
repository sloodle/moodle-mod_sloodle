<?php
/**
* Defines a base class for viewing information about a specific SLOODLE user (avatar).
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
* Class for rendering a view of SLOODLE user information.
* @package sloodle
*/
class sloodle_view_user extends sloodle_base_view
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
    * Integer ID of the Moodle user being viewed.
    * Supplied by request parameter.
    * @var integer
    * @access private
    */
    var $moodleuserid = null;
    
    /**
    * Integer ID of a SLOODLE user entry to delete, where supplied by request parameter.
    * Null or 0 indicates nothing is to be deleted.
    * @var integer
    * @access private
    */
    var $deletesloodleentry = null;
    
    /**
    * Indicates a confirmation for certain actions, such as deletion, supplied by request parameter.
    * @var string
    * @access private
    */
    var $userconfirmed = null;
    
    /**
    * The search string for users where appropriate.
    * @var string
    * @access private
    */
    var $searchstr = '';
    
    /**
    * List of user objects to be deleted (stored as a string, retrieved from request parameters).
    * @var string
    * @access private
    */
    var $deleteuserobjects = null;

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
    * Is the user viewing their own profile?
    * @var bool
    * @access private
    */
    var $viewingself = false;
    
    /**
    * Can the user edit the data they are viewing?
    * @var bool
    * @access private
    */
    var $canedit = false;
    
    /**
    * The result number to start displaying from
    * @var integer
    * @access private
    */
    var $start = 0;


    /**
    * Constructor.
    */
    function sloodle_view_user()
    {
    }

    /**
    * Check and process the request parameters.
    */
    function process_request()
    {
        // Fetch some parameters
        $this->moodleuserid = required_param('id', PARAM_RAW);
        $this->deletesloodleentry = optional_param('delete', null, PARAM_INT);
        $this->userconfirmed = optional_param('confirm', null, PARAM_RAW);
        $this->courseid = optional_param('course', SITEID, PARAM_INT);
        $this->searchstr = addslashes(optional_param('search', '', PARAM_TEXT));
        $this->deleteuserobjects = optional_param('deleteuserobjects', null, PARAM_TEXT);
        
        // If we are viewing 'all' avatar entries, then revert to the site course
        if (strcasecmp($this->moodleuserid, 'all') == 0) $this->courseid = SITEID;
    
        // Fetch our Moodle and SLOODLE course data
        if (!$this->course = sloodle_get_record('course', 'id', $this->courseid)) error('Could not find course.');
        $this->sloodle_course = new SloodleCourse();
        if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));
        $this->start = optional_param('start', 0, PARAM_INT);
        if ($this->start < 0) $this->start = 0;
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

	// The "all" view should be only available to admins
        if ( !has_capability('moodle/site:viewparticipants', $this->system_context) ){
            error(get_string('insufficientpermissiontoviewpage', 'sloodle'));
            exit();
        }
        $this->viewingself = false;
        $this->canedit = false;
        // Is the user trying to view their own profile?
        if ($this->moodleuserid == $USER->id) {
            $this->viewingself = true;
            $this->canedit = true;
        } else {
            // Does the user have permission to edit other peoples' profiles in the system and/or course?
            // If not, can they at least view others' profiles for the system or course?
            if (has_capability('moodle/user:editprofile', $this->system_context) || has_capability('moodle/user:editprofile', $this->course_context)) {
                // User can edit profiles
                $this->canedit = true;
            } else if (!(has_capability('moodle/user:viewdetails', $this->system_context) || has_capability('moodle/user:viewdetails', $this->course_context))) {
                // If this is the site course, then let it through anyway
                if ($this->courseid != SITEID) {
                    error(get_string('insufficientpermissiontoviewpage','sloodle'));
                    exit();
                }
            }
        }
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
    }

    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
        global $CFG, $USER;
        
        // Were any of the delete parameters specified in HTTP (e.g. from a form)?
        if (!empty($this->deleteuserobjects) || !empty($this->deletesloodleentry) || !empty($this->userconfirmed)) {
            // Convert them to session parameters
            if (!empty($this->deleteuserobjects)) $_SESSION['deleteuserobjects'] = $this->deleteuserobjects;
            if (!empty($this->deletesloodleentry)) $_SESSION['deletesloodleentry'] = $this->deletesloodleentry;
            if (!empty($this->userconfirmed)) $_SESSION['userconfirmed'] = $this->userconfirmed;
            
            // Construct our full URL, with GET parameters
            $url = sloodle_get_web_path();
            $url .= "?_type=user&id={$this->moodleuserid}";
            if (!empty($this->courseid)) $url .= "&course={$this->courseid}";
            if (!empty($this->searchstr)) $url .= "&search={$this->searchstr}";
            if (!empty($this->start)) $url .= "&start={$this->start}";
            // Reload this page without those parameters
            redirect($url);
            exit();
        }

        // Extract data from our session parameters
        if (isset($_SESSION['deleteuserobjects'])) {
            $this->deleteuserobjects = $_SESSION['deleteuserobjects'];
            unset($_SESSION['deleteuserobjects']);
        }
        if (isset($_SESSION['deletesloodleentry'])) {
            $this->deletesloodleentry = $_SESSION['deletesloodleentry'];
            unset($_SESSION['deletesloodleentry']);
        }
        if (isset($_SESSION['userconfirmed'])) {
            $this->userconfirmed = $_SESSION['userconfirmed'];
            unset($_SESSION['userconfirmed']);
        }
        
        // Check the mode: all, search, pending, or single
        $allentries = false;
        $searchentries = false;
        if (strcasecmp($this->moodleuserid, 'all') == 0) {
            $allentries = true;
            $this->moodleuserid = -1;
        } else if (strcasecmp($this->moodleuserid, 'search') == 0) {
            $searchentries = true;
            $this->moodleuserid = -1;
        } else {
            // Make sure the Moodle user ID is an integer
            $this->moodleuserid = (integer)$this->moodleuserid;
            if ($this->moodleuserid <= 0) error(ucwords(get_string('unknownuser', 'sloodle')));
        }
        
        
        // Get the URL and names of the course
        $courseurl = $CFG->wwwroot.'/course/view.php?_type=user&amp;id='.$this->courseid;
        $courseshortname = $this->course->shortname;
        $coursefullname = $this->course->fullname;
        
        // This value will indicate if we are currently confirming a deletion
        $confirmingdeletion = false;
        
        // These are localization strings used by the deletion confirmation form
        $form_yes = get_string('Yes', 'sloodle');
        $form_no = get_string('No', 'sloodle');
        
        
        // Are we deleting a Sloodle entry?
        $deletemsg = '';    
        if ($this->deletesloodleentry != NULL) {
            // Determine if the user is allowed to delete this entry
            $allowdelete = $this->canedit; // Just go with the editing ability for now... will maybe change this later. -PRB
            
            // Has the deletion been confirmed?
            if ($this->userconfirmed == $form_yes) {
                if (sloodle_record_exists('sloodle_users', 'id', $this->deletesloodleentry)) {
                    // Is the user allowed to delete this?
                    if ($allowdelete) {
                        // Make sure it's a valid ID
                        if (is_int($this->deletesloodleentry) && $this->deletesloodleentry > 0) {
                            // Attempt to delete the entry
                            $deleteresult = sloodle_delete_records('sloodle_users', 'id', $this->deletesloodleentry);
                            if ($deleteresult === FALSE) {
                                $deletemsg = get_string('deletionfailed', 'sloodle').': '.get_string('databasequeryfailed', 'sloodle');
                            } else {
                                $deletemsg = get_string('deletionsuccessful', 'sloodle');
                            }
                        } else {
                            $deletemsg = get_string('deletionfailed', 'sloodle').': '.get_string('invalidid', 'sloodle');
                        }
                    } else {
                        $deletemsg = get_string('deletionfailed', 'sloodle').': '.get_string('insufficientpermission', 'sloodle');
                    }
                }
            } else if (is_null($this->userconfirmed)) {
                // User needs to confirm deletion
                $confirmingdeletion = true;
                
                $form_url = SLOODLE_WWWROOT."/view.php";
                
                $deletemsg .= '<h3>'.get_string('delete','sloodle').' '.get_string('ID','sloodle').': '.$this->deletesloodleentry.'<br/>'.get_string('confirmdelete','sloodle').'</h3>';
                $deletemsg .= '<form action="'.$form_url.'" method="get">';
                $deletemsg .= '<input type="hidden" name="_type" value="user" />';
                
                if ($allentries) $deletemsg .= '<input type="hidden" name="id" value="all" />';
                else if ($searchentries) $deletemsg .= '<input type="hidden" name="id" value="search" /><input type="hidden" name="search" value="'.$this->searchstr.'" />';
                else $deletemsg .= '<input type="hidden" name="id" value="'.$this->moodleuserid.'" />';
                
                if (!is_null($this->courseid)) $deletemsg .= '<input type="hidden" name="course" value="'.$this->courseid.'" />';
                $deletemsg .= '<input type="hidden" name="delete" value="'.$this->deletesloodleentry.'" />';
                $deletemsg .= '<input type="hidden" name="start" value="'.$this->start.'" />';
                $deletemsg .= '<input style="color:green;" type="submit" value="'.$form_yes.'" name="confirm" />&nbsp;&nbsp;';
                $deletemsg .= '<input style="color:red;" type="submit" value="'.$form_no.'" name="confirm" />';
                $deletemsg .= '</form><br/>';
                
            } else {
                $deletemsg = get_string('deletecancelled','sloodle');
            }
        }
        
        // Are we getting all entries, searching, or just viewing one?
        if ($allentries) {
            // All entries
            $moodleuserdata = null;
            // Fetch a list of all Sloodle user entries
            $sloodleentries = sloodle_get_records('sloodle_users');
        } else if ($searchentries && !empty($this->searchstr)) {
            // Search entries
            $moodleuserdata = null;
            $LIKE = sloodle_sql_ilike();
            $params = array('%{$this->searchstr}%', '%{$this->searchstr}%');
            $fullsloodleentries = sloodle_get_records_select('sloodle_users', "avname $LIKE ? OR uuid $LIKE ?", 'avname', $params);
            if (!$fullsloodleentries) $fullsloodleentries = array();
            $sloodleentries = array();
            // Eliminate entries belonging to avatars who are not in the current course
            foreach ($fullsloodleentries as $fse) {
                // Does the Moodle user have permission?
                if (has_capability('moodle/course:view', $this->course_context, $fse->userid)) {
                    // Copy it to our filtered list
                    $sloodleentries[] = $fse;
                }
            }
            
        } else {
            // Attempt to fetch the Moodle user data
            $moodleuserdata = sloodle_get_record('user', 'id', $this->moodleuserid);
            // Fetch a list of all Sloodle user entries associated with this Moodle account
            $sloodleentries = sloodle_get_records('sloodle_users', 'userid', $this->moodleuserid);
        }
        // Post-process the query results
        if ($sloodleentries === FALSE) $sloodleentries = array();
        $numsloodleentries = count($sloodleentries);
        
        
        // Get the localization strings
        $strsloodle = get_string('modulename', 'sloodle');
        $strsloodles = get_string('modulenameplural', 'sloodle');
        $strunknown = get_string('unknown', 'sloodle');
        
        // Construct the breadcrumb links
        $navigation = "";
        if ($this->courseid != 1) $navigation .= "<a href=\"$courseurl\">$courseshortname</a> -> ";
        $navigation .= "<a href=\"".SLOODLE_WWWROOT."/view.php?_type=users&amp;course={$this->courseid}\">".get_string('sloodleuserprofiles', 'sloodle') . '</a> -> ';
        if ($this->moodleuserid > 0) {
            if ($moodleuserdata) $navigation .= $moodleuserdata->firstname.' '.$moodleuserdata->lastname;
            else $navigation .= get_string('unknownuser','sloodle');
        } else if ($searchentries) {
            $navigation .= get_string('avatarsearch', 'sloodle');
        } else {
            $navigation .= get_string('allentries', 'sloodle');
        }
        
        // Display the header
        print_header(get_string('sloodleuserprofile', 'sloodle'), get_string('sloodleuserprofile','sloodle'), $navigation, "", "", true);
        
        echo '<div style="text-align:center;padding-left:8px;padding-right:8px;">';
        // Display the deletion message if we have one
        if (!empty($deletemsg)) {
            echo '<div style="text-align:center; padding:3px; border:solid 1px #aaaaaa; background-color:#dfdfdf; font-weight:bold; color:#dd0000;">';
            echo $deletemsg;
            echo '</div>';
        }
        echo '<br/>';
        
        // Are we dealing with an actual Moodle account?
        if ($this->moodleuserid > 0) {
            echo '<p>';
            // Yes - do we have an account?
            if ($moodleuserdata) {
                // Yes - display the name and other general info
                echo '<span style="font-size:18pt; font-weight:bold;">'. $moodleuserdata->firstname .' '. $moodleuserdata->lastname.'</span>';
                echo " <span style=\"font-size:10pt; color:#444444; font-style:italic;\">(<a href=\"{$CFG->wwwroot}/user/view.php?id={$this->moodleuserid}&amp;course={$this->courseid}\">".get_string('moodleuserprofile','sloodle')."</a>)</span><br/>";
            } else {
                echo get_string('moodleusernotfound', 'sloodle').'<br/>';
            }        
            echo "<br/><br/>\n";
            
            // Check for issues such as no entries, or multiple entries
            if ($numsloodleentries == 0) {
                echo '<span style="color:red; font-weight:bold;">';
                print_string('noentries', 'sloodle');
                echo '</span>';
                // If it is the profile owner who is viewing this, then offer a link to the loginzone entry page
                if ($this->moodleuserid == $USER->id) {
                    echo "<br/><br/><p style=\"padding:8px; border:solid 1px #555555;\"><a href=\"{$CFG->wwwroot}/mod/sloodle/classroom/loginzone.php?id={$this->courseid}\">";
                    print_string('getnewloginzoneallocation', 'sloodle');
                    echo '</a></p>';
                }            
                
            } else if ($numsloodleentries > 1) {
                echo '<span style="color:red; font-weight:bold; border:solid 2px #990000; padding:4px; background-color:white;">';
                print_string('multipleentries', 'sloodle');
                helpbutton('multiple_entries', get_string('help:multipleentries', 'sloodle'), 'sloodle', true, false);
                echo '</span>';
            }
            echo '</p>';
            
        } else if ($searchentries) {
            // Searching for users
            echo '<span style="font-size:18pt; font-weight:bold; ">'.get_string('avatarsearch','sloodle').": \"{$this->searchstr}\"</span><br/><br/>";
            // Check to see if there are no entries
            if ($numsloodleentries == 0) {
                echo '<span style="color:red; font-weight:bold;">';
                print_string('noentries', 'sloodle');
                echo '</span>';
            }
            
        } else {
            // Assume we're listing all entries - explain what this means
            echo '<span style="font-size:18pt; font-weight:bold; ">'.get_string('allentries','sloodle').'</span><br/>';
            echo '<center><p style="width:550px; text-align:left;">'.get_string('allentries:info', 'sloodle').'</p></center>';
            
            // Check to see if there are no entries
            if ($numsloodleentries == 0) {
                echo '<span style="color:red; font-weight:bold;">';
                print_string('noentries', 'sloodle');
                echo '</span>';
            }
        }
        
        // Construct and display a table of Sloodle entries
        if ($numsloodleentries > 0) {
            $sloodletable = new stdClass(); 
            $sloodletable->head = array(    get_string('avatarname', 'sloodle'),
                                            get_string('avataruuid', 'sloodle'),
                                            get_string('profilePic', 'sloodle'),
                                            get_string('lastactive', 'sloodle'),
                                            ''
                                        );
            $sloodletable->align = array('left', 'left', 'left', 'left', 'left');
            $sloodletable->size = array('28%', '42%', '20%','20%', '10%');
            
            $deletestr = get_string('delete', 'sloodle');
            
            // We want to build a list of Sloodle user objects too
            $userobjects = array();
            // Create a dummy Sloodle Session
            $sloodle = new SloodleSession(false);
            
            // Check if our start is past the end of our results
            if ($this->start >= count($sloodleentries)) $this->start = 0;
                    
            // Go through each Sloodle entry for this user
            $resultnum = 0;
            $resultsdisplayed = 0;
            $maxperpage = 20;
            foreach ($sloodleentries as $su) {
            
                // Only display this result if it is after our starting result number
                if ($resultnum >= $this->start) {
                    // Add this user's Sloodle objects (if we're not in 'all' or search modes)
                    if (!$allentries && !$searchentries) {
                        if ($sloodle->user->load_avatar($su->uuid, '')) {
                            $userobjects += $sloodle->user->get_user_objects();
                        }
                    }
                    
                
                    // Is this entry being deleted (i.e. is the user being asked to confirm its deletion)?
                    $deletingcurrent = ($confirmingdeletion == true && $su->id == $this->deletesloodleentry);
                    
                    // Reset the line's content
                    $line = array();
                
                    // Fetch the avatar name and UUID
                    $curavname = '-';
                    $curuuid = '-';
                    if (!empty($su->avname)) $curavname = $su->avname;
                    if (!empty($su->uuid)) $curuuid = $su->uuid;
                    
                    // If we are in all or searching mode, add a link to the Sloodle user profile
                    if ($allentries || $searchentries) {
                        //$curavname .= " <span style=\"font-size:10pt; color:#444444; font-style:italic;\">(<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=user&amp;id={$su->userid}&amp;course={$this->courseid}\">".get_string('sloodleuserprofile','sloodle')."</a>)</span>";
                        $curavname = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=user&amp;id={$su->userid}&amp;course={$this->courseid}\">{$curavname}</a>";
                    }
                    // Add a red cross beside the avatar name if it is being deleted
                    if ($deletingcurrent) $curavname = '<span style="color:red; font-weight:bold;">X</span> '.$curavname;
                    
                    // Add them to the table
                    $line[] = $curavname;
                    $line[] = $curuuid; 
                    //grab image
                    $endlink="";
                    $startlink="";
                    if (empty($su->profilepic)) {
                        // There is no stored avatar picture URL.
                        // If we know the grid type and if we're only displaying the avatar(s) for a single user, then try to grab the image externally.
                        // Note that this page is also used to display a list of all avatars on the site, so we wouldn't want to do a curl request for each one.
                        if (!empty($CFG->sloodle_gridtype) && !$allentries && !$searchentries) {
                            if ($CFG->sloodle_gridtype=="SecondLife"){
                               //scrape image                 
                                 $profile_key_prefix = "<meta name=\"imageid\" content=\"";
                                 $profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
                                 $profile_img_suffix ="parcel";
                                 $url =  "http://world.secondlife.com/resident/".$curuuid;
                                 $ch = curl_init();    // initialize curl handle 
                                 curl_setopt($ch, CURLOPT_URL,$url); // set url to post to 
                                 curl_setopt($ch, CURLOPT_FAILONERROR,0); 
                                 curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable 
                                 curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s 
                                 curl_setopt($ch, CURLOPT_POST, 1); // set POST method 
                                 curl_setopt($ch, CURLOPT_POSTFIELDS,""); // add POST fields        
                                 $body= curl_exec($ch); // run the whole process 
                                 curl_close($ch); 
                                 $nameStart = strpos($body, '<title>');
                                 $nameEnd = strpos($body, '</title>');
                                 $nameStr = substr($body,$nameStart+7,$nameEnd-$nameStart-7);
                                 $imageStart = strpos($body, $profile_img_prefix);
                                 $imageEnd = strpos($body, $profile_img_suffix);
                                 $imgStr = substr($body,$imageStart+30,$imageEnd-$imageStart -39);
                                 $avimage = $imgStr;
                                 if (!$imageStart){
                                     $avimage= $CFG->wwwroot."/mod/sloodle/lib/media/empty.jpg";
                                 }else{
                                    $su->profilepic = $avimage;
                                    sloodle_update_record("sloodle_users",$su);
                                 }
                                 $startlink = '<a href="'.$url.'" target="_blank">';
                                 $endlink="</a>";
                            }else{
                                //grid type is opensim
                                $avimage= $CFG->wwwroot."/mod/sloodle/lib/media/empty.jpg";
                            }
                        }//gridtype was not specified so just put empty.pngs for the users until admin specifies gridtype
                        else{
                             $avimage= $CFG->wwwroot."/mod/sloodle/lib/media/empty.jpg";        
                            
                        }
                      
                    }//profile pic is already in db
                    else{
                        $avimage=$su->profilepic;
                    }
                          
                    $line[]=$startlink.'<img  style="width:40px;height:40px" src="'.$avimage.'">'.$endlink;       
                    // Do we know when the avatar was last active
                    if (!empty($su->lastactive)) {
                        // Calculate the time difference
                        $difference = time() - (int)$su->lastactive;
                        if ($difference < 0) $difference = 0;
                        // Add it to the table
                        $line[] = sloodle_describe_approx_time($difference, true);
                    } else {
                        $line[] = '('.$strunknown.')';
                    }
                    
                    // Display the "delete" action
                    if ($this->canedit || $su->userid == $USER->id) {
                        if ($allentries) $deleteurl = $CFG->wwwroot."/mod/sloodle/view.php?_type=user&amp;id=all&amp;course={$this->courseid}&amp;delete={$su->id}&amp;start={$this->start}";
                        else if ($searchentries) $deleteurl = $CFG->wwwroot."/mod/sloodle/view.php?_type=user&amp;id=search&amp;course={$this->courseid}&amp;search={$this->searchstr}&amp;delete={$su->id}&amp;start={$this->start}";
                        else $deleteurl = $CFG->wwwroot."/mod/sloodle/view.php?_type=user&amp;id={$this->moodleuserid}&amp;course={$this->courseid}&amp;delete={$su->id}&amp;start={$this->start}";
                        $deletecaption = get_string('clicktodeleteentry','sloodle');
                        $line[] = "<a href=\"$deleteurl\" title=\"$deletecaption\">$deletestr</a>";
                        
                    } else {
                        $line[] = '<span style="color:#777777;" title="'.get_string('nodeletepermission','sloodle').'">'.get_string('delete','sloodle').'</span>';
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
            $basicurl = SLOODLE_WWWROOT."/view.php?_type=user&amp;course={$this->courseid}";
            if ($searchentries) $basicurl .= "&amp;id=search&amp;search={$this->searchstr}";
            else if ($allentries) $basicurl .= "&amp;id=all";
            else $basicurl .= "&amp;id={$this->moodleuserid}";
            
            // Construct the next/previous links
            $previousstart = max(0, $this->start - $maxperpage);
            $nextstart = $this->start + $maxperpage;
            $prevlink = null;
            $nextlink = null;
            if ($previousstart != $this->start) $prevlink = "<a href=\"{$basicurl}&amp;start={$previousstart}\">&lt;&lt;</a>&nbsp;&nbsp;";            
            if ($nextstart < count($sloodleentries)) $nextlink = "<a href=\"{$basicurl}&amp;start={$nextstart}\">&gt;&gt;</a>";
            
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
            
        }
         
        // Display a link allowing admin users to add an avatar if this is a single avatar page
        if (!$allentries && !$searchentries)
        {

            if ( has_capability('moodle/site:viewparticipants', $this->system_context) )
            {
                echo "<p style=\"font-weight:bold;\">";
                echo "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=addavatar&amp;user={$this->moodleuserid}&amp;course={$this->courseid}\" title=\"".get_string('addavatarhere','sloodle')."\">";
                echo "<img src=\"{$CFG->wwwroot}/mod/sloodle/lib/media/add.png\" alt=\"[plus icon]\" /> ";
                print_string('addavatar', 'sloodle');
                echo "</a></p>\n";
            }
        }


        // Construct and display a table of Sloodle entries
        if ($numsloodleentries > 0) {
            
            // Display a list of user-authorised objects
            if (!$allentries && !$searchentries) {
                echo '<br/><h3>'.get_string('userobjects','sloodle');
                helpbutton('user_objects', get_string('userobjects','sloodle'), 'sloodle', true, false, '', false);
                echo "</h3>\n";
                
                
                // Have we been asked to delete the user objects?
                if ($this->deleteuserobjects == 'true') {
                    // Yes - display a confirmation form
                    echo '<h4 style="color:red; font-weight:bold;">'.get_string('confirmdeleteuserobjects','sloodle').'</h4>';
                    
                    echo '<table style="border-style:none; margin-left:auto; margin-right:auto;"><tr><td>';
                    
                    echo '<form action="'.SLOODLE_WWWROOT.'/view.php" method="GET">';
                    echo '<input type="hidden" name="_type" value="user" />';
                    echo '<input type="hidden" name="id" value="'.$this->moodleuserid.'" >';
                    if (!empty($courseid)) echo '<input type="hidden" name="course" value="'.$this->courseid.'" >';
                    echo '<input type="hidden" name="deleteuserobjects" value="confirm" >';
                    echo '<input type="hidden" name="start" value="'.$this->start.'" />';
                    echo '<input type="submit" value="'.get_string('yes').'" title="'.get_string('deleteuserobjects:help','sloodle').'" >';
                    echo '</form>';
                    
                    echo '</td><td>';
                    
                    echo '<form action="'.SLOODLE_WWWROOT.'/view.php" method="GET">';
                    echo '<input type="hidden" name="_type" value="user" />';
                    echo '<input type="hidden" name="id" value="'.$this->moodleuserid.'" >';
                    if (!empty($this->courseid)) echo '<input type="hidden" name="course" value="'.$this->courseid.'" >';
                    echo '<input type="hidden" name="start" value="'.$this->start.'" />';
                    echo '<input type="submit" value="'.get_string('no').'" >';
                    echo '</form>';
                    
                    echo '</td></tr></table><br>';
                    
                } else if ($this->deleteuserobjects == 'confirm') {
                    // Delete each one
                    $numdeleted = 0;
                    foreach ($userobjects as $obj) {
                        sloodle_delete_records('sloodle_user_object', 'id', $obj->id);
                        $numdeleted++;
                    }
                    $userobjects = array();
                    echo get_string('numdeleted','sloodle').': '.$numdeleted.'<br><br>';
                }
                
                
                // Do we have any objects to display?
                if (count($userobjects) > 0) {
                    
                    // Yes - prepare the table
                    $sloodletable = new stdClass();
                    $sloodletable->head = array(    get_string('ID', 'sloodle'),
                                                    get_string('avataruuid', 'sloodle'),
                                                    get_string('uuid', 'sloodle'),
                                                    get_string('name', 'sloodle'),
                                                    get_string('isauthorized', 'sloodle'),
                                                    get_string('lastused', 'sloodle')
                                                );
                    $sloodletable->align = array('center', 'left', 'left', 'left', 'center', 'left');
                    //$sloodletable->size = array('5%', '5%', '27%', '35%', '20%', '8%');
                    
                    // Store the current timestamp for consistency
                    $curtime = time();
                    
                    // Go through each object
                    foreach ($userobjects as $obj) {
                        $line = array();
                        $line[] = $obj->id;
                        $line[] = $obj->avuuid;
                        $line[] = $obj->objuuid;
                        $line[] = $obj->objname;
                        if ($obj->authorized) $line[] = ucwords(get_string('yes'));
                        else $line[] = ucwords(get_string('no'));
                        
                        $lastused = (int)$obj->timeupdated;
                        if ($lastused > 0) $line[] = sloodle_describe_approx_time($curtime - $lastused, true);
                        else $line[] = '('.get_string('unknown','sloodle').')';
                        
                        $sloodletable->data[] = $line;
                    }
                    
                    // Display the table
                    print_table($sloodletable);
                    
                    // Display a button to delete all the Sloodle objects
                    if (empty($deleteuserobjects)) {
                        echo '<br><form action="'.SLOODLE_WWWROOT.'/view.php" method="GET">';
                        echo '<input type="hidden" name="_type" value="user" />';
                        echo '<input type="hidden" name="id" value="'.$this->moodleuserid.'" >';
                        if (!empty($this->courseid)) echo '<input type="hidden" name="course" value="'.$this->courseid.'" >';
                        echo '<input type="hidden" name="deleteuserobjects" value="true" >';
                        echo '<input type="hidden" name="start" value="'.$this->start.'" />';
                        echo '<input type="submit" value="'.get_string('deleteuserobjects','sloodle').'" title="'.get_string('deleteuserobjects:help','sloodle').'" >';
                        echo '</form><br>';
                    }
                    
                    
                } else {
                    // No user objects
                    echo '<span style="color:red; font-weight:bold;">';
                    print_string('noentries', 'sloodle');
                    echo '</span>';
                }
            }
            
        }
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
