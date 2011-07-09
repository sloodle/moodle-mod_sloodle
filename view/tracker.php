<?php
/**
* Defines a class for viewing the SLOODLE Second Life Tracker module in Moodle.
* Derived from the module view base class.
*
*/

/** The base module view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view_module.php');
/** The SLOODLE Session data structures */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');



/**
* Class for rendering a view of a Second Life Tracker module in Moodle.
* @package sloodle
*/
class sloodle_view_tracker extends sloodle_base_view_module
{

    /**
    * When multiple users will be displayed, this value indicates which record to start from.
    * It will be read from HTTP parameters.
    * @var int
    * @access private
    */
    var $start = 0;

    /**
    * Number of users to display per page.
    * @var int
    * @access private
    */
    var $usersPerPage = 10;

    /**
    * The number of the page of users to be displayed.
    * 1-based.
    * @var int
    * @access private
    */
    var $page = 1;

    /**
    * Constructor.
    */
    function sloodle_view_tracker()
    {
    }

    /**
    * Processes request data to determine which Second Life Tracker is being accessed.
    */
    function process_request()
    {
        // Process the basic data
        parent::process_request();

        $this->page = optional_param('page', 1, PARAM_INT);
        if ($this->page < 1) $this->page = 1;
        $this->start = ($this->page - 1) * $this->usersPerPage;

        // Nothing else to get just now
    }

    /**
    * Process any form data which has been submitted.
    */
    function process_form()
    {
    }

	/**
	* Get the students enroled in this course.
	* @return $userlist: A list with the users, empty if there are no users enroled
	*/
	function get_class_list()
    {
        $userlist = array();
        
        // Ideally, use the capability-based user search.
        // This may not exist in particularly early versions of Moodle 1.8 and 1.9.
        // Fall-back on the function to get all users in a course if necessary,
        //  but note that it is a deprecated function, and it only seems to return students.
        if (function_exists('get_users_by_capability'))
        {
            $userlist = get_users_by_capability($this->course_context, 'moodle/course:view', 'u.id, u.firstname, u.lastname', 'u.firstname, u.lastname');
        }
        else
        {
            $userlist = get_course_users($this->courseid, 'firstname, lastname', '', 'u.id, firstname, lastname');
        }

        // Return an empty array if something went wrong
        if (!$userlist) return array();        
        return $userlist;
    }

