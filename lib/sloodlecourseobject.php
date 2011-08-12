<?php
/**
* sloodlecourseobject provides basic functionality for accessing information about
* the students, including a student list, and avatar list
*
* 
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @see http://slisweb.sjsu.edu/sl/index.php/Sloodle_Stipend_Giver
* @see award
*
* @contributer Paul Preibisch - aka Fire Centaur 
*/

 /** SLOODLE course data structure */
global $CFG;   
require_once(SLOODLE_DIRROOT.'/view/base/base_view_module.php');   


  class sloodleCourseObj{
      
      
      var $cm;
      
      var $courseRec;
      
      var $courseId;
      /**
      * URL for accessing the current course.
      * @var string
      * @access private
      */
      var $courseUrl = '';
      
      /**
      * Full name of the current course.
      * @var string
       * @access private
      */
      var $courseFullName = '';
  
      /**
      * Short name of the current course.
      * @var string
      * @access private
      */
      var $courseShortName = '';
      
      var $courseContext=null;
      
      var $sloodleCourseObject;
      
      var $sloodleRec;
      
      var $sloodleId;
      
      var $userList;
      
      var $avatarList;
   

           
      //constructor
      function sloodleCourseObj($id){
          
          if(!$this->cm = get_coursemodule_from_id('sloodle',$id)) error ('Course module ID was incorrect.');
          //coursemodule id
          
         $this->courseContext = get_context_instance(CONTEXT_MODULE, $this->cm->id);
         
          // Course object
          if (!$this->courseRec = sloodle_get_record('course', 'id', $this->cm->course)) error('Failed to retrieve course.');            
          
          //set course object
          $this->courseId = $this->cm->course;

          $this->courseFullName = $this->courseRec->fullname;
          $this->courseShortName = $this->courseRec->shortname;
          
         //set sloodle course object          
          $this->sloodleCourseObject = new SloodleCourse();
          
          $this->userList = $this->getUserList();
          $this->avatarList = $this->getAvatarList($this->userList);
          
        if (!$this->sloodleCourseObject->load($this->courseRec)) error(get_string('failedcourseload', 'sloodle'));
        //set course context
          $this->courseContext =get_context_instance_by_id((int)$this->cm->instance);
            //  sloodle_get_records('context','instanceid',(int)$this->cm->instance);
          
        // Fetch the SLOODLE instance itself
        if (!$this->sloodleRec = sloodle_get_record('sloodle', 'id', $this->cm->instance)) error('Failed to find SLOODLE module instance');
            
        //set sloodleId  (id of module instance)          
        $this->sloodleId= $this->cm->instance;  

      
      
      }     
      
      function get_avatars($userid){
         return  sloodle_get_records('sloodle_users', 'userid', $userid);   
          
      } 
      function get_avatar($userid){
         $recs = sloodle_get_records('sloodle_users', 'userid', $userid);            
         return $recs;
      }
      //returns a list of avatars in the class
      function getAvatarList($userList){
         $avList = array();
         if ($userList){
         foreach ($userList as $u){             
             $sloodledata = sloodle_get_records('sloodle_users', 'userid', $u->id);   
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
      function getSloodleId(){
        return $this->sloodleId;
      }  
      function is_teacher($userid){
           $context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
          
          if (has_capability('moodle/course:manageactivities',$context, $userid)) { 
              return true;
          }
          else return false;
          
          
      }
      
      function getUserList(){
            global $CFG;  
            
           //get all the users from the users table in the moodle database that are members in this class   
           $sql = "select u.*, ra.roleid from ".$CFG->prefix."role_assignments ra, ".$CFG->prefix."context con, ".$CFG->prefix."course c, ".$CFG->prefix."user u ";
           $sql .= " where ra.userid=u.id and ra.contextid=con.id and con.instanceid=c.id and c.id=?";
           
           
           $fullUserList = sloodle_get_records_sql_params($sql, array($this->cm->course));          
           return $fullUserList;                          
      }
  
   
     /**
     * setUserList set's the private userList array
     * @param $this->userList
     * @return null
     */   
     
     function setUserList($list){
        $this->userList = $list;
     }
     
     function get_moodleUserProfile($u){
         global $CFG;
        // Construct URLs to this user's Moodle and SLOODLE profile pages
        $url_moodleprofile = $CFG->wwwroot."/user/view.php?id={$u->id}&amp;course={$this->courseId}";
        return $url_moodleprofile;
     }
     
     function get_sloodleprofile($u){
         global $CFG;
        $url_sloodleprofile = SLOODLE_WWWROOT."/view.php?_type=user&amp;id={$u->id}&amp;course={$this->courseId}";        
        return $url_sloodleprofile;
     }

     // There used to be a function here called get_user_by_uuid. 
     // It looked obviously broken, and wasn't being used anywhere
     // function get_user_by_uuid($avuuid)
  }
        
?>
