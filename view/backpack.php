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
* @contributor Edmund Edgar
* @contributor Paul Preibisch
*
*/ 

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** SLOODLE logs data structure */
require_once(SLOODLE_LIBROOT.'/course.php');
require_once(SLOODLE_LIBROOT.'/currency.php');    

// Javascript for checking and unchecking checkboxes
require_js($CFG->wwwroot . '/mod/sloodle/lib/jquery/jquery-1.3.2.min.js');
require_js($CFG->wwwroot . '/mod/sloodle/lib/js/backpack.js');

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_backpack extends sloodle_base_view
{
   /**
    * The Moodle course object, retrieved directly from database.
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
    * Constructor.
    */
    function sloodle_view_backpack()
    {
        
        
    }

    /**
    * Check the request parameters to see which course was specified.
    */
    function process_request()
    {
        global $USER;

        $userIds = optional_param('userIds', PARAM_INT);
        $id = required_param('id', PARAM_INT);

        //has itemAdd forum been submitted?
        $isItemAdd= optional_param('isItemAdd',0, PARAM_INT);

        //check if valid course
        if (!$this->course = sloodle_get_record('course', 'id', $id)) error('Could not find course.');
        $this->sloodle_course = new SloodleCourse();
        if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));

        //itemAdd form has been submitted
        if ($isItemAdd) {

            $controllerid = required_param('controllerid', PARAM_INT);

            //fetch all currencies
            $all_currencies = SloodleCurrency::FetchIDNameHash();

            //create controller so we can fetch active round
            $controller = new SloodleController();
            $controller->load_by_course_module_id($controllerid);
            $roundid = $controller->get_active_roundid(true);

            //go through each currency and see if it has been set, if it has, we have to update each user who
            //has been checked
            foreach($all_currencies as $currencyid => $currencyname) {

                //check if a currency update is necessary for this currency
                //build the currencyname field  for this currency
                $fieldname="currency_".$currencyid;

                //now see if it was submitted
                $fieldvalue= optional_param($fieldname,0,PARAM_INT);

                //if no value has been submitted for this currency, we can skip adding this currency to the users!
                if ($fieldvalue==0) {
			continue;
		}

                foreach ($userIds as $u) {
                    //go through each user which was checked and give them the selected currency and amount
                    //create backpack item
                    $backpack_item = new stdClass();
                    $backpack_item->currencyid=intval($currencyid);
                    $backpack_item->userid=intval($u);
                    $backpack_item->amount=intval($fieldvalue);
                    $backpack_item->timeawarded=time();
                    $backpack_item->roundid=$roundid;
                    $backpack_item->description="moodle add by ". $USER->username;

                    //add it to the users backpack                    
                    sloodle_insert_record('sloodle_award_points',$backpack_item);
                } 
            } 
        } 
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
        if (has_capability('moodle/course:update', $this->course_context)) $this->can_edit = true;
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
        global $CFG;
        
        //print breadcrumbs
        $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?_type=backpack&id={$this->course->id}\">";
        $navigation .= get_string('backpack:view', 'sloodle');
        $navigation .= "</a>";
        //print the header
        print_header_simple(get_string('backpack','sloodle'), "", $navigation, "", "", true, '', navmenu($this->course));
    }
    
    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {                                      
        global $CFG;      
        global $COURSE;
        $view = optional_param('view', "");
        
        // Setup our list of tabs
        // We will always have a view option
	$action = optional_param('action', "");                 
	$context = get_context_instance(CONTEXT_COURSE,$this->course->id);
        echo "<br>";
        
        //print titles
        print_box_start('generalbox boxaligncenter center  boxheightnarrow leftpara');                  

	echo '<div style="position:relative ">';
	echo '<span style="position:relative;font-size:36px;font-weight:bold;">';
        
        //print return to backpack icon
        echo '<img align="center" src="'.$CFG->SLOODLE_WWWROOT.'lib/media/backpack64.png" width="48"/>';
        
        //print return to backpack title text
        echo s(get_string('backpacks:backpacks', 'sloodle'));
        echo '</span>';
        echo '<span style="float:right;">';
        echo '<a  style="text-decoration:none" href="'.$CFG->wwwroot.'/mod/sloodle/view.php?_type=currency&id='.$COURSE->id.'">';
        echo s(get_string('currency:View Currencies', 'sloodle')).'<br>';
        
        //print return to currencies icon
        echo '<img src="'.$CFG->SLOODLE_WWWROOT.'lib/media/returntocurrencies.png"/></a>';
        echo '</span>';
	echo '</div>';
        echo '<br>';
        echo '<span style="position:relative;float:right;">';
        echo '</span>';
        
        //get all currency names
	$all_currencies = SloodleCurrency::FetchIDNameHash();
	$active_currency_ids = array();

	$contextid = $context->id;
	$courseid = $this->course->id;


	$prefix = $CFG->prefix;
		
        //build scoresql 
        $scoresql = "select max(p.id) as id, p.userid as userid, p.currencyid as currencyid, sum(amount) as balance
		 from {$prefix}sloodle_award_points p inner join {$prefix}sloodle_award_rounds ro on ro.id=p.roundid 
		 where ro.courseid = ? group by p.userid, p.currencyid order by balance desc;
	";
        $scores = sloodle_get_records_sql_params( $scoresql, array( $courseid ) );
        
        //build usersql
        $usersql = "select max(u.id) as userid, u.firstname as firstname, u.lastname as lastname, 
		su.avname as avname from {$prefix}user u inner join ${prefix}role_assignments ra on u.id 
		left outer join ${prefix}sloodle_users su on u.id=su.userid where ra.contextid=?
		group by u.id order by avname asc;
	";
        $students = sloodle_get_records_sql_params( $usersql, array( $contextid ) );
        
        //create an array by userid
	$students_by_userid = array();
        foreach($students as $student) {
                $students_by_userid[ $student->userid ] = $student;
        }
        
        // students with scores, in score order
        $student_scores_by_currency_id = array();
        
        //creating a two dimensional array keyed by user id, then by currency for our display table
        foreach($scores as $score) {
		$userid = $score->userid;
		$currencyid = $score->currencyid;
		$active_currency_ids[ $currencyid ] = true;

		// if student is deleted from course but their score is still there, dont display their score
		if (!isset($students_by_userid[ $userid ])) { 
			continue;
		}
			
		//makes sure every student has an array entry 
		if ( !isset( $student_scores_by_currency_id[$userid] ) ) {
			$student_scores_by_currency_id[$userid] = array();
		}
        
		//put the students balance in the currency into the array
		$student_scores_by_currency_id[$userid][$currencyid] = $score->balance;
        }
        
        // students without scores to the end of the array, in scored order
	foreach($students_by_userid as $userid => $student) {
        	if (isset($student_scores_by_currency_id[ $userid ] )) {
				continue; // already done
		}
		$student_scores_by_currency_id[ $userid ] = array();
	}

        //now build display table
	$sloodletable = new stdClass(); 
        
        //create header
	$headerrow = array();
	$headerrow[] = s(get_string('awards:avname', 'sloodle'));
	$headerrow[] = s(get_string('awards:username', 'sloodle'));
	foreach($all_currencies as $currencyid => $currencyname) {
		$headerrow[] = s($currencyname);
	}
        $headerrow[] = '<input type="checkbox" id="checkall" checked>';
	    
        //now add the header we just built
    	$sloodletable->head = $headerrow;
        
	//set alignment of table cells 
	$aligns = array('center','center'); // name columns
	foreach($all_currencies as $curr) {
		$aligns[] = 'right'; // each currency
	}
	$aligns[] = 'center'; // checkboxes
	$sloodletable->align = $aligns;
	$sloodletable->width="95%";
   
        //now display scores
	foreach($student_scores_by_currency_id as $userid => $currencybalancearray) {
		$student = $students_by_userid[ $userid ];
		$row = array();
        $url_moodleprofile = $CFG->wwwroot."/user/view.php?id={$userid}&amp;course={$COURSE->id}";
        $url_sloodleprofile = SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$userid}&amp;course={$COURSE->id}";
		$row[] = "<a href=\"{$url_sloodleprofile}\">".s($student->avname)."</a>";
        
		$row[] = "<a href=\"{$url_moodleprofile}\">".s($student->firstname).' '.s($student->lastname)."</a>";
		foreach(array_keys($all_currencies) as $currencyid) {
			if ( isset($currencybalancearray[ $currencyid ] ) ) {
				$row[] = s($currencybalancearray[ $currencyid ]);
			} else {
				$row[] = ' 0 ';
			}
		}
		$row[] = '<input type="checkbox" checked name="userIds[]" value="'.intval($userid).'">';
		$sloodletable->data[] = $row;
	}

        $sloodletable->data[] = $trowData; 
        //create an extra row for the modify currency fields
        $row = array();
        $row[] = ' &nbsp; ';
        $row[] = ' &nbsp; ';
        foreach($all_currencies as $currencyid => $currencynames) {
		$row[] = ' &nbsp; ';
        }     

        //build select drop down for the controllers in the course that any point updates will be linked too
        $rowText='<select style="left:20px;text-align:left;" name="controllerid">';

        //get all controllers
        $recs = sloodle_get_records('sloodle', 'type', SLOODLE_TYPE_CTRL);
        
        // Make sure we have at least one controller
        if ($recs == false || count($recs) == 0) {
		error(get_string('objectauthnocontrollers','sloodle'));
		exit();
        }

        foreach ($recs as $controller){
                $rowText.='<option name="controllerid" value="'.intval($controller->id).'">'.s($controller->name).'</option>';
	}
	$rowText.='</select>';

	//add controller select cell to row       
	$row[] =$rowText; 

	//now add the row to the table
	$sloodletable->data[] = $row; 

	//create another row for the submit button 
	$row = array();
	$row[] = '&nbsp;';
	$row[] = '&nbsp;';
	foreach($all_currencies as $currencyid => $currencynames) {
		$row[] = '<input type="text" name="currency_'.$currencyid.'">';
	} 
	$row[]='<input type="submit" value="Update Backpacks">';
	$sloodletable->data[] = $row;  

        print('<form action="" method="POST">');
        echo '<input type="hidden" name="isItemAdd" value="1">';
	print_table($sloodletable); 
	print '</form>';

	print_box_end(); 
    }
  
    /**
    * Print the footer for this course.
    */
    function print_footer()
    {
        global $CFG;
        echo "<p style=\"text-align:center; margin-top:32px; font-size:90%;\"><a href=\"{$CFG->wwwroot}/course/view.php?id={$this->course->id}\">&lt;&lt;&lt; ".get_string('backtocoursepage','sloodle')."</a></h2>";
        print_footer($this->course);
    }

}

?>
