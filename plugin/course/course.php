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
//require_once(SLOODLE_LIBROOT.'/general.php');

class SloodleApiPluginCourse  extends SloodleApiPluginBase{
  /**********************************************************
     * getUsersGrps will retrieve a list of groups the user is a member of for this course
     * called by: 
     * llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "plugin:user,function:getUsersGroups\nSLOODLEID:null|USERNAME:"+avName+"|USERUUID:"+(string)avUuid, NULL_KEY);
     */
     var $course;
     var $sloodle_course;
     
     function checkAutoEnrolSettings(){
        global $sloodle;
        $course= get_record('course', 'id', $sloodle->course->get_course_id());
        if (sloodle_autoreg_enabled_site()==FALSE){
            $sloodle->response->set_status_code(-516);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
        if (sloodle_autoenrol_enabled_site()==FALSE){
            $sloodle->response->set_status_code(-515);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
        //load course
        $sloodleCourse = new SloodleCourse();
        if (!$sloodleCourse->load($course)) {
            $sloodle->response->set_status_code(-512);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
         $sloodle->response->set_status_code(1);         
         $sloodle->response->set_status_descriptor('OK'); //line 0  
         
         if (($sloodleCourse->check_autoenrol()==FALSE))$sloodle->response->add_data_line("autoenrol:FALSE");else
         if (($sloodleCourse->check_autoenrol()==TRUE))$sloodle->response->add_data_line("autoenrol:TRUE");else
         $sloodle->response->add_data_line("autoenrol:ERROR"); 
          
         if (($sloodleCourse->check_autoreg()==FALSE))$sloodle->response->add_data_line("autoreg:FALSE"); else
         if (($sloodleCourse->check_autoreg()==TRUE))$sloodle->response->add_data_line("autoreg:TRUE"); else
         $sloodle->response->add_data_line("autoreg:ERROR"); 
         


  }//function 
  function changeSettings(){
        global $sloodle;
        //$id = $sloodle->request->required_param('controllerid');
        
        
        $course= get_record('course', 'id', $sloodle->course->get_course_id());//) error('Could not find course.');
        $var = $sloodle->request->required_param('var');
        $setting = $sloodle->request->required_param('setting');
        $sloodleCourse = new SloodleCourse();
        if (sloodle_autoreg_enabled_site()==FALSE){
            $sloodle->response->set_status_code(-516);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
        if (sloodle_autoenrol_enabled_site()==FALSE){
            $sloodle->response->set_status_code(-515);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
        if (!$sloodleCourse->load($course)) {
            $sloodle->response->set_status_code(-512);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
        }
        
        
        switch ($var){
            case "autoenrol":
                if ($setting=="on"){
                    $sloodleCourse->enable_autoenrol();
                    $sloodleCourse->write();                                        
                }
                else
                if ($setting=="off"){
                    $sloodleCourse->disable_autoenrol();
                    $sloodleCourse->write();
                }
            break;
            case "autoreg":
                if ($setting=="on"){
                    $sloodleCourse->enable_autoreg();
                    $sloodleCourse->write();
                }
                else
                if ($setting=="off"){
                    $sloodleCourse->disable_autoreg();
                    $sloodleCourse->write();
                }
            break;
            default:
            $sloodle->response->set_status_code(-23);          //course note found
            $sloodle->response->set_status_descriptor('COURSE'); //line 0  
            return;
            break;
        }
         $sloodle->response->set_status_code(1);         
         $sloodle->response->set_status_descriptor('OK'); //line 0  
         if (($sloodleCourse->check_autoenrol()==FALSE))$sloodle->response->add_data_line("autoenrol:FALSE");else
         if (($sloodleCourse->check_autoenrol()==TRUE))$sloodle->response->add_data_line("autoenrol:TRUE");else
         $sloodle->response->add_data_line("autoenrol:ERROR"); 
          
         if (($sloodleCourse->check_autoreg()==FALSE))$sloodle->response->add_data_line("autoreg:FALSE"); else
         if (($sloodleCourse->check_autoreg()==TRUE))$sloodle->response->add_data_line("autoreg:TRUE"); else
         $sloodle->response->add_data_line("autoreg:ERROR"); 
         
  }//function 
}//class
?>
