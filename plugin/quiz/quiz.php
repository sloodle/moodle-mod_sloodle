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

class SloodleApiPluginQuiz  extends SloodleApiPluginBase{

        
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
     function getQuizzes(){
        global $sloodle;
        //sloodleid is the id of the activity in moodle we want to connect with
        $sloodleid = $sloodle->request->optional_param('sloodleid');    
        //cmid is the module id of the sloodle activity we are connecting to
        
        $index =  $sloodle->request->required_param('index');   
        $itemsPerPage=$sloodle->request->required_param('maxitems');    
        //get all groups in the course
        $quizzes= get_records('quiz','course',$sloodle->course->get_course_id(),'name DESC');
        $sloodle->response->set_status_code(1);             //line 0 
        $sloodle->response->set_status_descriptor('OK'); //line 0 
        $dataLine="";
        $counter = 0;
        $sloodle->response->add_data_line("INDEX:". $index);   
        $sloodle->response->add_data_line("numItems:".count($quizzes));//line 
        foreach($quizzes as $q){
             if (($counter>=($index*$itemsPerPage))&&($counter<($index*$itemsPerPage+$itemsPerPage))){
                 $course_module_id = get_record('course_modules','course',$sloodle->course->get_course_id(),'module',13,'instance',$q->id);
                $sloodle->response->add_data_line("name:".$q->name."|id:".$course_module_id->id);//line 
           }//(($counter>=($index*$groupsPerPage))&&($counter<($index*$groupsPerPage+$groupsPerPage)))
        }//foreach
     }//function    
     
       function newQuizGame(){        
         global $sloodle;
        
         //sloodleid is the id of the record in mdl_sloodle of this sloodle activity
         $sloodleid = $sloodle->request->optional_param('sloodleid');
         $quizId= $sloodle->request->optional_param('quizid');
         $quizName= $sloodle->request->optional_param('quizname');
         //coursemoduleid is the id of course module in sdl_course_modules which refrences a sloodle activity as its instance.
         //when a notecard is generated from a sloodle awards activity, the course module id is given instead of the id in the sloodle table
         //There may be some instances, where the course module is sent instead of the instance. We account for that here.
         $coursemoduleid= $sloodle->request->optional_param('sloodlemoduleid');    
         //if the sloodlemoduleid is not specified, get the course module from the sloodle instance
         if (!$coursemoduleid){
            //cmid is the module id of the sloodle activity we are connecting to
             if ($sloodleid) {
              $cm = get_coursemodule_from_instance('sloodle',$sloodleid);                 
              $cmid = $cm->id;                                            
             }
             else {
                 //&sloodlemoduleid or &sloodleid must be defined and included in the url 
                 //request so we can connect to an awards activity to complete this transaction
                 $sloodle->response->set_status_code(-500900); 
                 $sloodle->response->set_status_descriptor('HQ'); 
             }
         }       else $cmid= $coursemoduleid;
       
         //create sCourseObj, and awardsObj
         $sCourseObj = new sloodleCourseObj($cmid);  
         $awardsObj = new Awards((int)$cmid);
         //get the controller id
         $quizzes= get_records('quiz','course',$sloodle->course->get_course_id(),'name DESC');
         if (!empty($quizId)){
             $qId=$quizId;
             $qname=$quizName;
         }else{
             foreach ($quizzes as $q){
                $qId= $q->id;
                $qname = $q->name;
             }
         }
         $course_module_id = get_record('course_modules','course',$sloodle->course->get_course_id(),'module',13,'instance',$qId);
         $newgame= new stdClass();
          $newgame->sloodleid= (int)$sCourseObj->getSloodleId();
          $newgame->name="New Game";
          $newgame->timemodified=time();  
                $id=insert_record("sloodle_award_games",$newgame);
          if (!$id){
             $sloodle->response->set_status_code(-600000);             //line 0   problem inserting record into games table
             $sloodle->response->set_status_descriptor('HQ');  
             return;
          }
        $sloodle->response->set_status_code(1);             //line 0    1
        $sloodle->response->set_status_descriptor('OK'); 
        //line2: uuid who made the transaction        
        //add command
        //TODO: change to xml output?
        $sloodle->response->add_data_line("GAMEID:".$id);
        $sloodle->response->add_data_line("name:".$qname);
        $sloodle->response->add_data_line("id:".$course_module_id->id);//line        
    }  
   
}//class
?>
