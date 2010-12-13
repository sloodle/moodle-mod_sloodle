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


class SloodleApiPluginGroups  extends SloodleApiPluginBase{
  /**********************************************************
     * getUsersGrps will retrieve a list of groups the user is a member of for this course
     * called by: 
     * llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "plugin:user,function:getUsersGroups\nSLOODLEID:null|USERNAME:"+avName+"|USERUUID:"+(string)avUuid, NULL_KEY);
     */
     function getUsersGrps(){
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
        /***************************
        * Extract data from data stream
        ****************************/
      
        $avName=$sloodle->request->required_param('avname'); 
        $avUuid=$sloodle->request->required_param('avuuid'); 
        //build user
       $avUser = new SloodleUser( $sloodle );
        if ($avUser->load_avatar($avUuid,$avName)){
            if ($avUser->load_linked_user()){
                $userGrps = groups_get_all_groups($sloodle->course->get_course_id(),$avUser->get_user_id());
                if ($userGrps){    
                    $sloodle->response->set_status_code(1);          //@output status_code: 1 ok
                    $sloodle->response->set_status_descriptor('OK'); //line 0  
                    $sloodle->response->add_data_line("NUMGRPS:".count($userGrps));    
                    $sloodle->response->add_data_line("AVNAME:".$avName);    
                    $sloodle->response->add_data_line("AVUUID:".$avUuid);    
                    foreach ($userGrps as $grp){
                        $sloodle->response->add_data_line("GRP:".$grp->name);    
                    }//end foreach usergrp
                    return;
                }//endif userGrps
                else{ //return no groups found
                    $sloodle->response->set_status_code(-55000);     //@output status_code: -55000 user doesn’t have any groups
                    $sloodle->response->set_status_descriptor('GROUPS'); //line 0                      
                    $sloodle->response->add_data_line("AVNAME:".$avName);    
                    $sloodle->response->add_data_line("AVUUID:".$avUuid);                        
                    return;
                }//endelse                
            }//endif loadLinked
            else {   //return error user not linked              
                    $sloodle->response->set_status_code(-301);     //@output status_code: -301 There was an unspecified problem authenticating the user.
                    $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0                      
                    $sloodle->response->add_data_line("AVNAME:".$avName);    
                    $sloodle->response->add_data_line("AVUUID:".$avUuid);                        
                    return;
            }//endelse
        }//endif load avatar
        else{ //return error not registered
            $sloodle->response->set_status_code(-321);     //@output status_code: -321 User was not registered and we weren't allowed to register them automatically.
            $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0                      
            $sloodle->response->add_data_line("AVNAME:".$avName);    
            $sloodle->response->add_data_line("AVUUID:".$avUuid);                                     
            return;
        }//endelse*/
     }//function 
  
  function memberSort($a, $b){
        if ($a->numMembers == $b->numMembers) {
            return 0;
        }
        return ($a->numMembers < $b->numMembers) ? -1 : 1;
    }
    
