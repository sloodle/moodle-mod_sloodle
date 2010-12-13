<?php
/**
* Defines a plugin class for the SLOODLE hq -
* Will include functions to return lesson data into Second Life / Opensim
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* 
* @contributer Paul G. Preibisch - aka Fire Centaur 
* 
*/
class SloodleApiPluginLessons  extends SloodleApiPluginBase{

    
     /*********************************************************************************
     *   getLessons will return the lessons in this course that the _sloodle_api is connected to
     * 
     *   @parameters:  index - the index of the lessons you want to return
     *   @parameters:  lessonsPerPage - the number of lessons you want to return into sl
     *      
     *   API CALL in SL:
     *   string apiCall = "plugin:lessons,function:getLessons\nSLOODLEID:null\nindex:0|lessonsPerPage:9";
     *   llMessageLinked(LINK_SET, PLUGIN_CHANNEL, apiCall,  NULL_KEY);
     **********************************************************************************/
     function getQuizes($data){
        global $sloodle;
        //sloodleid is the id of the activity in moodle we want to connect with
        $sloodleid = $sloodle->request->optional_param('sloodleid');
        //cmid is the module id of the sloodle activity we are connecting to
        $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
        $cmid = $cm->id;
        $courseid = $sloodle->course->get_course_id();
        $data=$sloodle->request->optional_param('data'); 
        $bits = explode("|", $data);
        $index = getFieldData($bits[0]);
        
        $itemsPerPage = getFieldData($bits[1]);
        //get all lessons in the course
        $quizes= get_records('quiz','course',$courseid);
        if ($quizes){
            $sloodle->response->set_status_code(1);             //line 0 
            $sloodle->response->set_status_descriptor('OK'); //line 0 
            $dataLine="";
            $counter = 0;
            $sloodle->response->add_data_line("INDEX:".$index);
            $sloodle->response->add_data_line("#QUIZES:".count($quizes));
            //Return a list of column names from the database to SL that we are returning values for
            $dbColumns = "COLUMNS:ID|NAME|TIMEOPEN|TIMECLOSE|ATTEMPTS|ATTEMPTONLAST|SHUFFLEQ|";
            $dbColumns .="SHUFFLEA|QUESTIONS";
            $sloodle->response->add_data_line($dbColumns);
            //list the db columns returned
            foreach($quizes as $quiz){
            //only return the lessons in the index that was requested. This is useful because an http response is limited
            //in how many characters you can send back into SL. 
             if (($counter>=($index*$itemsPerPage))&&($counter<($index*$itemsPerPage+$itemsPerPage))){                
                 //Get all the pages of this lessone from mdl_lesson_pages table and return the number of pages
                $questions = get_records('quiz','course',$courseid);                
                if ($pages){
                    $numPages = count($lessons);                
                }//endif
                else{
                    $numPages = 0;
                }//end else
                id = :id,
  course = :course,
  name = :name,
  intro = :intro,
  timeopen = :timeopen,
  timeclose = :timeclose,
  optionflags = :optionflags,
  penaltyscheme = :penaltyscheme,
  attempts = :attempts,
  attemptonlast = :attemptonlast,
  grademethod = :grademethod,
  decimalpoints = :decimalpoints,
  review = :review,
  questionsperpage = :questionsperpage,
  shufflequestions = :shufflequestions,
  shuffleanswers = :shuffleanswers,
  questions = :questions,
  sumgrades = :sumgrades,
  grade = :grade,
  timecreated = :timecreated,
  timemodified = :timemodified,
  timelimit = :timelimit,
  password = :password,
  subnet = :subnet,
  popup = :popup,
  delay1 = :delay1,
  delay2 = :delay2
                /****************************************
                * Add data to the output
                *****************************************/          
                //add lesson id
                $dataLine = $les->id;      
                //add lesson name
                $dataLine .= "|".$les->name;                
                //add number of pages
                $dataLine .= "|".$numPages;                
                //add practice var
                $dataLine .= "|". $les->practice;
                //add modattempts
                $dataLine .= "|".$les->modattempts;
                //ongoing
                $dataLine .= "|".$les->ongoing;
                //usemaxgrade
                $dataLine .= "|".$les->usemaxgrade;
                //maxanswers
                $dataLine .= "|".$les->maxanswers;
                //maxanswers
                $dataLine .= "|".$les->maxattempts;
                //nextpagedefault
                $dataLine .= "|".$les->nextpagedefault;
                //minquestions
                $dataLine .= "|".$les->minquestions;
                //maxpages
                $dataLine .= "|".$les->maxpages;
                //timed 
                $dataLine .= "|".$les->timed;
                //maxtime 
                $dataLine .= "|".$les->maxtime;
                //retake 
                $dataLine .= "|".$les->retake;
                //highscores 
                $dataLine .= "|".$les->highscores;
                //maxhighscores
                $dataLine .= "|".$les->maxhighscores;
                //available
                $dataLine .= "|".$les->available;
                //deadline
                $dataLine .= "|".$les->deadline;
                $sloodle->response->add_data_line($dataLine);
             $counter++;
           }//(($counter>=($index*$groupsPerPage))&&($counter<($index*$groupsPerPage+$groupsPerPage)))
        }//foreach
     }// if ($lessons)
     else{
         $sloodle->response->set_status_code(-9872);             //no lessons in the course
         $sloodle->response->set_status_descriptor('API:LESSONS'); 
     }//end else
  }//end function
  
