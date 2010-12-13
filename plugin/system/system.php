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


class SloodleApiPluginSystem extends SloodleApiPluginBase{

      
     
    
   
     /**********************************************************
     * @method getBalance will return the total sum of all point credits, point debits, and cash a user has in the      
     * entire MOODLE site
     * @author Paul Preibisch
     *         
     * @package sloodle
     */
     
     function replaceController(){
         global $CFG;
         global $sloodle;
         $oldpass=   $sloodle->request->required_param('oldpassword');  
         $oldsloodleid=$sloodle->request->required_param('oldsloodleid');  
         $newpass=   $sloodle->request->required_param('newpassword'); 
                    
         $oldcontroller=get_records('sloodle_controller');   
         var_dump($oldcontroller);
         
        
     }//function
}//class
?>
