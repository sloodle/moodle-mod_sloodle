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
* @contributor Paul Preibisch
* @contributor Edmund Edgar
*
*/ 
define('SLOODLE_ALL_CURRENCIES_VIEW', 1);

/** The base view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view.php');
/** SLOODLE logs data structure */
require_once(SLOODLE_LIBROOT.'/course.php');
require_once(SLOODLE_LIBROOT.'/currency.php');    

/**
* Class for rendering a view of SLOODLE course information.
* @package sloodle
*/
class sloodle_view_currency extends sloodle_base_view
{
   /**
    * The Moodle course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $course = 0;

    var $can_edit = false;

    /**
    * SLOODLE course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $sloodle_course = null;

    var $sloodle_currency = null;

    /**
    * Constructor.
    */
    function sloodle_view_currency()
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
        if (!$this->sloodle_course->load($this->course)) error(s(get_string('failedcourseload', 'sloodle')));

     }

     function process_form()
     {

	//mode is for the different editing tasks of the currency screen (add, modify, delete)
        $mode = optional_param('mode', PARAM_INT); 

        switch($mode){

            case "modify":

                //get vars
                $currencyid = required_param('currencyid', PARAM_INT);        
                $currencyname = required_param('currencyname', PARAM_TEXT);        
                $imageurl = required_param('imageurl', PARAM_URL);        
                $displayorder = required_param('displayorder', PARAM_INT);        
                
                //create update object
                $currency = new stdClass();
                $currency->id = $currencyid;
                $currency->name = $currencyname;
                $currency->displayorder = $displayorder;                
		$currency->imageurl = ($imageurl != "") ? $imageurl : null;

                //update
                $result = update_record('sloodle_currency_types',$currency);
                if (!$result) {
                    $errorlink = $CFG->wwwroot."/mod/sloodle/view.php?_type=currency&id={$id}";
                    print_error(get_string('general:fail','sloodle'),$errorlink);
                }

            break;
            case "add":

                //get vars
                $currencyname = required_param('currencyname', PARAM_TEXT);        
                $imageurl = optional_param('imageurl', '', PARAM_URL);        
                $displayorder = optional_param('displayorder', 0, PARAM_INT);        

                //create update object
                $currency = new stdClass();
                $currency->name=$currencyname;
                $currency->displayorder = $displayorder;
                $currency->imageurl = $imageurl;

                //update
                $result = insert_record('sloodle_currency_types',$currency);
                if (!$result) {
                    $errorlink = $CFG->wwwroot."/mod/sloodle/view.php?_type=currency&id={$id}";
                    print_error(get_string('general:fail','sloodle'),$errorlink);
                }

            break;
            
            case "confirmdelete":
                     
                 $currencyid= required_param('currencyid', PARAM_INT);        
                 $result = delete_records('sloodle_currency_types','id',$currencyid);
                 
                 if (!$result) {
                     $errorlink = $CFG->wwwroot."/mod/sloodle/view.php?_type=currency&id={$id}";
                     print_error(get_string('general:fail','sloodle'),$errorlink);
                 }
               
            break;
            
            default:
                break;
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
    function print_header() {
    
        global $CFG;
        $id = required_param('id', PARAM_INT);
        $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?&_type=currency&mode=allcurrencies&id={$id}\">".get_string('currencies:view', 'sloodle')."</a>";
        print_header_simple(get_string('backpack','sloodle'), "", $navigation, "", "", true, '', navmenu($this->course));
        
    }


    /**
    * Render the view of the module or feature.
    * This MUST be overridden to provide functionality.
    */
    function render()
    {                                      
        $view = optional_param('view', "");
        $mode= optional_param('mode', "allcurrencies");
        switch ($mode){
            case "allcurrencies": 
                $this->render_all_currencies();
            break;
            case "editcurrency":
		$this->render_edit_currency();
            break;
            case "deletecurrency":
		$this->delete_currency();
            break;
            default:
		$this->render_all_currencies();
            break;
        }
    }
    
      function render_all_currencies(){
          
           global $CFG;      
           global $COURSE;                          

           $id = required_param('id', PARAM_INT);

            // Display instrutions for this page        
           echo "<br>";
           print_box_start('generalbox boxaligncenter center  boxheightnarrow leftpara');
           
           echo '<div style="position:relative ">';                                                                    
                                         
           echo '<span style="position:relative;font-size:36px;font-weight:bold;">';
           echo '<img align="center" src="'.$CFG->SLOODLE_WWWROOT.'lib/media/vault48.png" width="48"/>';
           echo get_string('currency:currencies', 'sloodle');
           echo '</span>';
           
               echo '<span style="float:right;">';
               echo '<a  style="text-decoration:none" href="'.$CFG->wwwroot.'/mod/sloodle/view.php?_type=backpack&id='.$COURSE->id.'">';
               echo get_string('backpacks:View Backpacks', 'sloodle').'<br>';
               echo '<img  src="'.$CFG->SLOODLE_WWWROOT.'lib/media/returnbackpacks.png"/></a>';
               echo '</span>';                                                                                                         
           
           echo '</div>';
           
            //create an html table to display the users      
            $sloodletable = new stdClass(); 

                $sloodletable->head = array(                         
                    s(get_string('currencies:displayorder', 'sloodle')),
                    s(get_string('currencies:icon', 'sloodle')),
                    s(get_string('currencies:name', 'sloodle')),
                    ""
                );
                
                //set alignment of table cells                                        
                $sloodletable->align = array('left','left','left');
                $sloodletable->width="95%";
                //set size of table cells
                $sloodletable->size = array('10%','5%','50%','45%','25%');            
                //get currencies 
                //get_records($table, $field='', $value='', $sort='', $fields='*', $limitfrom='', $limitnum='')
                $currencyTypes = SloodleCurrency::FetchAll();

                foreach ($currencyTypes as $c){
                  $rowData=array();
                  //cell 1 - display order
                  $rowData[]= $c->displayorder;
                  //cell 2 - image icon
                  if (isset($c->imageurl)){
                      $rowData[] = '<img src="'.$c->imageurl.'" width ="20px" height="20px">'; 
                  } else {
                      $rowData[] = "";
                  }
                  //cell 3 - currency name
                  $rowData[]= $c->name;
                  //cell 4 - image url
                 // $rowData[]= $c->imageurl;
                  //cell 5 - edit action
                      $editText= "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?&";
                      $editText.= "_type=currency";
                      $editText.= "&currencyid=".$c->id;
                      $editText.= "&currencyname=".urlencode($c->name);
                      $editText.= "&mode=editcurrency";
                      $editText.= "&id={$COURSE->id}";
                      $editText.= "\">";
                      
                      $editText.="<img src=\"{$CFG->SLOODLE_LIBROOT}lib/media/settings.png\" height=\"32\" width=\"32\" height=\"16\" alt=\"".get_string('currencies:edit', 'sloodle')."\"/> ";
                      $editText.= "</a>";
                    
                          $editText.= "&nbsp&nbsp";
                          $editText.= "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?&";
                          $editText.= "_type=currency";
                          $editText.= "&currencyid=".$c->id;
                          $editText.= "&currencyname=".urlencode($c->name);
                          $editText.= "&mode=deletecurrency";
                          $editText.= "&id={$COURSE->id}";
                          $editText.= "\">";
                          $editText.="<img src=\"{$CFG->SLOODLE_LIBROOT}lib/media/garbage.png\" height=\"32\" width=\"32\" height=\"16\" alt=\"".s(get_string('currencies:delete', 'sloodle'))."\"/> ";
                          $editText.= "</a>";
                          $rowData[]=$editText;
                        
                  
                  $sloodletable->data[]=$rowData;
                  
                }

                 print_table($sloodletable);
                 
                  print_box_end();
                //create an html table to display the users      
            $sloodletable = new stdClass(); 
            
                $sloodletable->head = array(                         
                    s(get_string('currencies:displayorder', 'sloodle')),
                    s(get_string('currencies:icon', 'sloodle')),
                    s(get_string('currencies:name', 'sloodle')),
                    s(get_string('currencies:imageurl', 'sloodle')),
                    ""
                );
                
                //set alignment of table cells                                        
                $sloodletable->align = array('left','left','left');
                $sloodletable->width="55%";
                //set size of table cells
                $sloodletable->size = array('10%','5%','50%','45%','25%');       
                print('<form action="" method="POST">');
                  //create cells for add row
                   $cells = array();
                   //cell 1 -display order
                   $cells[]='<input type="hidden" name="currencyid" value="null">           
                   <input type="hidden" name="mode" value="add">
                   <input type="hidden" name="id" value="'.$id.'">
                   <input type="text" name="displayorder" size="2" value="0">';
                   //cell 2 - icon - blank
                   $cells[]="";
                   //cell 3 - name
                   $cells[]='<input type="text" name="currencyname" size="30" value="">';
                   //cell 4 - imageurl
                   $cells[]='<input type="text" size="100" name="imageurl" value="">';
                   //cell 5- add
                   $cells[]='<input type="submit" name="add" value="'.get_string('currency:addcurrency','sloodle').'">';
                   $sloodletable->data[]=$cells;
                    
                   print_box_start('generalbox boxaligncenter center boxheightnarrow leftpara');

                   print "<h2><img align=\"left\" src=\"{$CFG->SLOODLE_WWWROOT}lib/media/addnew.png\" width=\"48\"/> ";
                   print s(get_string('currency:add new','sloodle'));
		   print "</h2>";
                   
                   print_table($sloodletable);

                   print("</form>");
                   print_box_end();
      }
      
      function delete_currency(){

        global $CFG;      
        global $COURSE;

        $id = required_param('id', PARAM_INT);
        $currencyname= optional_param('currencyname', '', PARAM_TEXT); 
        $currencyid= required_param('currencyid', PARAM_INT); 

        echo "<br>";            
        //print header box
        print_box_start('generalbox boxaligncenter right boxwidthnarrow boxheightnarrow rightpara');
        echo "<h1 ><img align=\"left\" src=\"{$CFG->SLOODLE_WWWROOT}lib/media/vault48.png\" width=\"48\"/> ";
        echo get_string('currency:confirm delete', 'sloodle')."</h1>";
        print_box_end();

        //display all currencies
        print_box_start('generalbox boxaligncenter boxwidthfull leftpara');
        print('<form action="" method="POST">');

           $c = get_record('sloodle_currency_types','id',$currencyid);
           $sloodletable = new stdClass(); 
           //set up column headers table data
           $sloodletable->head = array(                         
              s(get_string('currencies:icon', 'sloodle')),
              s(get_string('currencies:name', 'sloodle')), 
              "&nbsp;");
           $sloodletable->align = array('left','left','left');
           $sloodletable->width="95%";
           $sloodletable->size = array('10%','50%','30%');     
           //create cells for row
           $row = array();
           //cell 1 -icon
            if (isset($c->imageurl)&&!empty($c->imageurl)){
                    $row[]= '<img src="'.$c->imageurl.'" width ="20px" height="20px">'; 
                  }
                  else {
                      $row[]= " ";
                  }
          
           //cell 2 - name
            $row[]='<input type="hidden" name="mode" value="confirmdelete">
            <input type="hidden" name="currencyid" value="'.intval($c->id).'">
            <input type="hidden" name="id" value="'.$id.'">'.s($c->name);
           //cell 4 - submit
           $row[]='<input type="submit" name="sumbit" value="'
            .s(get_string('currency:deletethiscurrency', 'sloodle')).'">';
           $sloodletable->data[]=$row;
           print_table($sloodletable);
          
      }

      function  render_edit_currency(){
        global $CFG;      
        global $COURSE;
        $id = required_param('id', PARAM_INT);
        $currencyname= required_param('currencyname', PARAM_TEXT);
        $currencyid= required_param('currencyid', PARAM_INT);
        echo "<br>";            
        //print header box
        print_box_start('generalbox boxaligncenter center boxwidthnarrow boxheightnarrow leftpara');
        echo "<h1 color=\"Red\"><img align=\"center\" src=\"{$CFG->SLOODLE_WWWROOT}lib/media/vault48.png\" width=\"48\"/> ";
        echo get_string('currency:Edit Currency', 'sloodle')."</h1>";
        print_box_end();

        //display all currencies
        print_box_start('generalbox boxaligncenter boxwidthfull leftpara');
        print('<form action="" method="POST">');
           $c= get_record('sloodle_currency_types','id',$currencyid);
           $sloodletable = new stdClass(); 
           //set up column headers table data
           $sloodletable->head = array(                         
               s(get_string('currencies:displayorder', 'sloodle')),
               s(get_string('currencies:imageurl', 'sloodle')),
               s(get_string('currencies:name', 'sloodle')),
               "&nbsp;");
           $sloodletable->align = array('left','left','left');
           $sloodletable->width="95%";
           $sloodletable->size = array('10%','50%','30%','15%');     
           //create cells for row
           $row = array();
           //cell 1 -display order
           $row[]='<input type="hidden" name="currencyid" value="'.$c->id.'">           
           <input type="text" name="displayorder" size="2" value="'.$c->displayorder.'">';
           //cell 2 - imageurl
           $row[]='<input type="text" size="100" name="imageurl" value="'.$c->imageurl.'">
           <input type="hidden" name="mode" value="modify">
           <input type="hidden" name="id" value="'.$id.'">';
           //cell 3 - name
           $row[]='<input type="text" name="currencyname" size="30" value="'.$c->name.'">';
           //cell 4 - submit
           $row[]='<input type="submit" name="sumbit" value="submit">';
           $sloodletable->data[]=$row;
           print_table($sloodletable);
        print("</form>");
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
