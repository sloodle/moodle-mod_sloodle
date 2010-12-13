<?php
/**
* Defines a plugin class for the SLOODLE hq -
* 
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributer Paul G. Preibisch - aka Fire Centaur 
* 
*/


require_once(SLOODLE_LIBROOT.'/currency.php');    

class SloodleApiPluginBackpack extends SloodleApiPluginBase{

      
     
    
   
     /**********************************************************
     * @method getBalance will return the total sum of all point credits, point debits, and cash a user has in the      
     * entire MOODLE site
     * @author Paul Preibisch
     *         
     * @package sloodle
     */
     
     function getBalance(){
         global $CFG;
         global $sloodle;
         $avuuid=   $sloodle->request->required_param('avuuid');  
         $avname=   $sloodle->request->required_param('avname'); 
         $currency=   $sloodle->request->required_param('currency'); 
         $gameid=   $sloodle->request->optional_param('gameid'); 
         //build sloodle user
         $avUser = new SloodleUser( $sloodle );
         $sloodle->validate_user();
         $courseid = $sloodle->course->get_course_id();
         $avUser->load_avatar($avuuid,$avname);
         $avUser->load_linked_user();
         $userid = $avUser->avatar_data->userid;
         if (empty($userid)){
           $sloodle->response->set_status_code(-321);             //line 0 - User did not have permission to access the resources requested
           $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0  
           $sloodle->response->add_data_line("AVUUID:". $avuuid);    
           return; 
        }   
         $cObject = new SloodleCurrency();
         $balance = $cObject->get_balance($currency,$userid,$avuuid,$gameid);
        $sloodle->response->set_status_code(1);             //line 0 
        $sloodle->response->set_status_descriptor('OK'); //line 0 
        $sloodle->response->add_data_line("AVUUID:". $avuuid);    
        $sloodle->response->add_data_line("CURRENCY:". $currency);    
        $sloodle->response->add_data_line("BALANCE:". $balance["amount"]);    
        $sloodle->response->add_data_line("COURSEID:". $courseid);    
     }//function
     function getAllBalances(){
         global $CFG;
         global $sloodle;
         $avuuid=   $sloodle->request->required_param('avuuid');  
         $avname=   $sloodle->request->required_param('avname');          
         $gameid=   $sloodle->request->optional_param('gameid'); 
         //build sloodle user
         $avUser = new SloodleUser( $sloodle );
         $sloodle->validate_user();
         $courseid = $sloodle->course->get_course_id();
         $avUser->load_avatar($avuuid,$avname);
         $avUser->load_linked_user();
         $userid = $avUser->avatar_data->userid;
         if (empty($userid)){
           $sloodle->response->set_status_code(-321);             //line 0 - User did not have permission to access the resources requested
           $sloodle->response->set_status_descriptor('USER_AUTH'); //line 0  
           $sloodle->response->add_data_line("AVUUID:". $avuuid);    
           return; 
        }   
        $currencies = get_records('sloodle_currency_types');
        if ($currencies){
           $sloodle->response->set_status_code(1);             //line 0 
           $sloodle->response->set_status_descriptor('OK'); //line 0 
           $sloodle->response->add_data_line("AVUUID:". $avuuid);    
           $sloodle->response->add_data_line("COURSEID:". $courseid);    
           $sloodle->response->add_data_line("GAMEID:". $gameid);    
           $cObject = new SloodleCurrency();                                     
            foreach ($currencies as $c){
                
                $balance = $cObject->get_balance($c->name,$userid,$avuuid,$gameid);
                if ($balance["amount"]=="")$b=0; else $b=$balance["amount"];
                $sloodle->response->add_data_line($c->name."|".$b);         
            }            
        }         
        
     }//function
}//class
?>
