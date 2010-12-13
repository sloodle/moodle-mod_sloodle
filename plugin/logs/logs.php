<?php
/****************************************************************************************************
* Defines a plugin class for the SLOODLE logs -
* 
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributer Paul G. Preibisch - aka Fire Centaur 
* 
*****************************************************************************************************/
/** SLOODLE course object data structure */


class SloodleApiPluginLogs  extends SloodleApiPluginBase{
  /**********************************************************
     * getUsersGrps will retrieve a list of groups the user is a member of for this course
     * called by: 
     * llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "plugin:user,function:getUsersGroups\nSLOODLEID:null|USERNAME:"+avName+"|USERUUID:"+(string)avUuid, NULL_KEY);
     */
     function addLog(){
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
      
        $userAction=$sloodle->request->required_param('useraction'); 
        $slurl=$sloodle->request->optional_param('slurl'); 
        $avUuid=$sloodle->request->required_param('avuuid'); 
        $avName=$sloodle->request->required_param('avname'); 
        
        //build user
       $avUser = new SloodleUser( $sloodle );
        if ($avUser->load_avatar($avUuid,$avName)){
            if ($avUser->load_linked_user()){
                    $sloodle->response->set_status_code(1);          //@output status_code: 1 ok
                    $sloodle->response->set_status_descriptor('OK'); //line 0  
                    $sloodle->response->add_data_line("action:".$userAction);    
                    $sloodle->response->add_data_line("actionUrl:".$actionUrl);    
                    $sloodle->response->add_data_line("avname:".$avName);    
                    $sloodle->response->add_data_line("avuuid:".$avUuid);    
                    $newLog= new stdClass();
                    $newLog->course= (int)$sloodle->course->get_course_id();
                    $newLog->userid=$avUser->get_user_id();
                    $newLog->avuuid=$avUuid;
                    $newLog->avname=$avName;
                    $newLog->action=$userAction;
                    $newLog->slurl=$slurl;
                    $newLog->timemodified=time();  
                    $id=insert_record("sloodle_logs",$newLog);
          if (!$id){
             $sloodle->response->set_status_code(-600000);             //line 0   problem inserting record into table
             $sloodle->response->set_status_descriptor('HQ');  
             return;
          }//id
        }//load_linked_user
     }//load_avatar
  }//function 
}//class
?>
