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
define('SLOODLE_BACKPACKS_BACKPACKCONTENTS_VIEW', 1);



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
     var $can_edit=false;
    /**
    * SLOODLE course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $sloodle_course = null;
    var $backpack_mode="backpackcontents";
    var $sloodle_currency = null;
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
        global $COURSE;
        $view = optional_param('view', "");
        // Setup our list of tabs
        // We will always have a view option
        
        $tabs = array(); // Top level is rows of tabs
        $tabs[0] = array(); // Second level is individual tabs in a row
        $tabs[0][] = new tabobject(SLOODLE_BACKPACKS_BACKPACKCONTENTS_VIEW, SLOODLE_WWWROOT."/view.php?&_type=backpack&id={$COURSE->id}&mode=backpackcontents", get_string('backpack:backpackcontents', 'sloodle'), get_string('backpack:backpackcontents', 'sloodle'),true);
        

        // Does the user have authority to edit this module?
        // Determine which tab should be active
        $selectedtab = SLOODLE_BACKPACKS_BACKPACKCONTENTS_VIEW;
        switch ($this->backpack_mode)
        {
        //case 'user': $selectedtab = SLOODLE_AWARDS_GAMES_VIEW; break;            
        case 'backpackcontents': $selectedtab = SLOODLE_BACKPACKS_BACKPACKCONTENTS_VIEW; break;
        
        
        }
        
        // Display the tabs
        print_tabs($tabs, $selectedtab);
        echo "<div style=\"text-align:center;\">\n";
        
        // Call the appropriate render function, based on our mode
        switch ($this->backpack_mode)
        {
        case 'backpackcontents': $this->render_backpack_contents_view(); break;            
        
        default: $this->render_backpack_contents_view(); break;
        }
        echo "</div>\n";
        
 
    }
        /**
    * Process any form data which has been submitted.
    */
    function process_form(){        
        global $USER,$sloodle;
        //============== - CHECK TO SEE IF THERE ARE PENDING UPDATES TO EXISTING STUDENTS
        $update= optional_param("update");  
           if ($update){                
                   
                $balance_updates=optional_param("balanceAdjustment");
                $userIds = optional_param("userIds");
                $avuuids= optional_param("avuuids");
                $avnames= optional_param("avnames");
                $idatas= optional_param("idataFields"); 
                //if the userid field was submited, this means that this is the users first entry for this currency
                
                $currentCurrency= optional_param("currentCurrency");
                $sloodle_currency= new SloodleCurrency();
                $currIndex=0;   
                $updatedRecs = Array();
                $errorString=''; 
                $transactions= Array();
                
                if (is_array($userIds))
                {
                    foreach ($userIds as $userId) {
                        //Was a non-zero value entered in the balance_update field for this user?
                        if ($balance_updates[$currIndex]!=0){
                            //build a new transaction record for the sloodle_award_trans table
                                //build sloodle_user object for this user id                            
                                $trans = new stdClass();                            
                                $trans->currency=$currentCurrency;
                                $trans->avuuid= $avuuids[$currIndex];
                                if ($balance_updates[$currIndex]>0)$trans->itype='credit'; else 
                                if ($balance_updates[$currIndex]<0){ 
                                    $trans->itype='debit';
                                }//endif
                                $trans->amount=abs($balance_updates[$currIndex]);
                                $trans->userid = $userId; 
                                $trans->avname= $avnames[$currIndex]; 
                                if ($idatas[$currIndex]=="")
                                    $trans->idata="Modified by: ".$USER->username;
                                else
                                    $trans->idata=$idatas[$currIndex];
                                $trans->timemodified=time();    
                                $sloodle_currency->addTransaction($trans->userid,$trans->avname,$trans->avuuid,0,$currentCurrency,$balance_updates[$currIndex],$trans->idata,NULL);
                                $transactions[]=$trans;                      
                        }//endif $balance_updates[$currIndex]!=0
                        $currIndex++;        
                    }//end foreach
                }
            }//endif update
       }//end function process_form 
    
    /*
    *  This will render the view of each user's inventory for the selected currency type - that has been selected
    *  in the drop down.  The default currency is "Credits"
    * 
    *  There are two drop downs the user can select. One is for a user - if a specific user is selected, then all the transactions for that user
    *  for that particular currency will be displayed, otherwise a list of all users for the selected currency will be displayed
    */
    function render_backpack_contents_view(){
        global $CFG;
        global $sloodle;
        $id = required_param('id', PARAM_INT);      
        $action= optional_param('action', "");                 
        $currentCurrency = optional_param('currentCurrency',"Credits");
        $currentUser= optional_param('currentUser',"ALL");
        if ($currentUser!='ALL'){            
            $cUser = get_record('sloodle_users', 'avname', $currentUser);    
            $currUserId =$cUser->id;            
        }
          
        
        
        
            echo "<h4>Current User is: {$currentUser}</h4>";
            
            echo '<form action="" method="POST" >';
            echo "<input type=\"hidden\" name=\"id\" value=\"".$id."\">";
            echo "<input type=\"hidden\" name=\"currentCurrency\" value=\"".$currentCurrency."\">";
            echo "<input type=\"hidden\" name=\"_type\" value=\"backpack\">";
            $contextid = get_context_instance(CONTEXT_COURSE,$this->course->id);
        //get all enrolled users who have an avatar
            $enrolledUsers = $this->sloodle_course->get_enrolled_users();
        //SloodlCurrency is a class in the sloodle lib root folder with functions for currency
            $sloodle_currency= new SloodleCurrency();
            $cTypes=    $sloodle_currency->get_currency_types();
        // Display instrutions for this page        
            print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara');
                echo get_string('backpack:instructions_backpack_contentsview', 'sloodle');
            print_box_end();
        //display the select box for the user select box
            print_box_start();
             echo '<div style="";>'.get_string('backpack:selectusergroup', 'sloodle');
                
                 $students = $this->sloodle_course->get_enrolled_users();
                 echo " <select name=\"currentUser\"    onchange=\"this.form.submit()\" value=\"Sumbit\">";
                 if ($currentUser =="ALL") {
                     $selectStr="selected";
                 }
                 echo "<option value=\"ALL\" {$selectStr}>ALL</option>";
                          
                 foreach ($students as $s){                  
                    if ($s->avname==$currentUser){
                        $selectStr="selected";     
                        
                        
                    }
                    else {
                        $selectStr="";
                        
                    }
                    echo "<option value=\"{$s->avname}\" {$selectStr}>{$s->avname} / {$s->firstname} {$s->lastname}</option>";
                 }    
                 echo '</select>';
              
        //display the select box for the currency        
                echo get_string('backpack:selectcurrencytype', 'sloodle');
                echo " <select name=\"currentCurrency\"    onchange=\"this.form.submit()\" value=\"Sumbit\">";                 
                foreach ($cTypes as $ct){
                    if ($ct->name==$currentCurrency)$selectStr="selected"; else $selectStr="";
                    echo "<option value=\"{$ct->name}\" {$selectStr}>{$ct->name}</option>";
                }            
                echo '</select></div>  ';
        print_box_end(); 
        //create an html table to display the users      
            $sloodletable = new stdClass(); 
              
          if ($this->can_edit) {                 
                $updateString =' <input type="submit"';
                $updateString .=' name="update" ';
                $updateString .='  value="'.get_string("awards:update","sloodle") .'">';      
          }else {$updateString = '';}          
            $sloodletable->head = array(                         
             '<h4><div style="text-align:left;">'.get_string('backpack:avname', 'sloodle').'</h4>',
             '<h4><div style="text-align:left;">'.get_string('backpack:currency', 'sloodle').'</h4>',
             '<h4><div style="text-align:left;">'.get_string('backpack:details', 'sloodle').'</h4>',             
             '<h4><div style="text-align:left;">'.get_string('backpack:date', 'sloodle').'</h4>',             
             '<h4><div style="text-align:right;">'.get_string('backpack:amount', 'sloodle').'</h4>',$updateString);
              //set alignment of table cells                                        
             $sloodletable->align = array('left','left','left','left','right');
             $sloodletable->width="95%";
             //set size of table cells
             $sloodletable->size = array('15%','10%', '30%','20%','10%');            
             //get all the sum totals of the selected currency for each user if "ALL" is selected
              $trans = Array();
             if ($currentUser=="ALL"){
               //$trans = $sloodle_currency->get_transactions(null,$currentCurrency);               
                $enrolled=$this->sloodle_course->get_enrolled_users();
                if (!$enrolled) $enrolled = array();
               
                foreach ($enrolled as $e){                    
                    $sql= "select t.*, sum(case t.itype when 'debit' then cast(t.amount*-1 as signed) else t.amount end) as balance from {$CFG->prefix}sloodle_award_trans t where t.currency='{$currentCurrency}' AND t.avname='{$e->avname}' AND t.courseid={$id}";                    
                
                    $tran = get_record_sql($sql);    
                    $tran->avname=$e->avname;
                    $tran->avuuid=$e->avuuid;
                    $tran->userid=$e->userid;
                    $tran->currency=$currentCurrency;                    
                    if ($tran->balance == NULL){
                     $tran->balance=0;
                    }
                    $trans[]=$tran;
                }
             }else{
             //otherwise only get the transactions for the selected user for the selected currency
               $trans = $sloodle_currency->get_transactions($currentUser,$currentCurrency);
            }
            //display transactions            
            if ($this->can_edit) {       
                  $editField = '<input style="text-align:right;" type="text" size="6" name="balanceAdjustment[]" value=0>';
                 
            }
            else {
                $editField ='';
                $idata_editField='';
            }
            //manage the case where only a selected user is being viewed, but has no transactions yet
            if ($currentUser!="ALL"&&$trans==NULL){
                 $userIdFormElement = 
                '<input type="hidden" name="userIds[]" value="'.$cUser->userid.'">
                <input type="hidden" name="avuuids[]" value="'.$cUser->uuid.'">
                <input type="hidden" name="avnames[]" value="'.$cUser->avname.'">';                
                //var_dump($cUser->get_user_id());
                $avname=$currentUser;                
                $trowData[]=$userIdFormElement.$avname;  
                $trowData[]=$currentCurrency;  
                if ($this->can_edit) {                           
                       $idata_editField = '<input style="text-align:right;" type="text" size="20" name="idataFields[]" value="">';
                }                    
                $trowData[]=$idata_editField;    
                $trowData[]=date("D M j G:i:s T Y",$t->timemodified);                                               
                $trowData[]='<div style="color:green;text-align:left;">0</div>';//amount
                $trowData[]=$editField;                                                                                                                                                                     
                $sloodletable->data[] = $trowData;                     
            }else
            foreach ($trans as $t){               
                $trowData= Array();
                $userIdFormElement = 
                '<input type="hidden" name="userIds[]" value="'.$t->userid.'">
                <input type="hidden" name="avuuids[]" value="'.$t->avuuid.'">
                <input type="hidden" name="avnames[]" value="'.$t->avname.'">';
                $avname=urlencode($t->avname);
                $trowData[]=$userIdFormElement.$t->avname;  
                $trowData[]=$t->currency;  
                if ($currentUser=="ALL"){
                    if ($this->can_edit) {                           
                        $idata_editField = '<input style="text-align:right;" type="text" size="20" name="idataFields[]" value="">';
                    }                    
                }
                else
                if ($this->can_edit) {                           
                       $idata_editField = '<input style="text-align:right;" type="text" size="20" name="idataFields[]" value="'.$t->idata.'">';
                }else  $idata_editField = $t->idata;
                $trowData[]=$idata_editField;    
                $trowData[]=date("D M j G:i:s T Y",$t->timemodified);                                               
              
                $trowData[]='<div style="color:green;font-weight:bold;text-align:right;">'.$t->balance.'</div>';//
                $trowData[]=$editField;                                                                                                                                                                    
                $sloodletable->data[] = $trowData;     
            }

             
        print_table($sloodletable); 
              echo '</form>';   
 
        
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