    /**
    * Render the view of the SecondLife Tracker.
    */
    function render()
    { 
   		global $CFG, $USER;   
   		
   		$session = new SloodleSession(false);
        $tracker = new SloodleModuleTracker($session);
        
        // Check if this user is allowed to view all users in this activity, and if s/he is allowed to manage this activity
        $canManage = $this->canedit;
        
        // Load data of the current Second Life Tracker
        if (!$tracker->load($this->cm->id)) error("FAILED TO LOAD MODULE");
     
	    $this->courseid = $this->course->id; 
        $sloodleid=$this->sloodle->id;
        
        if ($canManage)
        {
            $strtrackeradmin = get_string('trackeradmin', 'sloodle');
            $strresetallprogress = get_string('resetallprogress', 'sloodle');
            $strdeletealltasks = get_string('deletealltasks', 'sloodle');
        
            echo <<<XXXEODXXX
<table style="margin:auto auto; ">
<!--<tr><th colspan="2">{$strtrackeradmin}</th></tr>-->
 <tr>
  <td style="text-align:center;">
   <form action="" method="POST" style="padding:6px;">
    <input type="hidden" name="id" value="{$this->cm->id}"/>
    <input type="hidden" name="action" value="reset_all_progress"/>
    <input type="submit" value="{$strresetallprogress}"/>
   </form>
  </td>
  <td style="text-align:center;">
   <form action="" method="POST" style="padding:6px;">
    <input type="hidden" name="id" value="{$this->cm->id}"/>
    <input type="hidden" name="action" value="delete_all_tasks"/>
    <input type="submit" value="{$strdeletealltasks}"/>
   </form>
  </td>
 </tr>
</table>
XXXEODXXX;
        }
 
        print('<h3 style="color:black;text-align:center;">'.get_string('secondlifetracker:activity','sloodle')).'</h3> '; 

        // Check if some kind of action has been requested, used if tasks has been reset
        $action = optional_param('action', '', PARAM_TEXT);
        
        // Has a reset task progress action been requested?
        if ($action == 'reset_tasks' && $canManage)
        {
            // Go through each request parameter
            foreach ($_REQUEST as $name => $val)
            {
                if ($val != 'true') continue;
                $parts = explode('_', $name);
                if (count($parts) == 2 && $parts[0] == 'sloodledeleteobj')
                {
                    // Only delete the activity if it belongs to this controller
                    delete_records('sloodle_activity_tracker', 'trackerid', $this->cm->id, 'id', (int)$parts[1]);                        
                }
            }
        }

        // Has a reset all tasks action been requested? (This deletes all activities from the module)
        if ($action == 'delete_all_tasks' && $canManage)
        {
            delete_records('sloodle_activity_tracker', 'trackerid', $this->cm->id);
            delete_records('sloodle_activity_tool', 'trackerid', $this->cm->id);
        }

        // Has a reset all progress action been requested?
        if ($action == 'reset_all_progress' && $canManage)
        {
            delete_records('sloodle_activity_tracker', 'trackerid', $this->cm->id);
        }


        //Obtain the users in this course  
        $userlist = $this->get_class_list();
          
        if ($userlist) {          

            // How many pages of users are there?
            $numresults = count($userlist);
            $numpages = (int)ceil($numresults / $this->usersPerPage);
            if ($this->page > $numpages) $this->page = $numpages;
            $this->start = ($this->page - 1) * $this->usersPerPage;
                     
            $sloodletable = new stdClass();
            
            // Create column headers for html table
            $sloodletable->head = array(    get_string('user', 'sloodle'),
                                            get_string('avatar', 'sloodle'),
                                        );
            // Set alignment of table cells                                        
            $sloodletable->align = array('center', 'center');
            // Set size of table cells
            $sloodletable->size = array('50%', '50%');
            
            // Check if our start is past the end of our results
            if (empty($this->start) || $this->start >= count($userlist)) $this->start = 0;
            // Ignore the start parameter if the user can only see his/her own record
            if (!$canManage) $this->start = 0;
            
		    $resultnum = 0;
            $resultsdisplayed = 0;
                       
            // Go through each user
            foreach ($userlist as $u)
            {
            
                // Skip until the desired start point of the results
                if ($resultnum < $this->start)
                {
                    $resultnum++;
                    continue;
                }

                // If this user is not a teacher, and this is not the user's own details, then skip this iteration
                if (!($u->id == $USER->id || $canManage)) continue;
            	
            	// This variable will contain the avatar identifier, necessary to search in the "sloodle_activity_tracker" DB table.
            	$avatarid = '';
            	
            	// These variables will be used to obtain the overall percentage of tasks completed
            	$tasks = 0;
            	$completed = 0;
                
                // Only display this result if it is after our starting result number
                //if ($resultnum >= $this->start) {
                    
                    // Reset the line's content
                    $line = array();
                    
                    // Construct URLs to this user's Moodle and SLOODLE profile pages
                    $url_moodleprofile = $CFG->wwwroot."/user/view.php?id={$u->id}&amp;course={$this->courseid}";
                    $url_sloodleprofile = SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$u->id}&amp;course={$this->courseid}";                                   
                    // Add the Moodle name
                    $line[0] = "<a href=\"{$url_moodleprofile}\">{$u->firstname} {$u->lastname}</a>";                    
                    
                    // Get the Sloodle data for this Moodle user
                    $sloodledata = get_records('sloodle_users', 'userid', $u->id, 'uuid, avname');
                    
                   // Initialize our search index    
                    /////////////////////////////////////////////////////////////////////////$dateIndex=false;
                    
                    if ($sloodledata)
                    {
                    
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
                            $avatarid = $sd->uuid;           
                        }
                        
                        // Add the avatar name(s) to the line
                        $line[1] = "<a href=\"{$url_sloodleprofile}\">{$avnames}</a>";   
                                             
                    } else {
                        // The query failed - if we are showing only Sloodle-enabled users, then skip the rest
                        if (!empty($this->sloodleonly) && $this->sloodleonly) continue;
                        $line[1] = get_string('secondlifetracker:noavatar','sloodle');                       
                    }
                    $sloodletable->data[0] = $line;  
                    $resultsdisplayed++;
                //}
                
                print_table($sloodletable);

				//Now all the tasks in the Tracker are displayed
				echo "<div style=\"text-align:center;\">\n";
        		//echo '<h3>'.get_string('secondlifetasks','sloodle').'</h3>';
                echo "<br/>";
        		
        		// Get all the tasks for this Tracker, ordered by "taskname"
       		 	$recs = get_records('sloodle_activity_tool', 'trackerid', $this->cm->id, 'taskname');
            
            	if (is_array($recs) && count($recs) > 0)
                {
                	
                	$objects_table = new stdClass();
                	
                	// Create column headers for html table
                	$objects_table->head = array(get_string('objectname','sloodle'),get_string('secondlifeobjdesc','sloodle'),get_string('secondlifelevelcompl','sloodle'),'Date','');
                	// Set alignment of table cells 
                	$objects_table->align = array('left', 'left', 'centre', 'centre', 'centre');
                	$overall = 0;
                    
                	foreach ($recs as $obj) {
                 	    // Skip this object if it has no type information
                 	    if (empty($obj->type)) continue;
                   	    
                  	    //Has this user completed the task?
                  	    $act = get_record('sloodle_activity_tracker','avuuid',$avatarid,'objuuid',$obj->uuid,'trackerid',$this->cm->id);
                  	    
                  	    //Yes. Activity completed
						if (!empty($act)){
						    $timezone = $act->timeupdated - 3600;          
						    $date = date("F j, Y, g:i a", $timezone);   
						    
						    // Only the admin can reset tasks  
						    if ($canManage)
                            {
                   	 			$objects_table->data[] = array('<span style="text-align:center;">'.$obj->taskname.'</a>', $obj->description, '<span style="text-align:center;color:green;">'.get_string('secondlifetracker:completed','sloodle').'</span><br>',$date,"<input type=\"checkbox\" name=\"sloodledeleteobj_{$act->id}\" value=\"true\" /");
                   	 		}
                   	 		else {
                   	 			$objects_table->data[] = array('<span style="text-align:center;">'.$obj->taskname.'</a>', $obj->description, '<span style="text-align:center;color:green">'.get_string('secondlifetracker:completed','sloodle').'</span><br>',$date,' - ');
                            }
                   	 		$tasks += 1;
                   	 		$completed += 1;
                		}
                		//No. Activity not completed
                		else {
                   	 		$objects_table->data[] = array('<span style="text-align:center;">'.$obj->taskname.'</a>', $obj->description, '<span style="text-align:center;color:red">'.get_string('secondlifetracker:notcompleted','sloodle').'</span><br>',' - ',' - ');
                   	 		$tasks += 1;
                		}
                		
                		//Overall percentage of tasks completed?
                        $overall = 0;
                        if ($tasks > 0) $overall = ((integer)(($completed / $tasks) * 1000.0)) / 10.0;
                	}    
                	
                	// If is the admin, show the reset button
                	if ($canManage){
                		echo '<form action="" method="POST">';
                    	echo '<input type="hidden" name="id" value="'.$this->cm->id.'"/>';
                   		echo '<input type="hidden" name="action" value="reset_tasks"/>';
                   		
                   		print_table($objects_table);
                   		echo '<h3>Completed: '.$overall.'%</h3>';
                   		echo '<input type="submit" value="'.get_string('resettasks','sloodle').'"/>';
                        echo '</form>';
            		}
                	else
                	{
                		print_table($objects_table);
                   		echo '<h3>Completed: '.$overall.'%</h3>';
                   	}
            	}
            	//No tasks in the Tracker
            	else {
                	echo '<span style="text-align:center;color:red">'.'No tasks found'.'</span><br>';
            	}
            	//echo '<p>&nbsp;</p>';
                echo "<br/><hr><br/>";
        		echo "</div>\n";
                                
                // Have we displayed the maximum number of results for this page?
                $resultnum++;
                if ($resultsdisplayed >= $this->usersPerPage) break;
            }
                        
