<?php
/****************************************************************************************************
* Defines a plugin class for the SLOODLE hq -
* 
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributer Paul G. Preibisch - aka Fire Centaur 
* 
*****************************************************************************************************/
/** SLOODLE course object data structure */
require_once(SLOODLE_LIBROOT.'/sloodlecourseobject.php');
/** SLOODLE awards object data structure */
require_once(SLOODLE_DIRROOT.'/mod/awards-1.0/awards_object.php');

class SloodleApiPluginUser  extends SloodleApiPluginBase{

        
    function balanceSort($a, $b){
        if ($a->balance == $b->balance) {
            return 0;
        }
        return ($a->balance > $b->balance) ? -1 : 1;
    }
    function nameSort($a, $b){
        if ($a->avname == $b->avname) {
            return 0;
        }
        return ($a->avname < $b->avname) ? -1 : 1;
    }
     
     /**
     * getUserList Returns a list of users in the course
     * @return array of table rows
     */
      function getUserList(){
          global $sloodle;   
          global $CFG;            
           //get all the users from the users table in the moodle database that are members in this class   
           $sql = "select u.*, ra.roleid from ".$CFG->prefix."role_assignments ra, ".$CFG->prefix."context con, ".$CFG->prefix."course c, ".$CFG->prefix."user u ";
           $sql .= " where ra.userid=u.id and ra.contextid=con.id and con.instanceid=c.id and c.id=".$sloodle->course->controller->cm->course;
           $fullUserList = get_records_sql($sql);          
           return $fullUserList;                          
      }
        /**
        * getAvatarList Returns a list of avatars in the course
        * @param $userList an array of users of the site
        * @return array of table rows of avatars (userid,username,avname,uuid)
        */
      function getAvatarList($userList){
         $avList = array();
         if ($userList){
         foreach ($userList as $u){             
             $sloodledata = get_records('sloodle_users', 'userid', $u->id);   
             //only adds users who have a linked avatar
             if ($sloodledata){
                foreach ($sloodledata as $sd){
                   $av = new stdClass(); 
                   $av->userid = $u->id;
                   $av->username = $u->username;                                      
                   $av->avname = $sd->avname;
                   $av->uuid = $sd->uuid;                   
                   $avList[]=$av;
                  
                }
               }
             }
         }
         return $avList;
      } 
       
      
     /*
     *   getClassList() will return all users with avatars in a course, along with other data:
     *   UUID:uuid|AVNAME:avname|BALANCE:balance|DEBITS:debits
     llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getClassList&sloodleid="+(string)currentAwardId+"&senderuuid="+(string)owner+"&index="+(string)index_getClassList+"&sortmode="+sortMode, NULL_KEY);
     */ 
      function getClassList(){
         global $sloodle;
         //sloodleid is the id of the record in mdl_sloodle of this sloodle activity
         $sloodleid = $sloodle->request->optional_param('sloodleid');
         $currency= $sloodle->request->optional_param('currency');
         if ($currency="")$currency="Credits";
         //coursemoduleid is the id of course module in sdl_course_modules which refrences a sloodleid as a field in its row called ""instance.""
         //when a notecard is generated from a sloodle awards activity, the course module id is given instead of the id in the sloodle table
         //There may be some instances, where the course module is sent instead of the instance. We account for that here.
         $coursemoduleid= $sloodle->request->optional_param('sloodlemoduleid');    
         if (!$coursemoduleid){
            //cmid is the module id of the sloodle activity we are connecting to
             $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
             $cmid = $cm->id;
         }
         else $cmid= $coursemoduleid;
         
         $sCourseObj = new sloodleCourseObj($cmid);  
         $awardsObj = new Awards((int)$cmid);
         $NUM_USERS_TO_RETURN=10;          
         $senderUuid= $sloodle->request->required_param('sloodleuuid');    
         $index        = $sloodle->request->required_param('index');    
         $gameid= $sloodle->request->required_param('gameid');    
         $sortMode     = $sloodle->request->required_param('sortmode');    
          /*  Send message back into SL
           *      LINE   MESSAGE
           *      0)     1 | OK
           *      1)     SENDERUUID:uuid
           *      2)     NUMUSERS:12
           *      3)     INDEX:0
           *      4)     SORTMODE:name/balance
           *      4)     UUID:uuid|AVNAME:avname|BALANCE:balance|DEBITS:debits
           *      5)     UUID:uuid|AVNAME:avname|BALANCE:balance|DEBITS:debits
           *      6)     UUID:uuid|AVNAME:avname|BALANCE:balance|DEBITS:debits
           *      7)     ...
           *      8)     UUID:uuid|AVNAME:avname|BALANCE:balance|DEBITS:debits
           *      9)     EOF
           */
            $sloodle->response->set_status_code(1);             //line 0    1
            $sloodle->response->set_status_descriptor('OK');    //line 0    OK  
            $sloodle->response->add_data_line("SENDER:".$senderUuid);//line 1                     
                      
                       
           
                 $avatarList = array();
                 
                 if ($sortMode=="balance")  $avatarList = $awardsObj->getScores((int)$gameid,"balance"); 
                 if ($sortMode=="name")  $avatarList = $awardsObj->getScores((int)$gameid,"name");   
                $sloodleData="";
                $size = count($avatarList);
                $i = 0;
           if ($size>0){
                $currIndex = $index;                
                $sloodle->response->add_data_line("INDEX:". $index);                  
                $sloodle->response->add_data_line("USERS:". $size );    
                $sloodle->response->add_data_line("SMODE:". $sortMode);   
                foreach ($avatarList as $av){                          
                   //print only the NUM_USERS_TO_RETURN number of users starting from the current index point                   
                   if (($i < $currIndex) || ($i > ($currIndex + $NUM_USERS_TO_RETURN-1))) {
                       $i++;                   
                       continue; //skip the ones which have already been sent                
                   }                 
                   else{
                   
                       $sloodleData = "UUID:".$av->avuuid."|";
                       $sloodleData .="AV:".  $av->avname . "|";
                       $sloodleData .="SCORE:".$av->score."|";
                       $sloodleData .= "DEBITS:".$av->debits;                   
                       $sloodle->response->add_data_line($sloodleData);   
                       $i++;
                       if ($i==$avListLen){                             
                           $sloodle->response->add_data_line("EOF");
                       }
                   }
                
                }//foreach  
            } else{//$avatarList is empty
                $sloodle->response->set_status_code(80002);             //no avatars
                $sloodle->response->set_status_descriptor('HQ');    //line 0    OK   
            } 
    
    } //getClassList
    
