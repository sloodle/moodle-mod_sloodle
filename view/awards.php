<?php
/**
* Defines a class for viewing the SLOODLE Awards module in Moodle.
* Derived from the module view base class.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @see http://slisweb.sjsu.edu/sl/index.php/Sloodle_Stipend_Giver
*
* @contributer Paul G. Preibisch - aka Fire Centaur 
*/

/** The base module view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view_module.php');
       
 /** SLOODLE course data structure */
require_once(SLOODLE_LIBROOT.'/course.php');

/** SLOODLE course object data structure */
require_once(SLOODLE_LIBROOT.'/sloodlecourseobject.php');
/** SLOODLE course object data structure */

/** SLOODLE awards object data structure */
require_once(SLOODLE_DIRROOT.'/mod/awards-1.0/awards_object.php');
/** Sloodle Session code. */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

/** General Sloodle functionality. */
require_once(SLOODLE_LIBROOT.'/general.php');   
/** ID of the 'userview' tab for the awards system. */                             
define('SLOODLE_AWARDS_GAMES_VIEW', 1);
define('SLOODLE_AWARDS_TEAM_VIEW', 2);   
define('SLOODLE_AWARDS_PRIZE_VIEW', 3); 
/**
* Class for rendering a view of a Distributor module in Moodle.
* @package sloodle
*/
class sloodle_view_awards extends sloodle_base_view_module
{
     
    /**
    * SLOODLE course object, retrieved directly from database.
    * @var object
    * @access private
    */
    var $sloodleCourse = null;
    
    var $renderMessage=null;
    var $awards_mode = 'game'; 
    /**
    * The result number to start displaying from
    * @var integer
    * @access private
    */
    var $start = 0;  
    
    /**
    * A List of records of the transactions for this stipend
    * @var Array
    * @access private
    */   
    var $transactionRecords = null;
    /**
    * A List of all users avatar UUID's who have collected a stipend
    * @var Array
    * @access private
    */     
    
    var $stipendCollectors_uuid= null;

    /**
    * A List of usrs moodle id's who have collected a stipend
    * @var Array
    * @access private
    */     
    var $stipendCollectors_moodleid= null;
    
    
   /**
   * A List of all the students in this course
   * @var Array
   * @access private
   */ 
   var $userList= null;
    
   var $initialized=false;        
       /**
    * sloodleId The instance of this moodle module
    * @var bigInt(10)
    * @access private
    */  
       
   var $sloodleId = null;
   /**
    * session is a dummy session object to be used as a parameter when creating a sloodleUser object
    * @var SloodleSession Object
    * @access private
    */  
       
   var $session= null;
   /**
    * @var $iPb a pointer to the iPoint bank object base class;  
    */
   var $iPb = null;
   /**
    * @var $sCourseObj - a pointer to the sloodleCourseObject with useful functions to access course data
    */   
   var $sCourseObj = null;
   /**
    * @var $iPts are the number of iPoints
    *  if iPoints were selected as icurrency
    */
   var $iPts = null;
   
   var $showInitForm = false;
   /**
    * @var $icurrency - currency of this stopend - can be Lindens, or iPoints
    */
   var $icurrency; 
   /**
    * @var $awardsObj - a pointer to the awardsObject with useful functions to access the awards
    */   
   var $awardsObj = null;
   
     /**
    * The course module instance, retrieved directly from the database (table: course_modules)
    * @var object
    * @access private
    */
    var $cm = null;

    /**
    * The main SLOODLE module instance, retreived directly from the database (table: sloodle)
    * @var object
    * @access private
    */
    var $sloodleRec = null;

    /**
    * The VLE course object, retrieved directly from the database (table: course)
    * @var object
    * @access private
    */
    var $course = null;

    /**
    * The SLOODLE course object.
    * @var SloodleCourse
    * @access private
    */
    var $sloodle_course = null;

    /**
    * Context object for permissions in the Moodle course.
    * @var object
    * @access private
    */
    var $course_context = null;

    /**
    * Context object for permissions in the Moodle module.
    * @var object
    * @access private
    */
   /**
    * Constructor.
    * This constructor creates a sloodleCourseObject which gives us useful functions to access course data 
    * Also creats a awards Object which gives us useful functions to access awards data
    * 
    */
   
    
    function sloodle_view_awards()    
    {
        global $sCourseObj,$awardsObj;
        
            $sloodleid = required_param('id', PARAM_INT);   
             
             //set Sloodle Course Obj - this object will give us things like: userlist of the course, sloodle id etc.
            $sCourseObj = new sloodleCourseObj($sloodleid);
            $this->sloodleRec= $sCourseObj->sloodleRec;
            $this->cm = $sCourseObj->cm;
            $this->course = $sCourseObj->courseRec;
            $this->course_context = $sCourseObj->courseContext;
            $awardsObj = new Awards($sCourseObj->cm->id);
    }
    /**
    * Check that the user has permission to view this module, and check if they can edit it too.
    */
    
    function check_permission()
    {
        global $sCourseObj;
        // Make sure the user is logged-in
        require_course_login($this->course, true, $this->cm);
        add_to_log($sCourseObj->courseId, 'sloodle', 'view sloodle module', "view.php?id={$sCourseObj->cm->id}", "{$this->sloodleRec->id}", $sCourseObj->cm->id);
        
        // Check for permissions
        $this->module_context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
        $this->course_context = get_context_instance(CONTEXT_COURSE, $this->course->id);
        if (has_capability('moodle/course:manageactivities', $this->module_context)) $this->canedit = true;

        // If the module is hidden, then can the user still view it?
        if (empty($this->cm->visible) && !has_capability('moodle/course:viewhiddenactivities', $this->module_context)) notice(get_string('activityiscurrentlyhidden'));
    }

