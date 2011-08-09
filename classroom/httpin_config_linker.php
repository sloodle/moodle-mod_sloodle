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
    require_once(SLOODLE_LIBROOT.'/general.php');

    // Attempt to authenticate the request
    // (only require authentication if controller ID and/or password is set)
    $authrequired = (isset($_REQUEST['sloodlecontrollerid']) || isset($_REQUEST['sloodlepwd']));
    $sloodle = new SloodleSession();
    $request_auth = $sloodle->authenticate_request($authrequired);
    
    // Get the extra parameters
    $rezzeruuid = $sloodle->request->required_param('sloodleobjuuid');
    $httpinurl = $sloodle->request->required_param('httpinurl');    
    $childobjectuuid= $sloodle->request->required_param('childobjectuuid');
    $controllerid = $sloodle->request->required_param('sloodlecontrollerid');
    $objectname = $sloodle->request->optional_param('sloodleobjname');
    $extraParams = ($rezzeruuid == $childobjectuuid) ? array() : array( 'sloodlerezzeruuid' => $rezzeruuid );   

    if ($childobjectuuid == $rezzeruuid) {

	// configs come from a notecard
	$configs = array();
	$configs['sloodlecontrollerid'] = $controllerid;
	foreach($_POST as $n=>$v) {
		if (preg_match('/^set\:(.*)$/', $n, $matches) ) {
			$configs[ $matches[1] ] = $v;
		}
	}
	$objecttype = isset($configs['sloodleobjtype']) ? $configs['sloodleobjtype'] : 'unknown';

        // This is an object trying to register itself with a notecard.
        // Go ahead an do it - it has a legitimate prim password or it would have been stopped already.
        $controller = new SloodleController();
        if (!$controller->load( $controllerid )) {
            $sloodle->response->set_status_code(-217);//Could not save HTTP In URL for rezzed object
            $sloodle->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle->response->add_data_line('Could not save HTTP In URL for rezzed object'); 
        }

	// TODO: Refactor and move this stuff into activeobject

	// first time we way it
	$ao = new SloodleActiveObject();
	if(!$ao->loadByUUID( $childobjectuuid )) {
		$primpassword = sloodle_random_web_password();
		$httpinpassword = sloodle_random_prim_password();
		if ( !$authid = $controller->register_object($childobjectuuid, $objectname, $sloodle->user, $primpassword, $httpinpassword, $objecttype) ) {
		    $sloodle->response->set_status_code(-217);//Could not save HTTP In URL for rezzed object
		    $sloodle->response->set_status_descriptor('OBJECT_AUTH');
		    $sloodle->response->add_data_line('Could not save HTTP In URL for rezzed object'); 
		}
	} else {
		$authid = $ao->id;
		// already got it - clean out old configs
		sloodle_delete_records('sloodle_object_config', 'object', $authid); 
	}

	if (count($configs) > 0) {
		foreach($configs as $n => $v) {
			$config->id = null;
			$config->object = $authid;
			$config->name = $n;
			$config->value = $v;
			if (!sloodle_insert_record('sloodle_object_config',$config)) {
				$ok = false;
			}
		}
	}

    }

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

    } else{

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
