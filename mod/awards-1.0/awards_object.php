<?php
    /**
    * The awards class provides basic transaction functions for the Sloodle Awards module.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    * @see Awards
    * @contributor Paul G. Preibisch - aka Fire Centaur 
    */
global $CFG;    

require_once(SLOODLE_LIBROOT.'/sloodlecourseobject.php');

  class Awards {
   
      var $sloodleId = null;
      var $transactionRecords = null;
      /*
      * @var $awardRec - the actual record of the stipendgiver from sloodle_stipengiver
      */
      var $sloodle_awards_instance = null;     
      var $currency;
      /*
      * The class Contstructor
      * @var $id - the sloodle id of this stipendgiver
      */
      function Awards($courseModuleId){  
          global $sloodle;
          
          $cm = get_coursemodule_from_id('sloodle',$courseModuleId);              
          $cmid = $cm->instance;
          $this->sloodle_awards_instance = get_record('sloodle_awards','sloodleid',$cmid); 
          $this->sloodleId=$cmid;                     
      }
      
              /*
        * getFieldData - string data sent to the awards has descripters built into the message so messages have a context
        * when debugging.  ie: instead of sending 2|Fire Centaur|1000 we send:  USERID:2|AVNAME:Fire Centaur|POINTS:1000
        * This function just strips of the descriptor and returns the data field 
        * 
        * @param string fieldData - the field you want to strip the descripter from
        */
        function getFieldData($fieldData){
               $tmp = explode(":", $fieldData); 
               return $tmp[1];
        }
      function getScoreboards($name){
        $scoreboardRecs=get_record('sloodle_award_scoreboards','name',$name);    
        return $scoreboardRecs;
      }
        function refreshScoreboard($gameid){
            $scoreboards = get_records('sloodle_award_scoreboards','gameid',$gameid);
            if ($scoreboards){
                foreach ($scoreboards as $sb){
                     $expiry = time()-$sb->timemodified;
                     if ($expiry>60*60*48){
                        //this is url is a week old, delete it because the inworld scoreboards 
                        //update their URL atleast once a week
                        delete_records('sloodle_award_scoreboards','gameid',$sb->gameid);
                    }
                    //get current display of each scoreboard
                    $displayData = $this->sendUrl($sb->url,"COMMAND:GET DISPLAY DATA\n");
                    
                    $dataLines = explode("\n", $displayData);
                    if ($displayData!=FALSE){
                        $currentView = $this->getFieldData($dataLines[0]);
                        if ($currentView=="Top Scores"||$currentView=="Sort by Name"){
                            $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                        }
                    }
                }//foreach scoreboard
            }//endif $scoreboards
     }
     function awards_getGames(){
         return get_records('sloodle_award_games','sloodleid',$this->sloodleId,'id DESC');
         
     }
      //set functions
      function setUrl($url){        
          $scoreboard = new stdClass();
          $scoreboard->url = $url;
          $scoreboard->sloodleid = $this->sloodleId;          
          return insert_record("sloodle_award_scoreboards",$scoreboard);        
      }
      function setAmount($amount){
          $this->sloodle_awards_instance->amount=(int)$amount; 
          $this->timeupdated = (int)time();
          return update_record('sloodle_awards', $this->sloodle_awards_instance);
        
      }
      function getScores($gameid,$currency="Credits",$sortMode,$userid=NULL){
         
         global $CFG;
          $scoreData= array();
         //get players for the game
         if ($userid!=NULL){
          $p= get_record_select('sloodle_award_players',"gameid={$gameid} AND userid={$userid}" );         
          
          $score=$this->awards_getBalanceDetails((int)$userid,(int)$gameid);                            
    
          $p->score =$score->balance;
          $p->credits=$score->credits;
          $p->debits=$score->debits;
          $scoreData[]=$p;
           
         }
         else{
         
          $players= get_records('sloodle_award_players','gameid',(int)$gameid);         
             //get score final score for each player
          foreach ($players as $p){      
                                           
              $score=$this->awards_getBalanceDetails($p->userid,(int)$gameid,$currency);               
              $p->score =$score->balance;
              $p->credits=$score->credits;
              $p->debits=$score->debits;
              $p->currency=$currency;   
              //p is now id,gameid,avuuid,userid,avname,score,credits,debits,timemodified
              $scoreData[]=$p;
              
              
          }
          
          //sort final scores                   
          if ($sortMode=="balance") usort($scoreData,array("Awards",  "scoreSort"));else
          if ($sortMode=="name") usort($scoreData,array("Awards",  "nameSort"));
          
         }
         
         return $scoreData;
         
     } 
     
     function scoreSort($a, $b){
        if ($a->score== $b->score) {
            return 0;
        }
        return ($a->score< $b->score) ? -1 : 1;
    }
        /**********************************
       * synchronizeDisplays_SL($transactions)
       *    This function works the same as the synchronizeDisplays but the transaction object is only one single transaction
       *    It starts by getting all entries in sloodle_award_scoreboards that match this award id. It will then send an http request to the each URL 
       *    "COMMAND:GET DISPLAY DATA" and will receive a response indication which display is currently being viewed, and the data currently being displayed in SL
       *    If the currently displayed data matches the user in the transaction list, then needsUpdating will be set to true, and an update command will be sent
       *    into SL
       * 
       * @param mixed $transactions
       */
       function sendUrl($url,$post){         
             $ch = curl_init(); 
             //curl_setopt($ch, CURLOPT_URL, 'http://sim5468.agni.lindenlab.com:12046/cap/48c6c5fc-f19d-4dc2-6a50-fc3566186508'); 
             // FIND BOOKS ON PHP AND MYSQL ON AMAZON 
            $ch = curl_init();    // initialize curl handle 
            curl_setopt($ch, CURLOPT_URL,$url); // set url to post to 
            curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);// allow redirects 
            curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable 
            curl_setopt($ch, CURLOPT_TIMEOUT, 3); // times out after 4s 
            curl_setopt($ch, CURLOPT_POST, 1); // set POST method 
             curl_setopt($ch, CURLOPT_POSTFIELDS,$post); // add POST fields        
            $result = curl_exec($ch); // run the whole process 
            curl_close($ch);   
             return $result;          
     }
     
      function setIcurrency($icurrency){
        $this->sloodle_awards_instance->icurrency=$icurrency; 
        $this->timeupdated = time();
        return update_record('sloodle_awards', $this->sloodle_awards_instance);  
      }      
      function setTimemodified($timemodified){
        $this->sloodle_awards_instance->timemodified=$timemodified;  
        $this->timeupdated = time();
        return update_record('sloodle_awards', $this->sloodle_awards_instance);  
      } 
    
       /**********************************
       * synchronizeDisplays($transactions)
       *    This function will get all entries in sloodle_award_scoreboards that match this award id. It will then send an http request to the each URL 
       *    "COMMAND:GET DISPLAY DATA" and will receive a response indication which display is currently being viewed, and the data currently being displayed in SL
       *    If the currently displayed data matches any of the users in the transaction list, then needsUpdating will be set to true, and an update command will be sent
       *    into SL
       * 
       * @param mixed $transactions
       */
       function synchronizeDisplays($transactions){
          global $sCourseObj;
           //get all httpIn urls connected to this award
            
           $scoreboards = get_records('sloodle_award_scoreboards','sloodleid',$this->sloodleId);  
           //$sendData='COMMAND:WEB UPDATE|DESCRIPTION:transactionProcessed|AWARDID:'.$sCourseObj->sloodleId."|AVKEY:".$iTransaction->avuuid."|AVNAME:".$iTransaction->avname."|ITYPE:".$iTransaction->itype.'|AMOUNT:'.$iTransaction->amount."|".$iTransaction->idata;
            if ($scoreboards){
                foreach ($scoreboards as $sb){
                    $expiry = time()-$sb->timemodified;
                    if ($expiry>60*60*48){
                        //this is url is a week old, delete it because the inworld scoreboards 
                        //update their URL atleast once a week
                        delete_records('sloodle_award_scoreboards','sloodleid',$sb->sloodleid,'timemodified',$sb->timemodified);
                        
                    }else{
                    //get current display of each scoreboard
                    $displayData = $this->sendUrl($sb->url,"COMMAND:GET DISPLAY DATA\n");
                    $dataLines = explode("\n", $displayData);
                    if ($displayData){
                        $currentView = $this->getFieldData($dataLines[0]);
                        if ($currentView=="Control Station"){
                            //set $needsUpdating initially to false
                           
                            //get number of groups for this scoreboard
                            $groupsInGame =   explode(",", $this->getFieldData($dataLines[1]));
                            $numGroups = count($groupsInGame); 
                            $needsUpdatingArray = array();          
                            //for each scoreboard group, check if transactions have been made for any members
                            $updateString ="";                                                       
                            for ($i=1;$i<$numGroups;$i++){
                                 $needsUpdating = false;        
                                //get group name
                                $groupName = $groupsInGame[$i];                                
                                //get Group record
                                $group = groups_get_group_by_name($sCourseObj->courseId,$groupName);
                                if ($group){
                                    $groupId = $group;
                                    //set updateString to empty
                                    
                                    //go through each transaction and see if it matches this userid
                                    foreach ($transactions as $t){
                                        if (groups_is_member($groupId,$t->userid)){
                                            $needsUpdating = true;                                            
                                        }//if
                                    }//endforeach
                                    if ($needsUpdating){                                        
                                        //get group total;
                                        $groupMembers =groups_get_members($groupId);
                                        $total=0;
                                        foreach ($groupMembers as $gMbr){
                                             $balanceDetails = $this->awards_getBalanceDetails($gMbr->id);
                                             if ($balanceDetails)
                                                $total+=$balanceDetails->balance;                    
                                        }  //foreach
                                        $updateString.="GROUP:".$groupName."|TOTAL:".$total."\n";
                                    }//if
                                }//endif group
                            }//for
                            if ($updateString!=""){
                                //this means one or more of the groups points has changed
                                 $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }
                        }//endif $currentView=="Control Station"
                        else
                        if ($currentView=="Top Scores"||$currentView=="Sort by Name"){
                            $userData = Array();
                            //initially set needsUpdating to false, change to true if any users being displayed have
                            //processed transactions                            
                            $needsUpdating = false;
                            //build user list from display
                            $numUsers = count($dataLines);
                            $updateString="";
                            for ($userCounter=1;$userCounter<$numUsers;$userCounter++){
                                $userData = explode("|", $dataLines[$userCounter]);                                                            //set updateString to empty
                                
                                //check if user is in transaction list
                             
                                    foreach ($transactions as $t){
                                        if (isset($userData[1])){
                                            if ($t->avname==$userData[1]){
                                                $needsUpdating = true;
                                                $updateMsg="AVKEY:".$t->avuuid."|AVNAME:".$t->avname;
                                                $updateMsg.="|ITYPE:".$t->itype.'|AMOUNT:'.$t->amount;
                                                $updateString.=$updateMsg."\n";
                                                //as soon as we find the individual transaction, 
                                                //exit the for loop
                                                break;
                                            }//endif                                                
                                        }//endif isset
                                    }//foreach
                                
                            }//for
                            //if any updates where made to students being displayed on this 
                            //scoreboard send update command into sl
                            if ($needsUpdating){
                                //send update into SL for this scoreboard
                                $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }//endif $needsUpdating
                        }//endif $currentView=="Top Scores"||$currentView=="Sort by Name"
                        else                         
                        if ($currentView=="Team Top Scores"){
                            //set $needsUpdating initially to false
                            $needsUpdating = false;
                            //get the courseId for this award activity
                            
                            //get number of groups for this scoreboard
                            $numGroups = count($dataLines);           
                            //for each scoreboard group, check if transactions have been made for any members
                            for ($i=1;$i<$numGroups;$i++){
                                //get groupData from display
                                $groupData = explode("|", $dataLines[$i]);
                                //get group name
                                $groupName = $groupData[0];                                
                                //get Group record
                                $group = groups_get_group_by_name($sCourseObj->courseId,$groupName);
                                if ($group){
                                    $groupId = $group;
                                    //set updateString to empty
                                    $updateString ="";
                                    //go through each transaction and see if it matches this userid
                                    foreach ($transactions as $t){
                                        if (groups_is_member($groupId,$t->userid)){
                                            $needsUpdating = true;
                                            $updateMsg="AVKEY:".$t->avuuid."|AVNAME:".$t->avname;
                                            $updateMsg.="|ITYPE:".$t->itype.'|AMOUNT:'.$t->amount;
                                            $updateString.=$updateMsg."\n";
                                        }//if
                                    }//endforeach
                                }//endif group
                            }//for
                            if ($needsUpdating){
                                //this means one or more of the groups points has changed
                                $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }
                        }//endif$currentView=="Team Top Scores"
                    }//end if displayData
                    }//expiry
                }//foreach scoreboard
            }//endif $scoreboards
       }//function
       /**********************************
       * synchronizeDisplays_SL($transactions)
       *    This function works the same as the synchronizeDisplays but the transaction object is only one single transaction
       *    It starts by getting all entries in sloodle_award_scoreboards that match this award id. It will then send an http request to the each URL 
       *    "COMMAND:GET DISPLAY DATA" and will receive a response indication which display is currently being viewed, and the data currently being displayed in SL
       *    If the currently displayed data matches the user in the transaction list, then needsUpdating will be set to true, and an update command will be sent
       *    into SL
       * 
       * @param mixed $transactions
       */
        function synchronizeDisplays_sl($transaction){
          global $sloodle,$sCourseObj;
           //get all httpIn urls connected to this award
            $scoreboards = get_records('sloodle_award_scoreboards','sloodleid',(int)$this->sloodleId);
               
            if ($scoreboards){
                foreach ($scoreboards as $sb){
                     $expiry = time()-$sb->timemodified;
                     if ($expiry>60*60*48){
                        //this is url is a week old, delete it because the inworld scoreboards 
                        //update their URL atleast once a week
                        delete_records('sloodle_award_scoreboards','sloodleid',$sb->sloodleid,'timemodified',$sb->timemodified);
                        
                    }else {
                    //get current display of each scoreboard
                    $displayData = $this->sendUrl($sb->url,"COMMAND:GET DISPLAY DATA\n");
                    $dataLines = explode("\n", $displayData);
                    if ($displayData!=FALSE){
                        $currentView = $this->getFieldData($dataLines[0]);
                        if ($currentView=="Top Scores"||$currentView=="Sort by Name"){
                            $userData = Array();
                            //initially set needsUpdating to false, change to true if any users being displayed have
                            //processed transactions                            
                            $needsUpdating = false;
                            //build user list from display
                            $numUsers = count($dataLines);
                            $updateString="";
                            for ($userCounter=1;$userCounter<$numUsers;$userCounter++){
                                $userData = explode("|", $dataLines[$userCounter]);                                                            //set updateString to empty                                //check if user is in transaction list
                                        $t=$transaction;
                                        if ($t->avname==$userData[1]){
                                            $needsUpdating = true;
                                            $updateMsg="AVKEY:".$t->avuuid."|AVNAME:".$t->avname;
                                            $updateMsg.="|ITYPE:".$t->itype.'|AMOUNT:'.$t->amount;
                                            $updateString.=$updateMsg."\n";
                                            //as soon as we find the individual transaction, exit the for loop      
                                            break;
                                        }//endif
                            }//for
                            //if any updates where made to students being displayed on this 
                            //scoreboard send update command into sl
                            if ($needsUpdating){
                                //send update into SL for this scoreboard
                                $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }//endif $needsUpdating
                        }//endif $currentView=="Top Scores"||$currentView=="Sort by Name"
                        else                         
                        if ($currentView=="Team Booth"){
                            $groupName = $this->getFieldData($dataLines[1]);
                            //set $needsUpdating initially to false
                            $needsUpdating = false;
                            //get the courseId for this award activity
                            $courseId = $sloodle->course->get_course_id();                           
                            //for each scoreboard group, check if transactions have been made for any members
                            //get Group record
                            $group = groups_get_group_by_name($sCourseObj->courseId,$groupName);
                            if ($group){
                                
                                $groupId = $group;
                                //set updateString to empty
                                $updateString ="";
                                //go through each transaction and see if it matches this userid
                               $t=$transaction;
                                    if (groups_is_member($groupId,$t->userid)){
                                        $needsUpdating = true;
                                        $updateMsg="AVKEY:".$t->avuuid."|AVNAME:".$t->avname;
                                        $updateMsg.="|ITYPE:".$t->itype.'|AMOUNT:'.$t->amount;
                                        $updateString.=$updateMsg."\n";
                                    }//if

                            }//endif group

                            if ($needsUpdating){
                                //this means one or more of the groups points has changed
                                $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }
                        }//endif$currentView=="Team Booth"
                        else                         
                        if ($currentView=="Team Top Scores"){
                            //set $needsUpdating initially to false
                            $needsUpdating = false;
                            //get the courseId for this award activity
                            $courseId = $sloodle->course->get_course_id();
                            //get number of groups for this scoreboard
                            $numGroups = count($dataLines);           
                            //for each scoreboard group, check if transactions have been made for any members
                            for ($i=1;$i<$numGroups;$i++){
                                //get groupData from display
                                $groupData = explode("|", $dataLines[$i]);
                                //get group name
                                $groupName = $groupData[0];                                
                                //get Group record
                                $group = groups_get_group_by_name($sCourseObj->courseId,$groupName);
                                if ($group){
                                    $groupId = $group;
                                    //set updateString to empty
                                    $updateString ="";
                                    //go through each transaction and see if it matches this userid
                                   $t=$transaction;
                                        if (groups_is_member($groupId,$t->userid)){
                                            $needsUpdating = true;
                                            $updateMsg="AVKEY:".$t->avuuid."|AVNAME:".$t->avname;
                                            $updateMsg.="|ITYPE:".$t->itype.'|AMOUNT:'.$t->amount;
                                            $updateString.=$updateMsg."\n";
                                        }//if

                                }//endif group
                            }//for
                            if ($needsUpdating){
                                //this means one or more of the groups points has changed
                                $result = $this->sendUrl($sb->url,"COMMAND:UPDATE DISPLAY\n".$updateString);
                            }
                        }//endif$currentView=="Team Top Scores"
                        
                    }//end if displayData
                    else {
                        
                    delete_records('sloodle_award_scoreboards','url',$sb->url);
                    }
                    }//expiry
                }//foreach scoreboard
            }//endif $scoreboards

       }//function
      /**
     * @method awards_makeTransaction
     * @author Paul Preibisch
     * 
     * makeTransaction inserts a record into the sloodle_award_trans table
     * then sends an xml message into Second Life to trigger the scoreboard to request an update
     * It then updates the grade in the gradebook
     *  
     * @package sloodle
     * @returns returns true if insert was successful
     * @returns returns false if insert was unsuccessful  
     * 
     * @$iTransaction is a dataObject (stdClass object)  with appropriate fields matching the table structure
     */
      function awards_makeTransaction($iTransaction,$sCourseObject){      
         global $USER,$COURSE,$CFG; 
         
         
        if (insert_record('sloodle_award_trans',$iTransaction)) {
            $balanceDetails = $this->awards_getBalanceDetails($iTransaction->userid,$iTransaction->gameid);   
            if ($balanceDetails->balance<0){
              $iTransaction->amount=  $balanceDetails->balance*-1;
              $iTransaction->itype="credit";
              $iTransaction->idata="DETAILS:System Modified Balance adjustment"; 
              insert_record('sloodle_award_trans',$iTransaction); 
            }//endif
            
            //get maxpoint limit
            $maxPoints = $this->sloodle_awards_instance->maxpoints;
            //Get balance 
            $newGrade=0;
            $detailsRec = $this->awards_getBalanceDetails($iTransaction->userid,$iTransaction->gameid);            
            //make sure we dont give more points than max points
            $pointsEarned = $detailsRec->balance;            
            return true;
        }
        else return false;
      }
    /**
     * @method awards_getTransactionRecords
     * @author Paul Preibisch
     * 
     * getTransactionRecords returns the recordset of sloodle_award_trans record 
     * for the $userId specified.  if $userId is null, returns all the transaction records for this stipend
     *  
     * @package sloodle
     * @return returns transaction records for this user / or for all users
     * @return If $userId is null, then all transactions are returned
     * 
     * @staticvar $userId moodle id of the user
     */
      function awards_getTransactionRecords($userId=null,$gameid){
          global $CFG,$awardsObj;
         if (!$userId){
             $sql = "select * from {$CFG->prefix}sloodle_award_trans where  gameid={$gameid} ORDER BY Timemodified DESC";
             
            return get_records_sql($sql);
         }
         else {
             $sql="select * from {$CFG->prefix}sloodle_award_trans where gameid={$gameid} AND userid={$userId} ORDER BY Timemodified DESC";
             
            return get_records_sql($sql);
         }
      }
      /**
       * getTotals - returns the credit, debit, and balance totals for all of the students 
       * 
       */
       function getTotals(){
         global $CFG; 
         $totalAmountRecs = get_records_select('sloodle_award_trans','itype=\'credit\' AND sloodleid='.$this->sloodleId);
         $credits=0;
         if ($totalAmountRecs)
            foreach ($totalAmountRecs as $userCredits){
                 $credits+=$userCredits->amount;
            }
         $totalAmountRecs = get_records_select('sloodle_award_trans','itype=\'debit\' AND sloodleid='.$this->sloodleId);
         $debits=0;         
         if ($totalAmountRecs)
            foreach ($totalAmountRecs as $userDebits){
                 $debits+=$userDebits->amount;
            }
         $balances = $credits-$debits;
         $totals= new stdClass();
         $totals->totalcredits = $credits;
         $totals->totaldebits = $debits;
         $totals->totalbalances = $credits - $debits;  
         
         return $totals;
      }
     
      /**
     * @method removeTransaction
     * @author Paul Preibisch
     * 
     * removeTransaction removes the transaction for this stipend     
     *  
     * @package sloodle
     * @return true if successful
     * @return false if unsuccessful
     * 
     * @staticvar $userId moodle id of the user
     * @staticvar $iType type of the transaction "stipend","credit","debit"
     */
     
     function awards_removeTransaction($userId,$iType){
         return delete_records("sloodle_award_trans",'sloodleid',$this->getSloodleId(),'itype',$iType,'userid',$userId);
     }
     function awards_updateTransaction($transRec){
        if (!update_record("sloodle_award_trans",$transRec))
            error(get_string("cantupdate","sloodle"));
     }
     function get_assignment_id(){
         return $this->sloodle_awards_instance->assignmentid;
     }
     function get_assignment_cmid($courseId){
         
          $recs = get_record('course_modules','instance',(int)$this->sloodle_awards_instance->assignmentid,'course',(int)$courseId);
         if ($recs)
            return $recs->id;
         else return null;
     }
     function get_assignment_name(){
         $recs = get_record('assignment','id',(int)$this->sloodle_awards_instance->assignmentid);
         if ($recs)
            return $recs->name;
         else return null;
     }
      
      /**
     * @method getLastTransaction
     * @author Paul Preibisch
     * 
     * getLastTransaction will retrieve the last transaction made for this user
     *  
     * @package sloodle
     */
     function getLastTransaction($avuuid,$details)    {
         global $CFG; 
         //get the maximum id (the last transaction) of a user with the details in idata in transaction db - this is the last transaction
        
         //get id of user         
         $awardTrans = get_records_select('sloodle_award_trans','avuuid',addSlashes($avuuid),'sloodleid',$this->sloodleId);         
         $maxId = 0;         
         foreach ($awardTrans as $trans){
             //find records with the $details in the idata
            if (strstr($awardTrans->idata,addSlashes($details))){
                //find max id
                if ($awardTrans->id>$maxId){
                    $maxId=$awardTrans->id;
                }                
            }
         }
         if ($maxId!=0){
             $rec = get_record('sloodle_award_trans','id',$maxId);            
             return $rec;
         }else {             
             return "";
         }
     } 
      /**
     * @method findTransaction
     * @author Paul Preibisch
     * 
     * getLastTransaction will retrieve the last transaction made for this user
     *  
     * @package sloodle
     */
     function findTransaction($avuuid,$details)    {
      global $CFG; 
         //get the maximum id (the last transaction) of a user with the details in idata in transaction db - this is the last transaction
        
         //get id of user         
         $awardTrans = get_records_select('sloodle_award_trans',"avuuid='".addSlashes($avuuid)."'".' AND sloodleid='.$this->sloodleId);         
         $foundArray = Array();      
         foreach ($awardTrans as $trans){
             //find records with the $details in the idata
            if (strstr($trans->idata,addSlashes($details))){
                //find max id
               $foundArray[]=$trans;
            }
         }
         return $foundArray;
     } 
     /* awards_getBalanceDetails - gets the total balance, credit, debits for a user
     *  @author Paul Preibisch
     * 
     * @package sloodle
     * @return returns a stdObj with credits, debits, balance for the given userid
     */       
     function awards_getBalanceDetails($userid,$gameid,$currency="Credits"){
         global $CFG;
          $sql = "select sum(case itype when 'debit' then cast(amount*-1 as signed) else amount end) as balance";
          $sql.= " from {$CFG->prefix}sloodle_award_trans";
          $sql.=" where gameid={$gameid} AND currency='{$currency}' AND userid={$userid} ORDER BY balance DESC";
           
          $totalAmountRecs = get_record_sql($sql);
          $accountInfo = new stdClass();
          $accountInfo->credits = 0;
          $accountInfo->debits = 0;          
          $accountInfo->balance = $totalAmountRecs->balance;
          
         return $accountInfo;      
     } 
   
     /**
     * getAvatarDebits function
     * @desc This function will search through all the transactions 
     * for a sloodle_awards instance based on avatar uuid and return the TOTAL debits amount
     * @staticvar integer $debitAmount will be zero if no debits exist for this user and stipend
     * @param string $avuuid the avatar UUID to search for
     * @link http://sloodle.googlecode.com
     * @return integer 
     */ 
     function getAvatarDebits($avuuid){
          //transactionRecords fields are: 
          //avuuid,userid,avname,amount,type,timemodified
          $debits = 0;   
         foreach ($this->getTransactionRecords() as $t){
            if ($t->avuuid == $avuuid)
               if ($t->itype=='debit')
                    $debits +=$t->amount;
         }
         return $debits; 
     } 
     /**
 * getUserDebits function
 * @desc This function will search through all the transactions 
 * and return TOTAL debits for this course user
 * @staticvar integer $debitAmount will be zero if no debits exist for this user and stipend
 * @param string $avuuid the avatar UUID to search for
 * @link http://sloodle.googlecode.com
 * @return integer 
 */ 
 function getUserDebits($userid=null){
      //transactionRecords fields are: 
      //avuuid,userid,avname,amount,type,timemodified
      $debits = 0;
      if ($userid==null)
          $transRecs = $this->getTransactionRecords();
      else      
          $transRecs = $this->getTransactionRecords($userid);
          if ($transRecs)
            foreach ($transRecs as $t)
                   if ($t->itype=='debit')
                       $debits +=$t->amount;
     return $debits; 
 }
    function get_class_list(){
            $fulluserlist = get_users(true, '');
            if (!$fulluserlist) $fulluserlist = array();
            $userlist = array();
            // Filter it down to members of the course
            foreach ($fulluserlist as $ful) {
                // Is this user on this course?
                if (has_capability('moodle/course:view', $this->course_context, $ful->id)) {
                    // Copy it to our filtered list and exclude administrators
                    if (!isadmin($ful->id))
                      $userlist[] = $ful;
                }
            }
            return $userlist;
      
      }
  }      
?>