        /*
        * getAwardMbrs will return a list of users with 
        * avatars in the course along with a tag indicating if they are a member of the group
        * This function can be called in SL using the following linked message:
        llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getAwardGrpMbrs&sloodleid="+(string)currentAwardId+"&senderuuid="+(string)owner+"&grpname="+clickedGroup+"&index="+(string)index+"&sortmode=name", NULL_KEY);
        */
        function getAwardGrpMbrs(){
           $NUM_USERS_TO_RETURN=10; 
           global $sloodle;           
             $sloodleid = $sloodle->request->optional_param('sloodleid');
             //coursemoduleid is the id of course module in sdl_course_modules which refrences a sloodleid as a field in its row called ""instance.""
             //when a notecard is generated from a sloodle awards activity, the course module id is given instead of the id in the sloodle table
             //There may be some instances, where the course module is sent instead of the instance. We account for that here.
             $coursemoduleid= $sloodle->request->optional_param('sloodlemoduleid');    
             if (!$coursemoduleid){
                //cmid is the module id of the sloodle activity we are connecting to
                 $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
                 $cmid = $cm->id;
             }
             else $cmid= $coursemoduleid;
           $sCourseObj = new sloodleCourseObj($cmid);  
           $awardsObj = new Awards((int)$cmid);           
           $senderUuid= $sloodle->request->required_param('sloodleuuid'); 
           $groupName  = $sloodle->request->required_param('grpname'); 
           $gameid = $sloodle->request->required_param('gameid'); 
           $index      = $sloodle->request->required_param('index'); 
           $sortMode   = $sloodle->request->required_param('sortmode'); 
           $groupId = groups_get_group_by_name($sCourseObj->courseId,$groupName);
           if (!$groupId){
                $sloodle->response->set_status_code(-500401); //group doesnt exist in course 
                $sloodle->response->set_status_descriptor('GROUPS');    //line 0    OK                              
                $sloodle->response->add_data_line("GRPNAME:".$groupName);
                return;
           } 
           //response line 1                           
           $sloodle->response->set_status_code(1);
           $sloodle->response->set_status_descriptor('OK');    //line 0    OK         
             //index line 2
           $sloodle->response->add_data_line("INDEX:".$index);
           //total users line 3                           
           $players= get_records('sloodle_award_players','gameid',$gameid);
           $members = array();
           $line=array();
           if ($players){
               foreach($players as $p){
                   if (groups_is_member($groupId,$p->userid)){
                       //avuuid|avname|balance|membershipstatus
                       $line[]="uuid:".$p->avuuid."|avname:".$p->avname."|balance:".$p->score."|mbr:yes";
                        $members[]=$p;   
                   }
                   else{
                       $line[]="uuid:".$p->avuuid."|avname:".$p->avname."|balance:".$p->score."|mbr:no";

                   }
               }
           }
           else{
            $sloodle->response->set_status_code(80002);             //no avatars
            $sloodle->response->set_status_descriptor('HQ');    //line 0    OK      
             //line 3
           $sloodle->response->add_data_line("TOTALusers:".count($line));
           //line 4
           $sloodle->response->add_data_line("TOTALMBRS:".count($members));
           //line 5
           $sloodle->response->add_data_line("GRPNAME:".$groupName);   
           $sloodle->response->add_data_line("RESP:".get_string('awards:noplayers','sloodle'));   
            return;           
           }        
           //line 3
           $sloodle->response->add_data_line("TOTALusers:".count($line));
           //line 4
           $sloodle->response->add_data_line("TOTALMBRS:".count($members));
           //line 5
           $sloodle->response->add_data_line("GRPNAME:".$groupName);
           foreach ($line as $l){
               $sloodle->response->add_data_line($l);
           }
           return;
           
        }
           
           
        function getEnrolledCourses(){           
           global $sloodle;    
              
           $avname= $sloodle->request->required_param('avname');
             $avuuid= $sloodle->request->required_param('avuuid');
             $avUser = new SloodleUser( $sloodle );
             $avUser->load_avatar($avuuid,$avname);
             $avUser->load_linked_user();
             $userid = $avUser->avatar_data->userid;    
             if (!empty($userid)){
             $is_registered = $sloodle->user->is_user_loaded();             
                 if ($is_registered) {                    
                    $usercourses = array();
                    $courses = get_courses(0);
                    // Go through each course
                    $sloodle->response->set_status_code(1);             //line 0    1
                    $sloodle->response->set_status_descriptor('OK');    //line 0    OK  
                     
                    foreach ($courses as $course) {
                        // Check if the user can view this course and is not a guest in it.
                        // (Note: the site course is always available to all users.)
                        $course_context = get_context_instance(CONTEXT_COURSE, $course->id);
                        $sc = new SloodleCourse();
                        $sc->load($course);
                         if ($sc->course_object->id!=1){
                         $cost=$sc->course_object->cost;
                         if (empty($cost))$cost=0;
                        if (has_capability('moodle/course:view', $course_context, $sloodle->user->get_user_id()) && !has_capability('moodle/legacy:guest', $course_context, $sloodle->user->get_user_id(), false)) {
                           
                                $sloodle->response->add_data_line($sc->course_object->id."|".$sc->course_object->fullname."|".$cost."|1");
                                   
                                }else{
                                   $sloodle->response->add_data_line($sc->course_object->id."|".$sc->course_object->fullname."|".$cost."|0"); 
                                }
                        }
                        
                    }
             }
             } 
            
    }//enrolled
     /**********************************************************
     * addGrpMbr will attempt to add a member to a group 
     * called by: 
     * llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "plugin:user,function:addGrpMbr\nSENDERUUID:"+(string)owner+"|GROUPNAME:"+current_grp_membership_group+"|USERUUID:"+(string)useruuid|USERNAME:avname, NULL_KEY);
     * @output status_code: -500800 user doesn?t have capabilities to edit group membersip
     */
     function addGrpMbr(){
        global $sloodle;
         //sloodleid is the id of the record in mdl_sloodle of this sloodle activity
         $sloodleid = $sloodle->request->optional_param('sloodleid');
         //coursemoduleid is the id of course module in sdl_course_modules which refrences a sloodleid as a field in its row called ""instance.""
         //when a notecard is generated from a sloodle awards activity, the course module id is given instead of the id in the sloodle table
         //There may be some instances, where the course module is sent instead of the instance. We account for that here.
         $coursemoduleid= $sloodle->request->optional_param('sloodlemoduleid');    
         if (!$coursemoduleid){
            //cmid is the module id of the sloodle activity we are connecting to
             $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
             $cmid = $cm->id;
         }
         else $cmid= $coursemoduleid;
        
                
        $sender_uuid= $sloodle->request->required_param('sloodleuuid');   
        $sender_name=$sloodle->request->required_param('sloodleavname');
        $avUser = new SloodleUser( $sloodle );
        $avUser->load_avatar($sender_uuid,$sender_name);
        $avUser->load_linked_user();
        $sender_moodle_id= $avUser->avatar_data->userid;
        $grpName =  $sloodle->request->required_param('grpname');
        $newMemberUuid =$sloodle->request->required_param('avuuid');
        $newMemberName= $sloodle->request->required_param('avname');
        $courseId = $sloodle->course->get_course_id();
        $context = get_context_instance(CONTEXT_COURSE, $courseId);
        //check to see if user has authority to edit group membership
        if (!has_capability('moodle/course:managegroups', $context,$sender_moodle_id)) {
           $sloodle->response->set_status_code(-500800);     //@output status_code: -500800 user doesn?t have capabilities to edit group membersip
           $sloodle->response->set_status_descriptor('GROUPS'); //line 0  
           $sloodle->response->add_data_line("GRP:".$grpName);
           $sloodle->response->add_data_line("MBRNAME:".$newMemberName);
           $sloodle->response->add_data_line("MBRUUID:".$newMemberUuid);
           return;
        }//has_capability('moodle/course:managegroups'
        //search for group to get id, then add to the sloodle_award_teams database
        $grpName=urldecode($grpName);
        $groupId = groups_get_group_by_name($courseId,$grpName);
        if ($groupId){            
            $avUser = new SloodleUser( $sloodle );
            $avUser->load_avatar($newMemberUuid,$newMemberName);
            $avUser->load_linked_user();
            $newMemberMoodleId= $avUser->avatar_data->userid;
            if (groups_add_member($groupId,$newMemberMoodleId)){
                $sloodle->response->set_status_code(1);             //line 0 
                $sloodle->response->set_status_descriptor('OK'); //line 0 
           $sloodle->response->add_data_line("GRP:".$grpName);
           $sloodle->response->add_data_line("MBRNAME:".$newMemberName);
           $sloodle->response->add_data_line("MBRUUID:".$newMemberUuid);
            }else{//could not add user to group
                $sloodle->response->set_status_code(-500900); //-500900 could not add user to group
                $sloodle->response->set_status_descriptor('GROUPS'); //line 0                 
            }
            return;
        }else {//groupid is null
            //@output status_code: -500400 group doesnt exist for this course 
            $sloodle->response->set_status_code(-500400);     
            $sloodle->response->set_status_descriptor('GROUPS'); //line 0      
           $sloodle->response->add_data_line("GRP:".$grpName);
           $sloodle->response->add_data_line("MBRNAME:".$newMemberName);
           $sloodle->response->add_data_line("MBRUUID:".$newMemberUuid);
            return;
        } 
            
     }
      function enrolUser(){
        global $sloodle;
                
        $avuuid= $sloodle->request->required_param('avuuid');   
        $avname=$sloodle->request->required_param('avname');
        $courseid=$sloodle->request->required_param('courseid');
        $avUser = new SloodleUser( $sloodle );
        $avUser->load_avatar($avuuid,$avname);
        $avUser->load_linked_user();
        $userid= $avUser->avatar_data->userid;
        $is_enrolled = false;
        $is_registered = $sloodle->user->is_user_loaded();  
        if ($is_registered) {
            $is_enrolled = $sloodle->user->is_enrolled($courseid);
            if ($is_enrolled){
                //user is already enrolled
                   $sloodle->response->set_status_code(401);             //line 0 - User is already enrolled
                   $sloodle->response->set_status_descriptor('MISC_REGISTER'); //line 0 
                   return;                
            }else{
                //user is not enrolled so enrol them into the course
                 $sc = new SloodleCourse();
                 $sc->load((int)$courseid);
                 $avUser->enrol($sc);
                 $sloodle->response->set_status_code(1);
                 $sloodle->response->set_status_descriptor('OK');
                 $sloodle->response->add_data_line("CourseId:".$courseid);                  
                 $sloodle->response->add_data_line("avuud:".$avuuid);                  
                 $sloodle->response->add_data_line("avname:".$avname);                  
                 $sloodle->response->add_data_line("userid:".$userid);                  
                
            }
        }else{
            // Add a pending avatar
            $pa = $sloodle->user->add_pending_avatar($sloodleuuid, $sloodleavname);
            if (!$pa) {
                $sloodle->response->set_status_code(-322);
                $sloodle->response->set_status_descriptor('MISC_REGISTER');
                $sloodle->response->add_data_line('Failed to add pending avatar details.');
            } else {
                // Construct and return a registration URL
                $url = SLOODLE_WWWROOT."/login/sl_welcome_reg.php?sloodleuuid=$sloodleuuid&sloodlelst={$pa->lst}";
                if ($sloodlemode == 'regenrol') $url .= '&sloodlecourseid='.$sloodle->course->get_course_id();                
                $sloodle->response->set_status_code(-321);
                $sloodle->response->set_status_descriptor('USER_AUTH');
                $sloodle->response->add_data_line($url);
            }
            
        }
    }
     /**********************************************************
     * removeGrpMbr will attempt to remove a member to a group 
     * called by: 
     llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->removeGrpMbr&sloodleid="+(string)currentAwardId+"&senderuuid="+(string)owner+"&groupname="+currentGroup+"&avuuid="+(string)useruuid+"&avname="+userName, NULL_KEY);
     * 
     * @output status_code: -500800 user doesn?t have capabilities to edit group membersip
     * @output status_code: -500900 could not add user to group
     */
     function removeGrpMbr(){
        global $sloodle;
      
           //sloodleid is the id of the record in mdl_sloodle of this sloodle activity
         $sloodleid = $sloodle->request->optional_param('sloodleid');
         //coursemoduleid is the id of course module in sdl_course_modules which refrences a sloodleid as a field in its row called ""instance.""
         //when a notecard is generated from a sloodle awards activity, the course module id is given instead of the id in the sloodle table
         //There may be some instances, where the course module is sent instead of the instance. We account for that here.
         $coursemoduleid= $sloodle->request->optional_param('sloodlemoduleid');    
         if (!$coursemoduleid){
            //cmid is the module id of the sloodle activity we are connecting to
             $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
             $cmid = $cm->id;
         }
         else $cmid= $coursemoduleid;
        $sCourseObj = new sloodleCourseObj($cmid);          
        
        
        $sender_uuid=$sloodle->request->required_param('sloodleuuid');    
        $sender_name=$sloodle->request->required_param('sloodleavname');
        $avUser = new SloodleUser( $sloodle );
        $avUser->load_avatar($sender_uuid,$sender_name);
        $avUser->load_linked_user();
        $sender_moodle_id= $avUser->avatar_data->userid;
        $grpName =  $sloodle->request->required_param('grpname');    
        $newMemberUuid = $sloodle->request->required_param('avuuid');    
        $newMemberName= $sloodle->request->required_param('avname');    
        $context = get_context_instance(CONTEXT_COURSE, $sCourseObj->courseId);
        //check to see if user has authority to edit group membership
        if (!has_capability('moodle/course:managegroups', $context,$sender_moodle_id)) {
           $sloodle->response->set_status_code(-500800);     //@output status_code: -500800 user doesn?t have capabilities to edit group membersip
           $sloodle->response->set_status_descriptor('GROUPS'); //line 0  
           $sloodle->response->add_data_line($grpName);
           $sloodle->response->add_data_line($newMemberName);
           $sloodle->response->add_data_line($newMemberUuid);
           return;
        }//has_capability('moodle/course:managegroups'
        //search for group to get id, then add to the sloodle_award_teams database
        $grpName=urldecode($grpName); 
        $groupId = groups_get_group_by_name($sCourseObj->courseId,$grpName);
        if ($groupId){            
            $avUser = new SloodleUser( $sloodle );
            $avUser->load_avatar($newMemberUuid,$newMemberName);
            $avUser->load_linked_user();
            $newMemberMoodleId= $avUser->avatar_data->userid;
            if (groups_remove_member($groupId,$newMemberMoodleId)){
                $sloodle->response->set_status_code(1);             //line 0 
                $sloodle->response->set_status_descriptor('OK'); //line 0 
                $sloodle->response->add_data_line($grpName);
                $sloodle->response->add_data_line($newMemberName);
                $sloodle->response->add_data_line($newMemberUuid);                
            }else{//could not add user to group
                $sloodle->response->set_status_code(-500901); //-500901 could not remove user to group
                $sloodle->response->set_status_descriptor('GROUPS'); //line 0                 
            }
            return;
        }else {//groupid is null
            //@output status_code: -500400 group doesnt exist for this award 
            $sloodle->response->set_status_code(-500400);     
            $sloodle->response->set_status_descriptor('GROUPS'); //line 0      
            $sloodle->response->add_data_line($grpName);
            $sloodle->response->add_data_line($newMemberName);
            $sloodle->response->add_data_line($newMemberUuid);                
            return;
        } 
            
     }
}//class
?>
