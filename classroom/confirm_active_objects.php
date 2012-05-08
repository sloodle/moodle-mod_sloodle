<?php
    /**
    * Sloodle active object confirm.
    * Allows the rezzer to check for any objects that are no longer there, because they have been manually derezzed.
    * With sloodlecmd=requestconfirmable, expects a list of uuids of objects that haven't checked in recently.
    * With sloodlecmd=reportdisappeared, supplies a list of uuids of objects that have been found to be absent.
    * If an object is found to be absent, its rezzer uuid will be removed.
    * The object is left in the active object table in case it has been taken into inventory rather than deleted.
    *
    * @package sloodleclassroom
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    *
    */
    
    // The following parameters are required:
    //
    //  sloodlecontrollerid = the ID of the controller through which the current object may access Sloodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate access
    //  sloodleobjuuid = the UUID of the object which is active
    //  sloodlecmd = the task - either requestconfirmable or reportdisappeared
    //
    // If the check is successful, the status code will be 1.
    // If the object was not found, status code -103 is returned.
    //
    //
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    $task = required_param('sloodlecmd', PARAM_TEXT);
    
    // Authenticate the request
    $sloodle = new SloodleSession();

    // The access record happens when we authenticate.
    // If it fails, it should error out and exit.
    $sloodle->authenticate_request();

    $rezzer = $sloodle->active_object;

    if ($task == 'requestconfirmable') {

        $uuids = $rezzer->uuids_of_children_missing_since( 0, time() + 900 );
        
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        $sloodle->response->set_refresh_seconds(SLOODLE_REZZER_STATUS_CONFIRM_INTERVAL);
           

        if (count($uuids) > 0) {
            foreach($uuids as $uuid) {
                $sloodle->response->add_data_line(array($uuid));
            }
        }

    } else {

       $uuidstr = required_param('sloodlemissinguuids', PARAM_TEXT);
       if ($uuidstr != '') {
           $uuids = explode('|', $uuidstr);
           if (count($uuids) > 0) {
               foreach($uuids as $uuid) {
                   if ($uuid == '') {
                       continue;
                   }
                   $ao = new SloodleActiveObject();
                   if ( $ao->loadByUUID( $uuid ) ) {
                       if ($ao->rezzeruuid == $rezzer->uuid) {
                           $ao->rezzeruuid = '';
                           $ao->save();
                       }
                   }
               }
           }

       }

        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');

    }
    
    // Output the response
    $sloodle->response->render_to_output();

?>
