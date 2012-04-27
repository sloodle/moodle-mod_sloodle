<?php
    /**
    * Sloodle object authorization linker.
    * Allows authorised objects in SL to delegate authorisation to other objects,
    *  or allows new objects in SL to initiate their own authorisation.
    * (Creates a new entry in the 'sloodle_active_object' DB table.)
    *
    * @package sloodleclassroom
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    *
    */
    
    // If fully authorising a new object ('delegating' trust),
    //  then the following parameters are required:
    //
    //  sloodlecontrollerid = the ID of the controller through which the current object may access Sloodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate access
    //  sloodleobjuuid = the UUID of the object being authorised
    //  sloodleobjname = the name of the object being authorised
    //  sloodleobjpwd = a password for the new object
    //  sloodlehttpinurl = an http-in url we can use to talk to the new object
    //
    // The following parameters are optional:
    //
    //  sloodleobjtype = the type identifier for the object being authorised. Can be overridden later.
    //
    // With the above information, a new entry is made, indicating that the object is fully authorised.
    // The new object can ONLY be authorised against the controller the request is received on.
    // If successful, the status code returned is 1, and the data line will contain the authorisation ID of the object which has been authorised.
    
    // If an object needs the user to perform web-authorisation, then it can create an unauthorised entry.
    // To do this, the following parameters are required:
    //
    //  sloodleobjuuid = the UUID of the object being authorised
    //  sloodleobjname = the name of the object being authorised
    //  sloodleobjpwd = a new password for the object (NOT including its UUID)
    //
    // The following parameter is optional:
    //
    //  sloodleobjtype = the type identifier for the object. Can be overridden later.
    //
    // With this information, a new entry is made which is not linked to a particular user account.
    // As such, the entry is deemed 'unauthorised' and cannot be used until authorised.
    // If successful, status code 1 is returned, and the ID of the active object entry is returned on the data line.
    // The object should use this to build a URL to send the user to Sloodle for manual object authorisation.
    // Unauthorised entries will expire within 5 minutes and be deleted.
    
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Attempt to authenticate the request
    // (only require authentication if controller ID and/or password is set)
    $authrequired = (isset($_REQUEST['sloodlecontrollerid']) || isset($_REQUEST['sloodlepwd']));
    $sloodle = new SloodleSession();
    $request_auth = $sloodle->authenticate_request($authrequired);
    
    // Get the extra parameters
    $sloodleobjuuid = $sloodle->request->required_param('sloodleobjuuid');
    $sloodleobjname = $sloodle->request->required_param('sloodleobjname');
    $sloodleobjpwd = $sloodle->request->required_param('sloodleobjpwd');
    $sloodleobjtype = $sloodle->request->optional_param('sloodleobjtype', '');
    $sloodlecloneconfig = $sloodle->request->optional_param('sloodlecloneconfig', ''); // uuid of an object whose config we want to clone. combined with a layout id of 0. used for rezzing a mothership from a set
    $sloodlehttpinurl = $sloodle->request->optional_param('sloodlehttpinurl','');

    // When the set rezzes an item from a layout, it can pass this parameter saying what layout entry the object represented.
    // We'll use that to auto-configure the object based on the layout entry configurations.
    $sloodlelayoutentryid = $sloodle->request->optional_param('sloodlelayoutentryid',-1,PARAM_INT);
    
    // If the request was authenticated, then the object is being fully authorised.
    // Otherwise, it is simply a 'pending' authorisation.
    if ($request_auth) {
        // If the request is coming from an authorised object, then use that user as the authoriser for this one
        $sloodlepwd = $sloodle->request->required_param('sloodlepwd');
        $pwdparts = explode('|', $sloodlepwd, 2);
        if (count($pwdparts) >= 2 && strlen($pwdparts[0]) == 36) { // Do we have a UUID?
            $userid = $sloodle->course->controller->get_authorizing_user($pwdparts[0]);
            if ($userid) $sloodle->user->load_user($userid);
        }

	    $httpinpassword = sloodle_random_prim_password();
        
        // Authorise the object on the controller
        $authid = $sloodle->course->controller->register_object($sloodleobjuuid, $sloodleobjname, $sloodle->user, $sloodleobjpwd, $httpinpassword, $sloodleobjtype);
        $alreadyconfigured = "0";
        if ($sloodlelayoutentryid > 0) {
            if ($sloodle->course->controller->configure_object_from_layout_entry($authid, $sloodlelayoutentryid)) {
                // This flag will tell the rezzer to tell the object that it's already configured
                // That way the object will know not to tell the user to configure it.
                $alreadyconfigured = "1";
            }
        } else if ( ($sloodlelayoutentryid == 0) && ($sloodlecloneconfig != '') ) { // use 0 to mean we want to configure based on the parent who authorized us, rather than on a layout. Doing this to make the mothership worked when rezzed by a Sloodle Set, but we may want to do the same kind of thing with Registration Booths etc.
            if ($result = $sloodle->course->controller->configure_object_from_parent($authid, $sloodlecloneconfig)) {
                // This flag will tell the rezzer to tell the object that it's already configured
                // That way the object will know not to tell the user to configure it.
$alreadyconfigured = $result;
                $alreadyconfigured = "1";
            } else {
                $alreadyconfigured = "0";
            }

	}
        if ($authid) {
            $sloodle->response->set_status_code(1);
            $sloodle->response->set_status_descriptor('OK');
            $sloodle->response->add_data_line($authid);
            $sloodle->response->add_data_line($alreadyconfigured);
        } else {
            $sloodle->response->set_status_code(-201);
            $sloodle->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle->response->add_data_line('Failed to register new active object.');
        }
    } else {
        // Create a new unauthorised entry
	    $httpinpassword = sloodle_random_prim_password();
        $authid = $sloodle->course->controller->register_unauth_object($sloodleobjuuid, $sloodleobjname, $sloodleobjpwd, $sloodleobjtype, null, $sloodlehttpinurl, $httpinpassword);
        if ($authid != 0) {
            $sloodle->response->set_status_code(1);
            $sloodle->response->set_status_descriptor('OK');
            $sloodle->response->add_data_line($authid);
            $sloodle->response->add_data_line($alreadyconfigured="0");
        } else {
            $sloodle->response->set_status_code(-201);
            $sloodle->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle->response->add_data_line('Failed to register new active object.');
        }
    }
    
    // Render the output
    sloodle_debug('<pre>');
    $sloodle->response->render_to_output();
    sloodle_debug('</pre>');

?>
