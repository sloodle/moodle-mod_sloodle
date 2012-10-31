<?php
/*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle/classroom/httpin_url_update_linker.php
*
*  Copyright:
*  @contributers Paul G. Preibisch (Fire Centaur in SL)
*  @contributers Edmund Edgar
*
*  When an object's http-in url changes on a sim restart or crossing, it lets us know here.
* 
*/ 
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);

    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    require_once(SLOODLE_LIBROOT.'/general.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');

    // Attempt to authenticate the request
    // (only require authentication if controller ID and/or password is set)
    $sloodle = new SloodleSession();
    $request_auth = $sloodle->authenticate_request(true);
    
    $httpinurl = $sloodle->request->required_param('httpinurl');    
    $objuuid = $sloodle->request->required_param('sloodleobjuuid');

$ao = new SloodleActiveObject();
    if($ao->loadByUUID( $objuuid)) {
        $ao->httpinurl = $httpinurl;
        $ao->save();
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');//httpin config sent properly
    } else {
        $sloodle->response->set_status_code(-217);//Could not save HTTP In URL for rezzed object
        $sloodle->response->set_status_descriptor('OBJECT_AUTH');
        $sloodle->response->add_data_line('Could not save HTTP In URL for rezzed object'); 
    }

    $sloodle->response->render_to_output();

?>
