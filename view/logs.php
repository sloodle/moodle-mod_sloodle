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
/** SLOODLE logs data structure */
require_once(SLOODLE_LIBROOT.'/course.php');

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_logs extends sloodle_base_view
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
    function sloodle_view_logs()
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
        $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view_logs.php?id={$this->course->id}\">".get_string('logs:view', 'sloodle')."</a>";
        print_header_simple(get_string('logs:view','sloodle'), "", $navigation, "", "", true, '', navmenu($this->course));
    }


    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {
        
        global $CFG;
        global $sloodle;
        // Display info about Sloodle course configuration
        echo "<h1 style=\"text-align:center;\">".get_string('logs:sloodlelogs','sloodle')."</h1>\n";
        

      // print_box(get_string('logs:info','sloodle'), 'generalbox boxaligncenter boxwidthnormal');
        $sloodletable = new stdClass(); 
         $sloodletable->head = array(                         
             '<h4><div style="color:red;text-align:left;">'.get_string('avatarname', 'sloodle').'</h4>',
             '<h4><div style="color:red;text-align:left;">'.get_string('user').'</h4>',
             '<h4><div style="color:green;text-align:left;">'.get_string('action').'</h4>',             
             '<h4><div style="color:green;text-align:left;">'.get_string('logs:slurl', 'sloodle').'</h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('logs:time', 'sloodle').'</h4>');             
              //set alignment of table cells                                        
            $sloodletable->align = array('left','left','left','left','left');
            $sloodletable->width="95%";
            //set size of table cells
            $sloodletable->size = array('15%','10%', '50%','5%','20%');

         $logData = sloodle_get_records('sloodle_logs','course',$this->sloodle_course->get_course_id(), 'timemodified DESC');
          
        
        if ($logData && count($logData)>0){
                foreach ($logData as $ld){
                    $trowData= Array();        
                         $link_url=' <a href="'.$CFG->wwwroot.'/user/view.php?id='.$ld->userid."&amp;course=";
                         $link_url.=$this->sloodle_course->get_course_id().'">'.$ld->avname."</a>";
                         $trowData[]=$link_url;    
                         $userData = sloodle_get_record('user','id',$ld->userid);
                         $username= $userData->firstname.' '.$userData->lastname;                         
                         $trowData[]=$username;    
                         $trowData[]=$ld->action;    
                         $trowData[]='<a href="'.$ld->slurl.'">'.get_string('logs:slurl', 'sloodle').'</a>';    
                         $trowData[]=date("F j, Y, g:i a",$ld->timemodified);             
                         $sloodletable->data[] = $trowData;                     
                }//for
             
            }
            else
            {
                $trowData[]=get_string('logs:nologs', 'sloodle');
                $sloodletable->data[] = $trowData;
            }
        
        print_table($sloodletable); 
        
 
 
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