     /*********************************************
     * Gets all the groups in the current course
     * @param string|mixed $data - string with this format: INDEX:0|GROUPSPERPAGE:10
     * 
     ********************************************/
      function getGrps(){
        global $sloodle;
        //sloodleid is the id of the activity in moodle we want to connect with
        $sloodleid = $sloodle->request->optional_param('sloodleid');
        //cmid is the module id of the sloodle activity we are connecting to
        
        $index =  $sloodle->request->required_param('index');   
        $groupsPerPage =$sloodle->request->required_param('maxitems');    
        //get all groups in the course
        $groups = groups_get_all_groups($sloodle->course->get_course_id());
        $sloodle->response->set_status_code(1);             //line 0 
        $sloodle->response->set_status_descriptor('OK'); //line 0 
        $dataLine="";
        $counter = 0;
        foreach($groups as $g){
             if (($counter>=($index*$groupsPerPage))&&($counter<($index*$groupsPerPage+$groupsPerPage))){
                if ($counter!=0) $dataLine.="|";
                $dataLine .= "GRP:".$g->name;
                $groupMembers =groups_get_members($g->id);
                $numMembers = count($groupMembers);                
                $dataLine .= ",MBRS:".$numMembers;                
             $counter++;
           }//(($counter>=($index*$groupsPerPage))&&($counter<($index*$groupsPerPage+$groupsPerPage)))
        }//foreach
        $sloodle->response->add_data_line("INDEX:". $index);   
        $sloodle->response->add_data_line("numGroups:".$counter);//line 
        $sloodle->response->add_data_line($dataLine);//line         
     }//function
      /*********************************************
     * addToRandomGrp If the user specified is not in any of the groups sent, 
     * this function will automatically add the user to one            of the groups specified which has the lowest number of members
     * @param string|mixed $avname - name of the avatar
     * @param string|mixed $avuuid - uuid of the avatar
     * @param string|mixed $groups- groups you want to choose from to add a member to
     * 
     ********************************************/
      function addToRandomGrp(){
        global $sloodle;
        //sloodleid is the id of the activity in moodle we want to connect with
        $sloodleid = $sloodle->request->optional_param('sloodleid');
        //cmid is the module id of the sloodle activity we are connecting to        
        $avname=  $sloodle->request->required_param('avname');   
        $uuid =$sloodle->request->required_param('avuuid');    
        
        //http://englishvillage.asia/sloodle/mod/sloodle/mod/hq-1.0/linker.php?&plugin=groups&function=addToRandomGrp&sloodlecontrollerid=2&sloodlepwd=299749874&sloodleserveraccesslevel=0&sloodleuuid=2102f5ab-6854-4ec3-aec5-6cd6233c31c6&sloodleavname=Fire%20Centaur&sourceuuid=&avuuid=&avname=&groups=Group%20C,%20%20%20Group%20A,%20%20%20Group%20D,%20%20%20Group%20B,%20%20%20Team%20A,%20%20%20Group%20E,%20%20%20Team%20B
        
        $user = new SloodleUser( $sloodle );
        if (!$user->load_avatar($uuid, null)) {
             $sloodle->response->set_status_code(-321);             //line 0 
             $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0
             return;
        }
        if (!$user->load_linked_user()) {
             $sloodle->response->set_status_code(-321);             //line 0 
             $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0
             return;
        }
        
        //get all groups in the course
        $groups = groups_get_all_groups($sloodle->course->get_course_id());
        $usersGroups = groups_get_all_groups($sloodle->course->get_course_id(),$user->get_user_id());
        $numUsersGrps=0;
      //  if ($usersGroups){
        //    foreach ($usersGroups as $ug){
        //        if (in_array($ug->name,$availGrps)) $numUsersGrps++;
        //    }
       // }
      if (empty($usersGroups)){
            //add to random group;
            $numGroups = count($groups);
            $allGrps = array();
            foreach ($groups as $g){
             
                    $newGrp = new stdClass();
                    $newGrp->numMembers = count(groups_get_members($g->id));
                    $newGrp->name = $g->name;
                    $newGrp->id = $g->id;
                    array_push($allGrps,$newGrp);
              
            }
            //sort with group with lowest member count first
            usort($allGrps,array("SloodleApiPluginGroups",  "memberSort"));
            $newGrp = new stdClass();
            if (count($allGrps)>0){
                //set new group for this member to be the group with the lowest member count
                $newGrp = $allGrps[0];    
          }
            if (groups_add_member($newGrp->id,$user->get_user_id())){
                $sloodle->response->set_status_code(1);             //line 0 
                $sloodle->response->set_status_descriptor('OK'); //line 0 
                $sloodle->response->add_data_line("AVUUID:". $uuid);   
                $sloodle->response->add_data_line("GRP:". $newGrp->name);   
                return;
            }else{
                $sloodle->response->set_status_code(-97000);             //Tried to add user to group, but MOODLE failed to add user to the group               
                $sloodle->response->set_status_descriptor('HQ'); //line 0 
                $sloodle->response->add_data_line("AVUUID:". $uuid);   
                $sloodle->response->add_data_line("GRP:". $newGrp->name);  
                return;
                
            }
            
      }
         $sloodle->response->set_status_code(1);             //line 0 
         $sloodle->response->set_status_descriptor('OK'); //line 0 
        $sloodle->response->add_data_line("AVUUID:". $uuid);   
        foreach ($usersGroups as $ug){
            $sloodle->response->add_data_line("GRP:". $ug->name);   
        }
     }//function
}//class
?>