    /**
    * Check and process the request parameters.
    */
    function process_request()
    {
        global $CFG, $USER;
        global $sCourseObj;
        global $awardsObj;
    
        //====================== Get all course related information
           //coursemodule id
            $sloodleId = required_param('id', PARAM_INT);      
            $this->start = optional_param('start', 0, PARAM_INT);
                     
            //get awards Object (Awards Object)
            $awardsObj = new Awards((int)$sloodleId);
            if ($this->start < 0) $this->start = 0;
            //get icurrency type of points
            //$this->icurrency= $awardsObj->icurrency; // there doesn't seem to be an icurrency value anymore
            //get users in this course
            $this->userList = $sCourseObj->getUserList(); 

            
    }
   function creditAll($amount,$gameid){
       global $awardsObj,$sCourseObj;
       $transactions = Array();
       foreach ($this->sCourseObj->getUserList() as $u){ 
            //Ipoints can be various types - ie: real lindens, or just points.                         
            $iTransaction = new stdClass();
            $iTransaction->userid       = (int)$u->id;
            $iTransaction->sloodleid    = (int)$this->sloodleId;
            $iTransaction->gameid       = (int)$gameid;
            $iTransaction->icurrency    = (string)$this->icurrency;
            $iTransaction->amount       = (int)$amount;
            $iTransaction->itype = "credit";
            $iTransaction->timemodified = (int)time();
            $awardsObj->awards_makeTransaction($iTransaction,$sCourseObj);
            $transactions[]=$iTransaction;
       }   
       $awardsObj->synchronizeDisplays($iTransaction);
   } 
    
    /**
    * Process any form data which has been submitted.
    */
    function process_form(){        
        global $awardsObj;
        global $sCourseObj;
        global $USER;
        $this->awards_mode = optional_param('mode', 'games');   
        //============== - CHECK TO SEE IF THERE ARE PENDING UPDATES TO EXISTING STUDENTS
           //check if we need to update allocations 
           //if "update" param exists, that means someone submitted a form using the update button in printPointsTable function
           $addteams= optional_param("addteam");            
           $removeTeams= optional_param("removeteams"); 
           if (isset($_POST['addteam'])){ 
                $teamsToAdd = $_POST['availteams']; 
               if (isset($_POST['availteams'])){
               
                foreach ($teamsToAdd as $tAdd){
                        //first check to see if team already exists
                        if (!get_record('sloodle_awards_teams','groupid',$tAdd,'sloodleid',$sCourseObj->sloodleId)){
                            $newT = new stdClass();
                            $newT->groupid = $tAdd;
                            $newT->sloodleid = $sCourseObj->sloodleId;                                                
                            insert_record('sloodle_awards_teams',$newT);
                        }//end if !get_record
                   }//endif foreach
               }//endif isset
               //update scoreboard displays of newly added teams
               $scoreboards = $awardsObj->getScoreboards($sCourseObj->sloodleId);
               if ($scoreboards){
                   foreach ($scoreboards as $sb){
                        $displayData ="";
                        $displayData= $awardsObj->callLSLScript($sb->url,"COMMAND:GET DISPLAY DATA\n",10);
                      if ($displayData){                       
                        $dataLines = explode("\n", $displayData);
                        $currentView = $awardsObj->getFieldData($dataLines[0]);
                        if ($currentView=="Select Teams"||$currentView=="Team Top Scores"){
                           $response= $awardsObj->callLSLScript($sb->url,"COMMAND:UPDATE DISPLAY\n",10); 
                        }//endif
                      }//endif
                   }//foreach
               }//endif
           }//endif isset addteam
           if (isset($_POST['removeteams'])){ 
                $teamsToRemove = $_POST['existingteams']; 
               if (isset($_POST['existingteams'])){
                foreach ($teamsToRemove as $tRemove){
                        delete_records('sloodle_awards_teams','groupid',$tRemove,'sloodleid',$sCourseObj->sloodleId);
                }//end foreach
               }//endif isset
                 $scoreboards = $awardsObj->getScoreboards($sCourseObj->sloodleId);
               if ($scoreboards){
                   foreach ($scoreboards as $sb){
                        $displayData ="";
                        $displayData= $awardsObj->callLSLScript($sb->url,"COMMAND:GET DISPLAY DATA\n",10);
                      if ($displayData){                       
                        $dataLines = explode("\n", $displayData);
                        $currentView = $awardsObj->getFieldData($dataLines[0]);
                        if ($currentView=="Select Teams"||$currentView=="Team Top Scores"){
                           $response= $awardsObj->callLSLScript($sb->url,"COMMAND:UPDATE DISPLAY\n",10); 
                        }//endif
                      }//endif
                   }//foreach
               }//endif
           }//endif isset
           $addmorefields= optional_param("addmorefields");  
           $deleteTeam = optional_param("deleteteam");  
           $update= optional_param("update");
           $gameid= optional_param("gameid");
             
           if ($update){                
                   
                $balance_updates=optional_param("balanceAdjustment");
                
                //get userId's that were posted
                $userIds = optional_param("userIds");
                
                //get user names that were posted
                $userNames = optional_param("usernames");
                $currIndex=0;   
                $updatedRecs = Array();
                $errorString=''; 
                //go through each userId posted, and check each update field.  If it's a non-zero
                //then we must make a transaction for this user
                $sloodle = new SloodleSession( false );
                $transactions= Array();
                foreach ($userIds as $userId) {
                    //Was a non-zero value entered in the balance_update field for this user?
                    if ($balance_updates[$currIndex]!=0){
                        //build a new transaction record for the sloodle_award_trans table
                            //build sloodle_user object for this user id                            
                            $avuser = new SloodleUser( $sloodle ); 
                            $userRec = get_record('sloodle_users', 'userid', $userId);  
                            $trans = new stdClass();
                            $trans->gameid=$gameid;
                            $trans->currency="Credits";
                            $trans->avuuid= $userRec->uuid;        
                            if ($balance_updates[$currIndex]>0)$trans->itype='credit'; else 
                            if ($balance_updates[$currIndex]<0){
                                $trans->itype='debit';
                                //check to see if this debit will make a negative amount
                                
                                $userAccountInfo = $awardsObj->awards_getBalanceDetails($userRec->userid,$gameid);
                                if (($userAccountInfo->balance - abs($balance_updates[$currIndex]))<0){
                                    $balance_updates[$currIndex]= $userAccountInfo->balance;
                                }//endif
                            }//endif
                            $trans->amount=abs($balance_updates[$currIndex]);
                            $trans->userid = $userId; 
                             $trans->avname= $userRec->avname; 
                            $trans->idata="DETAILS:webupdate|by moodle user:".$USER->username;
                            $trans->timemodified=time();    
                            $awardsObj->awards_makeTransaction($trans,$sCourseObj);  
                            $transactions[]=$trans;                      
                    }//endif $balance_updates[$currIndex]!=0
                    $currIndex++;        
                }//end foreach
                //update scoreboards in secondLife
                if (!empty($transactions)){
                    $awardsObj->synchronizeDisplays($transactions);
                }
                //create and print confirmation message to the user
                $confirmedMessage = get_string("awards:successfullupdate","sloodle");
                $confirmedMessage .= $this->addCommas($updatedRecs);
                //send confirmation Message
                $this->setRenderMessage($confirmedMessage . $errorString);
            }//endif update
       }//end function process_form 
      /**
    * Override the base_view_module print_header for formatting reasons 
    */
    
