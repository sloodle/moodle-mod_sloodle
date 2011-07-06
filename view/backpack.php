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
* @contributor Paul Preibisch
*
*/ 

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** SLOODLE logs data structure */
require_once(SLOODLE_LIBROOT.'/course.php');
require_once(SLOODLE_LIBROOT.'/currency.php');    

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_backpack extends sloodle_base_view
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
        
        $id = required_param('id', PARAM_INT);
        
        if (!$this->course = get_record('course', 'id', $id)) error('Could not find course.');
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
        if (has_capability('moodle/course:update', $this->course_context)) $this->can_edit = true;
    }

    /**
    * Print the course settings page header.
    */
    function print_header()
    {
        global $CFG;
        $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view_backpack.php?id={$this->course->id}\">".get_string('backpack:view', 'sloodle')."</a>";
        print_header_simple(get_string('backpack','sloodle'), "", $navigation, "", "", true, '', navmenu($this->course));
        
    }


    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {                                      
        global $CFG;      

        $view = optional_param('view', "");
        // Setup our list of tabs
        // We will always have a view option
        
        echo "<div style=\"text-align:center;\">\n";

		$action = optional_param('action', "");                 

		$contextid = get_context_instance(CONTEXT_COURSE,$this->course->id);

		//$sloodle_currency= new SloodleCurrency();
		//$cTypes=    $sloodle_currency->get_currency_types();
        
        echo "<br>";
		print_box_start('generalbox boxaligncenter left boxwidthnarrow boxheightnarrow leftpara');
        echo "<h1 color=\"Red\"><img align=\"center\" src=\"{$CFG->SLOODLE_WWWROOT}lib/media/backpack64.png\" /> ";
		echo get_string('backpacks:backpacks', 'sloodle');
        echo "&nbsp<img align=\"center\" src=\"{$CFG->SLOODLE_WWWROOT}lib/media/backpack64.png\" /></h1>";        
		print_box_end();

		//display the select box for the user select box

		$contextid = get_context_instance(CONTEXT_COURSE,$this->course->id);
		$courseid = $this->course->id;

		// Fetch the balance for each user, for each course. 
		// Should include people who are in the course, but do not yet have any points.
		$sql = "select u.id as userid, u.firstname as firstname, u.lastname as lastname, su.avname as avname, sum(p.amount) as balance, c.id as currencyid, c.name as currencyname from {$CFG->prefix}user u left outer join {$CFG->prefix}sloodle_users su on u.id=su.userid inner join {$CFG->prefix}role_assignments ra on u.id  inner join {$CFG->prefix}sloodle_award_points p on u.id=p.userid inner join {$CFG->prefix}sloodle_award_rounds ro on p.roundid=ro.id inner join {$CFG->prefix}sloodle_currency_types c on c.id=p.currencyid where ra.contextid=".intval($contextid)." and ro.courseid=".intval($courseid)." group by u.id, p.currencyid order by lastname asc, firstname asc, avname asc;";
//print $sql;

		$currencynames = array();
		$userdetail = array();	

		//Moodle userid, then currency id, then balance of points
		// eg. $usercurrencybalance[2][10] = 123;
		$usercurrencybalance = array();

		$recs = get_records_sql($sql);

		foreach($recs as $rec) {
			$userid = $rec->userid;
			$currencyid = $rec->currencyid;	
			if (!isset($currencynames[ $currencyid ] )) {
				$currencynames[ $currencyid ] = $rec->currencyname;
			}
			if (!isset($userdetail[ $userid ] ) ){
				$userdetail[ $userid ] = array(
					'firstname' => $rec->firstname,
					'lastname' => $rec->lastname,
					'avname' => $rec->avname
				);
			}
			if (!isset($usercurrencybalance[ $userid ] )) {
				$usercurrencybalance[ $userid ] = array();
			}
			$usercurrencybalance[ $userid ][ $currencyid ] = $rec->balance;
		}

		$sloodletable = new stdClass(); 
              
		$headerrow = array();

		$headerrow[] = s(get_string('awards:avname', 'sloodle'));
		$headerrow[] = s(get_string('awards:firstname', 'sloodle'));
		$headerrow[] = s(get_string('awards:lastname', 'sloodle'));
		foreach($currencynames as $currencyname) {
			$headerrow[] = s($currencyname);
		}
		
		$sloodletable->head = $headerrow;

		//set alignment of table cells                                        
		$aligns = array('left', 'left', 'left');
		foreach($currencynames as $cn) {
			$aligns[] = 'right';
		}

		$sloodletable->align = $aligns;
		$sloodletable->width="95%";
		//set size of table cells
		//$sloodletable->size = array('10%','10%', '15%','*','*');            

		foreach($usercurrencybalance as $userid => $currencybalancearray) {

			$row = array();
			$row[] = s($userdetail[ $userid ]['avname']);
			$row[] = s($userdetail[ $userid ]['firstname']);
			$row[] = s($userdetail[ $userid ]['lastname']);
			foreach($currencynames as $currencyid=>$currencyname) {
				if ( isset($currencybalancearray[ $currencyid ] ) ) {
					$row[] = s($currencybalancearray[ $currencyid ]);
				} else {
					$row[] = ' 0 ';
				}
			}

			$sloodletable->data[] = $row;

		}

                $sloodletable->data[] = $trowData; 

		print_table($sloodletable); 
        
        
        echo "</div>\n";
 
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