     /*********************************************************************************
     *   getLessonPages will return the lessons pages for the lesson specified
     * 
     *   @parameters:  index - the index of the lessons you want to return
     *   @parameters:  lessonPagesPerPage - the number of lesson Pages you want to return into sl
     *      
     *   API CALL in SL:
     *   string apiCall = "plugin:lessons,function:getLessonPages\nSLOODLEID:null\nindex:0|lessonPagesPerPage:9|lessonid:1";
     *   llMessageLinked(LINK_SET, PLUGIN_CHANNEL, apiCall,  NULL_KEY);
     **********************************************************************************/
    function getLessonPages($data){
        global $sloodle;
        //sloodleid is the id of the activity in moodle we want to connect with
        $sloodleid = $sloodle->request->optional_param('sloodleid');
        //cmid is the module id of the sloodle activity we are connecting to
        $cm = get_coursemodule_from_instance('sloodle',$sloodleid);
        $cmid = $cm->id;
        $courseid = $sloodle->course->get_course_id();
        $data=$sloodle->request->optional_param('data'); 
        $bits = explode("|", $data);
        /****************************
        * parse the data parameters passed into SL
        *****************************/
        $index = getFieldData($bits[0]);        
        $lessonPagesPerPage = getFieldData($bits[1]);
        $lessonId = getFieldData($bits[2]);
        /****************************
        * get all lesson pages in the course for this lesson
        ******************************/
        $lessonPages = get_records('lesson_pages','lessonid',(int)$lessonId);
        if ($lessonPages){
            $sloodle->response->set_status_code(1);             //line 0 
            $sloodle->response->set_status_descriptor('OK'); //line 0 
            $dataLine="";
            $counter = 0;
            $sloodle->response->add_data_line("INDEX:".$index);
            $sloodle->response->add_data_line("#LESSONPAGES:".count($lessonPages));
            //Return a list of column names from the database to SL that we are returning values for
            $dbColumns = "COLUMNS:ID|PREVPAGEID|NEXTPAGEID|QTYPE|QOPTION|TITLE|CONTENTS";
            $sloodle->response->add_data_line($dbColumns);
            //list the db columns returned
            foreach($lessonPages as $les_page){
            //only return the lessons in the index that was requested. This is useful because an http response is limited
            //in how many characters you can send back into SL. 
             if (($counter>=($index*$lessonPagesPerPage))&&($counter<($index*$lessonPagesPerPage+$lessonPagesPerPage))){                
                /****************************************
                * Add data to the output
                *****************************************/
                //add page id
                $dataLine = $les_page->id;                     
                //add prevpageid
                $dataLine .= "|".$les_page->prevpageid;                
                //add nextpageid
                $dataLine .= "|".$les_page->nextpageid;                
                //add qtype
                $dataLine .= "|". $les_page->qtype;
                //add qoption
                $dataLine .= "|".$les_page->qoption;
                //add title
                $dataLine .= "|".$les_page->title;
                //contents
                $dataLine .= "|".$les_page->contents;
                $sloodle->response->add_data_line($dataLine);
             $counter++;
           }//(($counter>=($index*$groupsPerPage))&&($counter<($index*$groupsPerPage+$groupsPerPage)))
        }//foreach
     }// if ($lessons)
     else{
         $sloodle->response->set_status_code(-9873);             //no pages for this lesson in the course
         $sloodle->response->set_status_descriptor('API:LESSONS'); 
     }//end else
  }//end function
}//end class
?>