     function print_header(){             
        global $CFG,$sCourseObj;
        // Offer the user an 'update' button if they are allowed to edit the module
        $editbuttons = '';
        if ($this->canedit) {
            $editbuttons = update_module_button($this->cm->id, $this->course->id, get_string('modulename', 'sloodle'));
        }
        // Display the header: Sloodle with edit buttons
        $navigation = "<a href=\"index.php?id={$this->course->id}\">".get_string('modulenameplural','sloodle')."</a> ->";
        $courseName=$sCourseObj->sloodleRec->name;
        print_header_simple(format_string($courseName), "", "{$navigation} ".format_string($courseName, "", "", true, $editbuttons, navmenu($this->course, $this->cm)));
        // Display the module name: Sloodle awards
       
        
    
        // Display the module type and description
        $fulltypename = get_string("moduletype:{$sCourseObj->sloodleRec->type}", 'sloodle');
        echo '<h4 style="text-align:center;">'.get_string('moduletype', 'sloodle').': '.$fulltypename;
        echo helpbutton("moduletype_{$sCourseObj->sloodleRec->type}", $fulltypename, 'sloodle', true, false, '', true).'</h4>';
    }   
 
 /**
 * printPointsTable function
 * @desc This function will display an HTML table of the users transactions
 * Columns displayed will be:  UserName | Avatar  |  Amount Alloted  |  Balance Remaining   
 * @staticvar null
 * @param $userData - an array of users
 * @link http://sloodle.googlecode.com
 * @return null 
 */ 
    function printPointsTable($gameid){        
        global $CFG;
        global $USER;
        global $sCourseObj;
        global $awardsObj;

        $sloodletable = new stdClass();            
        $sloodletable->tablealign='center';
        //build row
        $rowData=Array();
        //$userscore = $awardsObj->getScores($gameid,'balance',$userid);
        
        $text='<h2><div style="color:blue;text-align:center;">'.$sCourseObj->sloodleRec->name.'</div><h2>';
        $text.='<h2><div style="color:black;text-align:center;">'.get_string('awards:gamescoreboard','sloodle').$gameid.'</div></h2>';
        //$text.='<div style="color:black;text-align:center;">'.get_string('awards:finalscore','sloodle').$userscore[0]->score.'<br>';  
        $text.='<a href="'.$CFG->wwwroot.'/mod/sloodle/view.php?id='.$sCourseObj->cm->id.'">'.get_string('awards:gobackgameslist','sloodle').'</a></div>';
        $rowData[]=$text;        
        $sloodletable->data[]=$rowData;            
        print_table($sloodletable); 
         //===================== Build table with headers, set alignment and width of cells
        //Create HTML table object
        $sloodletable = new stdClass();
        $sloodletable->tablealign='center';
        //Row Data
        
        //Create Sloodle Table Column Labels
        //User | Avatar  |  Amount Alloted  |  Balance Remaining
         $context = get_context_instance(CONTEXT_MODULE, $sCourseObj->cm->id);          
          if (has_capability('moodle/course:manageactivities',$context, $USER->id)) {                 
            $updateString =' <input type="submit"';
            $updateString .=' name="update" ';
            $updateString .='  value="'.get_string("awards:update","sloodle") .'">';      
        }else {$updateString = '';}
             
            $sloodletable->head = array(
             get_string('awards:fullname', 'sloodle'),
             get_string('awards:avname', 'sloodle'),             
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:points', 'sloodle').'</h4>',
             '<h4><div style="color:red;text-align:center;">'.get_string('awards:penalties', 'sloodle').'</h4>',
             '<h4><div style="color:green;text-align:center;">'.get_string('awards:score', 'sloodle').'</h4>',
             $updateString);
        //set alignment of table cells                                        
        $sloodletable->align = array('left', 'left','right','right','right');
        //set size of table cells
        $sloodletable->size = array('15%','35%', '5%','5%','10%');        
        $avs='';
        $debits='';
        $checkBoxId=0; 
        $userData =  $awardsObj->getScores($gameid,"balance");
        if (!empty($userData)){
            foreach ($userData as $u){
                 //==========print hidden user id for form processing
                $userIdFormElement = '<input type="hidden" name="userIds[]" value="'.$u->userid.'">';
                $gameidelement = "<input type=\"hidden\" name=\"gameid\" value='{$gameid}'>";
                // Get the Sloodle user data for this Moodle user
                if ($sCourseObj->is_teacher($USER->id))
                  $editField = '<input style="text-align:right;" type="text" size="6" name="balanceAdjustment[]" value=0>';
                  else $editField ='';
                //build row
                //col 0: fullname & link to profile
                //col 1: avatar
                //col 2: balance
                //col 3: updateAmount
                //col 4: transaction link
                $rowData= Array();  
                // Construct URLs to this user's Moodle and SLOODLE profile pages
                $userinfo = get_record('user','id',$u->userid);
                $url_moodleprofile= $sCourseObj->get_moodleUserProfile($userinfo);
                $rowData[]= $gameidelement. $userIdFormElement . "<a href=\"{$url_moodleprofile}\">{$userinfo->firstname} {$userinfo->lastname}</a>";
                //create a url to the transaction list of each avatar the user owns
                
                 $ownedAvatars = get_records('sloodle_users', 'userid', $u->userid,'avname DESC','userid,uuid,avname');                        
                if ($ownedAvatars){
                    
                    $trans_url ='';   
                    foreach ($ownedAvatars as $av){
                       $trans_url.='<a href="'.$CFG->wwwroot.'/mod/sloodle/view.php?id=';
                       $trans_url.=$sCourseObj->cm->id.'&';
                       $trans_url.='action=gettrans&userid='.$av->userid.'&mode=user&gameid='.$gameid.'">';
                       $rowData[]=$av->avname.' '.$trans_url .'(transactions)</a>';
                       $trans_details = $awardsObj->awards_getBalanceDetails($av->userid,$gameid);
                       if (!$trans_details) {
                           $credits=0; $debits=0;$balance=0;
                       }else{
                           $points=$trans_details->credits;
                           $penalties=$trans_details->debits;
                           $score=$trans_details->balance;
                       }
                       $rowData[]='<div style="color:black;text-align:center;"><input type="text" size="10" readonly value="'.$points.'"></div>';
                       $rowData[]='<div style="color:red;text-align:center;"><input type="text" size="10" readonly value="'.$penalties.'"></div>';
                       $rowData[]='<div style="color:green;text-align:center;"><input type="text" size="10" readonly value="'.$score.'"></div>';
                       $rowData[]=$editField;
                        
                    }
                    $sloodletable->data[] = $rowData;
                }
            }
            print ('<input type="hidden" name="gameid" value='.$gameid.'><form action="" method="POST">');
            print_table($sloodletable);  
            print('</form>');  
        } else
        {
         print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara'); 
                print ('<h1 style="color:red;text-align:center;">'.get_string('awards:noplayers','sloodle').'</div>');
         print_box_end(); 
        }
    }  
     /**
 * printTeamTable function
 * @desc This function will display an HTML table of the team
 * Columns displayed will be:  TeamName | TeamPoints
 */ 
    function printTeamTable($teamData){        
        global $CFG;
        global $USER;
        global $sCourseObj;
        global $awardsObj;

        
         //===================== Build table with headers, set alignment and width of cells
        //Create HTML table object
        $sloodletable = new stdClass();
        $sloodletable->tablealign='center';
        //Row Data
        
        //Create Sloodle Table Column Labels
        //Team Name | Points 
      
         $context = get_context_instance(CONTEXT_MODULE, $sCourseObj->cm->id);          
         
            $sloodletable->head = array(
             get_string('awards:teamname', 'sloodle'),
             '<h4><div style="color:green;text-align:center;">'.get_string('awards:points', 'sloodle').'</h4>');
        //set alignment of table cells                                        
        $sloodletable->align = array('left','right');
        //set size of table cells
        $sloodletable->size = array('80%','20%');        
        if (!empty($teamData)){
            foreach ($teamData as $t){
                
                 //==========print hidden user id for form processing
                $teamIdFormElement = '<input type="hidden" name="teamIds[]" value="'.$t->id.'">';
                // Get the Sloodle user data for this Moodle user
               
               
                //build row
                //col 0: team name
                //col 1: points
                $rowData= Array();  
                $rowData[]= $userIdFormElement;
                $rowData[]= "<b>".$t->name."<b>";
                $rowData[]= $awardObj->getTeamPoints($t->id);
                $sloodletable->data[] = $rowData;
                $teamMembers = $awardsObj->getTeamMembers($t->id);
                foreach ($teamMembers as $tm){
                   $rowData= Array();               
                   $rowText = $tm->name;
                   $rowData[]=$rowText;
                   $sloodletable->data[] = $rowData;
                }
            }            
            print ('<form action="" method="POST">');
            print_table($sloodletable);  
            print('</form>');  
        }  
    }  
 /**
 * printTransTable function
 * @desc This function will display an HTML table of a single users transactions
 * @staticvar null
 * @param $userData - an array of users
 * @link http://sloodle.googlecode.com
 * @return null 
 */ 
    function printTransTable($userid,$gameid){        
        global $CFG;
        global $USER;
        global $sCourseObj;
        global $awardsObj;
        
         $context = get_context_instance(CONTEXT_MODULE, $sCourseObj->cm->id);          
         $permissions = has_capability('moodle/course:manageactivities',$context, $USER->id);
      
        //get sloodle_record
        $userRec = get_record('sloodle_users', 'userid', $userid);  
        //build table
        print("<div align='center'>");
        $sloodletable = new stdClass();            
        $sloodletable->tablealign='center';
        //build row
        $rowData=Array();
        //$userscore = $awardsObj->getScores($gameid,'balance',$userid);
        $text='<h2><div style="color:blue;text-align:center;">'.$sCourseObj->sloodleRec->name.'</div>';
        $text.='<div style="color:black;text-align:center;">'.get_string('awards:gamescoreboard','sloodle').$gameid.'</div></h2>';
        $text.='<h3><div style="color:black;text-align:center;">'.get_string('awards:usertransactions','sloodle').$userRec->avname.'</div>';
                                         
        $userscore = $awardsObj->getScores($gameid,'balance',$userid);
        if ($userscore[0]->score<0)$color='<div style="color:red;text-align:center;">';
        else$color='<div style="color:green;text-align:center;">';
        $text.=$color.get_string('awards:finalscore','sloodle').$userscore[0]->score.'</h3><br>';  
        $text.='<div style="color:black;text-align:center;"><a href="'.$CFG->wwwroot.'/mod/sloodle/view.php?id='.$sCourseObj->cm->id.'&action=getgame&gameid='.$gameid.'">'.get_string('awards:gobacktogame','sloodle').'</a></div>';
        $rowData[]=$text;        
        $sloodletable->data[]=$rowData;            
        print_table($sloodletable); 
              
        
            
            
        $avName = $userRec->avname; 
        
       $tsloodletable = new stdClass(); 
        //create transactions table
        if ($permissions) {
            $tsloodletable->head = array(             
            '<h4><div style="color:black;text-align:center;">'.get_string('awards:gameid', 'sloodle').'<br></h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('ID', 'sloodle').'<br></h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:details', 'sloodle').'<br></h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:credits', 'sloodle').'<br>('.$userscore[0]->credits.')'.'</h4>',
             '<h4><div style="color:red;text-align:center;">'.get_string('awards:debits', 'sloodle').'<br>('.$userscore[0]->debits.')'.'</h4>',
             '<h4><div style="color:green;text-align:center;">'.get_string('awards:balance', 'sloodle').'<br>('.$userscore[0]->score.')'.'</h4>',             
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:date', 'sloodle').'</h4>');
             //set alignment of table cells                                        
            $tsloodletable->align = array('left','left','left', 'right','right','right','left');
            $tsloodletable->width="95%";
            //set size of table cells
            $tsloodletable->size = array('5%','5%','40%','10%', '10%','10%','35%');
        } else {
            $tsloodletable->head = array(             
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:gameid', 'sloodle').'<br></h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('ID', 'sloodle').'<br></h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:credits', 'sloodle').'<br>('.$totaldebits.')'.'</h4>',
             '<h4><div style="color:red;text-align:center;">'.get_string('awards:debits', 'sloodle').'<br>('.$totaldebits.')'.'</h4>',
             '<h4><div style="color:green;text-align:center;">'.get_string('awards:balance', 'sloodle').'<br>('.$totalbalances.')'.'</h4>',             
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:date', 'sloodle').'</h4>');             
              //set alignment of table cells                                        
            $tsloodletable->align = array('left','left','right','right','right','left');
            $tsloodletable->width="95%";
            //set size of table cells
            $tsloodletable->size = array('5%','5%','10%', '10%','10%','25%');
        }
        //get all users transactions
        $transactions = $awardsObj->awards_getTransactionRecords($userid,$gameid);
        if (!empty($transactions)){
            $balance=0;
            foreach ($transactions as $t){
               $trowData= Array();        
               $trowData[]=$gameid;             
               $trowData[]=$t->id;
               if ($permissions) {                 
                $trowData[]=$t->idata;         
               }
               if ($t->itype=='credit') { 
                   $balance+=$t->amount;
                   $trowData[]='<div style="color:black;text-align:center;">'.$t->amount.'</div>'; 
                   $trowData[]='';
               }else
               if ($t->itype=='debit') { 
                   $balance-=$t->amount;
                   $trowData[]='';
                   $trowData[]='<div style="color:black;text-align:center;">'.$t->amount.'</div>';                    
               }               
               $trowData[]='<div style="color:green;text-align:center;">'.$balance.'</div>';
               
               $trowData[]=date("D M j G:i:s T Y",$t->timemodified);
               $tsloodletable->data[] = $trowData;     
            }
            print_table($tsloodletable);   
            }      
                              
            
            print("</div>"); 
        }    
   
            
      
    /**
    * Render the view of the awards system.
    */
     function render()
    {
        global $CFG;
        
        // Setup our list of tabs
        // We will always have a view option
        $awardsTabs = array(); // Top level is rows of tabs
        $awardsTabs[0] = array(); // Second level is individual tabs in a row
        $awardsTabs[0][] = new tabobject(SLOODLE_AWARDS_GAMES_VIEW, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=games", get_string('awards:gametab', 'sloodle'), get_string('awards:gametab', 'sloodle'),true);
        $awardsTabs[0][] = new tabobject(SLOODLE_AWARDS_TEAM_VIEW, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=team", get_string('awards:teams', 'sloodle'), get_string('awards:teamtab', 'sloodle'),true);
        $awardsTabs[0][] = new tabobject(SLOODLE_AWARDS_PRIZE_VIEW, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=prizes", get_string('awards:prizes', 'sloodle'), get_string('awards:prizes', 'sloodle'),true);
        // Does the user have authority to edit this module?
        // Determine which tab should be active
        $selectedtab = SLOODLE_AWARDS_GAMES_VIEW;
        switch ($this->awards_mode)
        {
        //case 'user': $selectedtab = SLOODLE_AWARDS_GAMES_VIEW; break;            
        case 'games': $selectedtab = SLOODLE_AWARDS_GAMES_VIEW; break;
        case 'team': $selectedtab = SLOODLE_AWARDS_TEAM_VIEW; break;
        case 'prizes': $selectedtab = SLOODLE_AWARDS_PRIZE_VIEW; break;
        }
        
        // Display the tabs
        print_tabs($awardsTabs, $selectedtab);
        echo "<div style=\"text-align:center;\">\n";
        
        // Call the appropriate render function, based on our mode
        switch ($this->awards_mode)
        {
        case 'user': $this->render_userview(); break;            
        case 'games': $this->render_gamesview(); break;
        case 'team': $this->render_teamview(); break;
        case 'prizes': $this->render_prizeview(); break;        
        default: $this->render_gamesview(); break;
        }
        echo "</div>\n";
    }    
    function render_teamview()              {
          global $CFG,$sCourseObj;
          print ('<form action="" method="POST">');
          print('<div align="center">');

                
                //add the name of the Sloodle Awards Module
                print('<h2><div style="text-align:center;">'.$sCourseObj->sloodleRec->name.'</h2></div>');                
                 
                 //if the createTeam button was pressed, display create team form
                          
                       //get all groups 
                      $sloodletable = new stdClass();                
                      $sloodletable->tablealign='center';            
                      $sloodletable->width="50%";
                      $sloodletable->head= array(get_string('awards:existingteams','sloodle'),"",get_string('awards:availteams','sloodle'));
                      $nonPlayerStr = '<select name="availteams[]" style="width:300px;margin:5px 0 5px 0;" multiple="multiple" size="10">';
                      $gameTeamsStr = '<select name="existingteams[]" style="width:300px;margin:5px 0 5px 0;" multiple="multiple" size="10">';
                      $courseGroups = get_records_select('groups','courseid = '. $sCourseObj->courseId );
                      $gameTeams = Array();//non participating teams
                      $nonPlayers  = Array(); //participating teams
                       //get all groups 
                      if ($courseGroups){
                          foreach ($courseGroups as $team){
                              //put teams who are not playing in nonPlayers array
                              if (!get_record('sloodle_awards_teams','groupid',$team->id,'sloodleid',$sCourseObj->sloodleId))  {
                                $nonPlayers[]= $team;        //a team that ISN''T connected to the game 
                                $nonPlayerStr.='<option value="'.$team->id.'">'.$team->name.'</option>';
                              }
                              //put teams who are playing in gameTeams array
                              else {
                               $gameTeams[] = $team; //a team that is connected to the game
                               $gameTeamsStr .='<option value="'.$team->id.'">'.$team->name.'</option>';
                              }
                          }
                      }
                      $nonPlayerStr.='</select>';
                      $gameTeamsStr.='</select>';
                      $addRemoveTeamBtn='<input type="submit" name="addteam" value="'.get_string("awards:addteams","sloodle") .'">';
                      $addRemoveTeamBtn.='<input type="submit" name="removeteams" value="'.get_string("awards:removeteams","sloodle") .'">';  
                      $addRemoveTeamBtn.='<br><br><a targe="_blank" href="'.$CFG->wwwroot.'/group/group.php?courseid='.$sCourseObj->courseId.'">'.get_string('awards:createnewteam','sloodle').'</a>';
                      $rowData=Array();                
                      $rowData[]= $gameTeamsStr;
                      $rowData[]=$addRemoveTeamBtn;
                      $rowData[]= $nonPlayerStr;   
                      $sloodletable->data[]=$rowData; 
                     
                      //now print gameTeam members and members of non playing teams
                      $rowData=Array();                
                      //print gameteams and members first
                      //for each team in the group, print there names of the users
                      $teamGroupStr ="";
                      foreach ($gameTeams as $gameteam){
                        //print team name
                        $teamGroupid = $gameteam->id;
                        $teamGroupStr .= '<b>'.$gameteam->name.'</b>&nbsp;&nbsp;<a target="blank" href="'.$CFG->wwwroot.'/group/members.php?group='.$gameteam->id.'">'.get_string('awards:modifygroupmembership','sloodle').'</a><br><ul>';
                        //get all the user ids in the group
                        $teamMembers = get_records_select('groups_members','groupid = "'.$teamGroupid.'"') ;
                        if ($teamMembers){
                             //have all the team, members now lets print their names
                            foreach ($teamMembers as $tm){
                                //get avname                        
                                $sloodleUser = get_record('sloodle_users', 'userid', $tm->userid);   
                                if ($sloodleUser){
                                    $teamGroupStr .='<li>'.$sloodleUser->avname.'</li>';
                                }                                
                            }
                        $teamGroupStr .= "</ul><br>";                                                        
                        }
                      }
                      $rowData[]= $teamGroupStr;
                      $rowData[]="";
                      $teamGroupStr ="";
                      
                      //now print nonPlaying teams members 
                      
                      foreach ($nonPlayers as $np){
                        //print team name
                        $teamGroupid = $np->id;
                        $teamGroupStr .= '<b>'.$np->name.'</b>&nbsp;&nbsp;<a target="blank" href="'.$CFG->wwwroot.'/group/members.php?group='.$np->id.'">'.get_string('awards:modifygroupmembership','sloodle').'</a><br><ul>';
                        //get all the user ids in the group
                        $teamMembers = get_records_select('groups_members','groupid = "'.$teamGroupid.'"') ;
                        if ($teamMembers){
                             //have all the team, members now lets print their names
                            foreach ($teamMembers as $tm){
                                //get avname                        
                                $sloodleUser = get_record('sloodle_users', 'userid', $tm->userid);   
                                if ($sloodleUser){
                                    $teamGroupStr .='<li>'.$sloodleUser->avname.'</li>';
                                }                                
                            }
                       
                        } else {
                           $teamGroupStr .= "<li>".get_string('awards:nomembers','sloodle')."</li>"; 
                            
                        }
                         $teamGroupStr .= "</ul><br>";                                                        
                      }
                      $rowData[]= $teamGroupStr;
                      //add to the table
                           $sloodletable->data[]=$rowData;  
                   
                      print_table($sloodletable);
                                 
                print('</div>');    
                print ('</form>');                
        
       
        
    }
    function render_prizeview() {
          global $CFG,$sCourseObj;
          print('<div align="center">');
                
                echo '<h2><div style="text-align:center;">'.$sCourseObj->sloodleRec->name.'<h2>'.get_string('awards:prizes','sloodle').'<br>';
           print('</div>'); 
            
        
       
        
    }
    function avnameSort($a, $b){
        if ($a->avname == $b->avname) {
            return 0;
        }
        return ($a->avname < $b->avname) ? -1 : 1;
    }
    function render_gamesview()              
    {
        global $sloodle;
        global $CFG, $USER,$sCourseObj,$awardsObj;   
        $this->courseid = $sCourseObj->courseId;
        $sloodleid=$awardsObj->sloodleId;
        $action = optional_param('action');  
        switch ($action){
         case "getgame":
            //get user id
            $gameid = optional_param('gameid');     
            $this->printPointsTable($gameid);
         break;
         default: 
         // Print a Table Intro
            print('<div align="center">');
                          
                echo '<h2><div style="text-align:center;">'.$sCourseObj->sloodleRec->name.'</div> <div style="color:black;text-align:center;">'.get_string('awards:gameslist','sloodle').'<h2>';
                 
                
            //==================================================================================================================
            
           if ($this->getRenderMessage()){
            print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara'); 
                print ('<h1 style="color:red;text-align:center;">'.$this->getRenderMessage().'</div>');
            print_box_end();
            
           }
           
           print('</div>'); 
        
            //======Print Games list
            $tsloodletable = new stdClass();  
             $tsloodletable->head = array(             
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:gamename', 'sloodle').'</h4>',
             '<h4><div style="color:black;text-align:center;">'.get_string('awards:gamenumber', 'sloodle').'<br></h4>',
             '<h4><div style="color:red;text-align:center;">'.get_string('awards:date', 'sloodle').'</h4>',
             '<h4><div style="color:green;text-align:right;">'.get_string('awards:1st', 'sloodle').'</h4>',             
             '<h4><div style="color:green;text-align:right;">'.get_string('awards:2nd', 'sloodle').'</h4>',             
             '<h4><div style="color:green;text-align:right;">'.get_string('awards:3rd', 'sloodle').'</h4>');             
              //set alignment of table cells                                        
            $tsloodletable->align = array('left','left','right','right','right','right');
            $tsloodletable->width="95%";
            //set size of table cells
            $tsloodletable->size = array('10%','5%', '10%','25%','25%','%25');
            $games = $awardsObj->awards_getGames();
            if (!empty($games)){
              foreach ($games as $g){
                    $trowData= Array();            
                     
                    $link_url=' <a href="'.$CFG->wwwroot.'/mod/sloodle/view.php?id=';
                    $link_url.=$sCourseObj->cm->id.'&';
                    $link_url.='action=getgame&gameid='.$g->id.'">(details)</a>';                    
                    $trowData[]=$g->name.$link_url;             
                    $trowData[]=$g->id;     
                    $trowData[]=date("F j, Y, g:i a",$g->timemodified);             
                    $scoreData = $awardsObj->getScores($g->id,'balance');                               
                    if ($scoreData[0]) $trowData[]=$scoreData[0]->avname." (" . $scoreData[0]->score." pts)"; else $trowData[]="none";  
                    if($scoreData[1]) $trowData[]=$scoreData[1]->avname." (" . $scoreData[1]->score." pts)";else $trowData[]="none";  
                    if($scoreData[2])$trowData[]=$scoreData[2]->avname." (" . $scoreData[2]->score." pts)";else $trowData[]="none";  
                   
                 
                    
                    $tsloodletable->data[] = $trowData;                     
              }
              
              print_table($tsloodletable); 
            }
            else {
                print('<div style="text-align:center;">');
                print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara'); 
                print ('<h1 style="color:red;text-align:center;">'.get_string('awards:nogames','sloodle').'</div>');
                print_box_end();
                print('</div>');                
            }
            
        //==================================================================================================================
            
        
       }
    }
    
 function render_userview()              
    {
        global $sloodle;
        global $CFG, $USER,$sCourseObj,$awardsObj;   
        $this->courseid = $sCourseObj->courseId;
        $sloodleid=$awardsObj->sloodleId;
        $action = optional_param('action');  
        switch ($action){
         case "gettrans":
            //get user id
            $userid = optional_param('userid');           
            $gameid = optional_param('gameid');     
            $this->printTransTable($userid,$gameid);
            
         break;
         default: 
         // Print a Table Intro
            print('<div align="center">');
          
                $iTable = new stdClass();
                $iRow = array();
                
//                $totalusers =  $totals->totalusers;
                $sloodletable = new stdClass();
                $sloodletable->tablealign='center';
                
                $img = '<img src="'.$CFG->wwwroot.'/mod/sloodle/icon.gif" width="16" height="16" alt=""/> ';
                $rowData=Array();
                $rowData[]=get_string('awards:course','sloodle'). $img.$sCourseObj->courseRec->fullname. $img.get_string('awards:userview','sloodle');;
                $sloodletable->data[]=$rowData;
                $rowData=Array();
                $rowData[]='<h2><div style="color:blue;text-align:center;">'.$sCourseObj->sloodleRec->name.'<h2>';
                $sloodletable->data[]=$rowData;
                
                print_table($sloodletable); 
                 
                
            //==================================================================================================================
               
           if ($this->getRenderMessage()){
            print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara'); 
                print ('<h1 style="color:red;text-align:center;">'.$this->getRenderMessage().'</div>');
            print_box_end();
            
           }
           print('</div>'); 
            //======Print STUDENT TRANSACTIONS
              $userList =$awardsObj->getScores();    
              $newList = array();
              if (!empty($userList)){
              foreach ($userList as $u){
                  $newU = new stdClass();
                  foreach ($u as $uu=>$val){
                      $newU->$uu = $val;
                  }
                  $sloodledata = get_record('sloodle_users', 'userid', $u->id);
                  
                  if (!empty($sloodledata)){
                      if ($sloodledata->avname)
                        $newU->avname = $sloodledata->avname;
                      if ($sloodledata->uuid)                        
                        $newU->uuid = $sloodledata->uuid;
                        $trans_details = $awardsObj->awards_getBalanceDetails($u->id);
                       if (!$trans_details) {
                           $credits=0; $debits=0;$balance=0;
                       }else{
                           $newU->credits=$trans_details->credits;
                           $newU->debits=$trans_details->debits;
                           $newU->balance=$trans_details->balance;
                       }
                      
                      $newList[]=$newU;
                      
                  }
                  
                  }
              }
              
            usort($newList,array("sloodle_view_awards",  "avnameSort"));
            if ($newList){
              print("<div align='center'>");
                $this->printPointsTable($newList);
                 print("</div>"); 
            }
           
            else {
                
                print('<div style="text-align:center;">');
                print_box_start('generalbox boxaligncenter boxwidthnarrow leftpara'); 
                print ('<h1 style="color:red;text-align:center;">'.get_string('awards:nostudents','sloodle').'</div>');
                print_box_end();
                print('</div>');                
            }
            
        //==================================================================================================================
           
             //  $this->destroy();        
        
       }
    }


 
 
  /**
 * addCommas takes an array of strings and add commas between elements except at the last element, or if there is only one element
 * @param array $arrList
 * @return string
 */ 
 function addCommas($arrList){
     $runTwice=false;  //for the comma to print correctly
     $newList = '';
     foreach ($arrList as $arr){
         
         if ($runTwice) $newList.=",";
         $runTwice = true;
         $newList .=$arr; 
     }
     return $newList;
 
 
 }  
  
 /**
 * buildAvTable function
 * @desc Simply sets up the inner avatar table, alignment, and sizes 
 * @staticvar object $avTable
 * @param null
 * @link http://sloodle.googlecode.com
 * @return object 
 */ 
 function buildAvTable(){
 //create inter avatar table
        $avTable = new stdClass();        
        $avTable->align = array('left','right');
        $avTable->size = array('70%','30%');
        $avTable->data = null;
   return $avTable;
 
 }  
 
 function setRenderMessage($str){
    $this->renderMessage=$str;
    
 }
 function getRenderMessage(){
    return $this->renderMessage;
 }
        
}

          
?>