            $basicurl = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;course={$this->courseid}";  

            // Construct the links for page navigation
            $prevlink = ""; $nextlink = "";
            if ($this->page > 1)
            {
                $prevpage = $this->page - 1;
                $prevlink = "<a href=\"{$basicurl}&amp;page={$prevpage}\">&lt;&lt;</a>&nbsp;&nbsp;";
            } else {
                $prevlink = "<span style=\"color:#777777;\">&lt;&lt;</span>&nbsp;&nbsp;";
            }

            if ($this->page < $numpages)
            {
                $nextpage = $this->page + 1;
                $nextlink = "&nbsp;&nbsp;<a href=\"{$basicurl}&amp;page={$nextpage}\">&gt;&gt;</a>";
            } else {
                $nextlink = "&nbsp;&nbsp;<span style=\"color:#777777;\">&gt;&gt;</span>";
            }

            // Display the page navigation
            echo "<div style=\"text-align:center; font-size:130%; font-weight:bold;\">";
            echo $prevlink;
            $pagenav = new stdClass();
            $pagenav->num = $this->page;
            $pagenav->total = $numpages;
            print_string('pagecount', 'sloodle', $pagenav);
            echo $nextlink;
            echo "</div>";

    	}
    	//No users enroled in the course
    	else {
    		echo "<div style=\"text-align:center;\">\n";
            echo '<span style="color:red">'.get_string('tracker:nousers','sloodle').'</span><br>';
        }
    }   
}

?>
