
<?
/*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle/classroom/httpin_config_linker.php
*
*  Copyright:
*  @contributers Paul G. Preibisch (Fire Centaur in SL)
*  @contributers Edmund Edgar
*
*  The purpose of this file is to receive a message from a rezzer which is passing an httpinurl for a child object requesting its config.
*  this file will search for the child object in active_object table, save its httpin which was sent, and then pass it its config using curl 
* 
*/ 
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);

    /** Grab the Sloodle/Moodle configuration. */
    require_once('../sl_config.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    // Attempt to authenticate the request
    // (only require authentication if controller ID and/or password is set)
    $authrequired = (isset($_REQUEST['sloodlecontrollerid']) || isset($_REQUEST['sloodlepwd']));
    $sloodle = new SloodleSession();
    $request_auth = $sloodle->authenticate_request($authrequired);
    
    // Get the extra parameters
    $rezzeruuid = $sloodle->request->required_param('sloodleobjuuid');
    $httpinurl = $sloodle->request->required_param('httpinurl');    
    $childobjectuuid= $sloodle->request->required_param('childobjectuuid');
    $extraParams = array( 'sloodlerezzeruuid' => $rezzeruuid );   
    //search for active_object table
    //create new active object for found record
    $active_object= new SloodleActiveObject();
    //loadByUUid will search and find the active object
    $sloodle->response->add_data_line($childobjectuuid);

    if(!$active_object->loadByUUID( $childobjectuuid )){
            $active_object->response = new SloodleResponse();
            $active_object->response->set_status_code(-201);
            $active_object->response->set_status_descriptor('OBJECT_AUTH');
            $active_object->response->add_data_line('Failed to register new active object.');
            $renderStr="";
            //create message
            //send message to httpin
            $sloodle->response->set_status_code(-218);//child object not found
            $sloodle->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle->response->render_to_output();
    }//endif
    else{
         //save httpinurl
         $active_object->httpinurl=$httpinurl;
         if (!$active_object->save()) {                
            $sloodle->response->set_status_code(-217);//Could not save HTTP In URL for rezzed object
            $sloodle->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle->response->add_data_line('Could not save HTTP In URL for rezzed object'); 
         }
        //active object is loaded, send config to the object, and also send the rezzeruuid to the object so 
        //our object also knows its rezzer uuid 
        $result = $active_object->sendConfig($extraParams);
        //result is an array(curlinfo,curlresult)
        //lsl script returns an OK or FAIL
        if ($result["result"]=='OK'){          
                  $sloodle->response->set_status_code(1);
                $sloodle->response->set_status_descriptor('OK');//httpin config sent properly
          }else{
               $sloodle->response->set_status_code(-219);//Sending configuration to object via HTTP-in URL failed
               $sloodle->response->set_status_descriptor('OBJECT_AUTH');
               $sloodle->response->add_data_line('Sending configuration to object via HTTP-in URL failed'); 
          }
          $sloodle->response->render_to_output();
    }//end else

?>
