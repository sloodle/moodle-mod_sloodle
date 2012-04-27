<?php
    /**
    * Sloodle PrimDrop linker (for Sloodle 0.3).
    * Allows a Sloodle PrimDrop object to interact with a 'Sloodle Object' assignment type.
    *
    * @package sloodleprimdrop
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Jeremy Kemp
    * @contributor Peter R. Bloomfield
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = cmID of an assignment
    //
    // If accessed with only the above paramters, then the script will return information about the assignment.
    // Status code will be 1, and the first data line will contain the name of the assignment.
    // The second data line will contain the description of the assignment.
    //
    // To check whether or not a user can submit an assignment, the following details should also be provided:
    //  sloodleuuid = UUID of the avatar who created the submission
    //  sloodleavname = name of the avatar who created the submission
    //
    // The status code returned will be as follows (no data):
    //  1 = OK
    //  -10201 = User is not authorised to submit assignments
    //  -10202 = Assignment is not yet open for submissions
    //  -10203 = Assignment due date has passed, and is closed for submissions
    //  -10204 = Assignment due date has passed, but is still accepting submissions
    //  -10205 = User has already submitted, and resubmissions are not being accepted
    //
    // To report a submission, the following parameters (in addition to all above) should be provided:
    //  sloodleobjname = Name of the object being submitted
    //  sloodleprimcount = Number of prims in the object being submitted
    //  sloodleprimdropname = Name of the PrimDrop object being submitted to
    //  sloodleprimdropuuid = UUID of the PrimDrop object being submitted to
    //  sloodleregion = region in which the PrimDrop is located
    //  sloodlepos = position of the PrimDrop (vector <x,y,z>)
    //
    // If the submission was successful, the status code will be 1.
    // Otherwise, the codes above may be returned (although -10204 will only appear as a side effect).
    // Status code -103 will appear if some assignment submission to the database fails.
    //

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, load the Sloodle Object assignment module, and validate the user
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->load_module('sloodleobject', true);
    
    // Has user data been omitted?
    $uuid = $sloodle->request->get_avatar_uuid(false);
    $avname = $sloodle->request->get_avatar_name(false);
    if ($uuid == null && $avname == null) {
        // Just query the assignment details
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        $sloodle->response->add_data_line($sloodle->module->get_name());
        $sloodle->response->add_data_line(strip_tags($sloodle->module->get_intro()));
        $sloodle->response->render_to_output();
        exit();
    }
    
    // Some user data has been provided, so make sure we can validate the user
    $sloodle->validate_user();
    
    // Check the requirements for allowing submissions
    $status = 1; // This means it's OK
    if (!$sloodle->module->user_can_submit($sloodle->user)) $status = -10201;
    else if ($sloodle->module->user_has_submitted($sloodle->user) == true && $sloodle->module->resubmit_allowed() == false) $status = -10205;
    else if ($sloodle->module->is_too_early()) $status = -10202;
    else {
        $late = $sloodle->module->is_too_late();
        if ($late > 0) $status = -10203;
        else if ($late < 0) $sloodle->response->add_side_effect(-10204); // Still OK... just late! :-)
    }
    
    // If the status was bad, then report it
    if ($status < 1) {
        $sloodle->response->set_status_code($status);
        $sloodle->response->set_status_descriptor('ASSIGNMENT');
        $sloodle->response->render_to_output();
        exit();
    }
    
    // Has an object name been provided?
    $sloodleobjname = $sloodle->request->optional_param('sloodleobjname', null);
    if ($sloodleobjname == null || empty($sloodleobjname)) {
        // No - just checking if the user can submit
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
$sloodle->response->add_data_line('Checked assignment status');
        $sloodle->response->render_to_output();
        exit();
    }
    
    // Object being submitted - fetch our other data
    $sloodleprimcount = (int)$sloodle->request->required_param('sloodleprimcount');
    $sloodleprimdropname = $sloodle->request->required_param('sloodleprimdropname');
    $sloodleprimdropuuid = $sloodle->request->required_param('sloodleprimdropuuid');
    $sloodleregion = $sloodle->request->required_param('sloodleregion');
    $sloodlepos = $sloodle->request->required_param('sloodlepos');
    
    // Make sure the position is valid
    $arr = sloodle_vector_to_array($sloodlepos);
    if (!$arr) $sloodlepos = '<0,0,0>';
    else $sloodlepos = sloodle_round_vector($sloodlepos);
    
    // Submit all the data
    if ($sloodle->module->submit($sloodle->user, $sloodleobjname, $sloodleprimcount, $sloodleprimdropname, $sloodleprimdropuuid, $sloodleregion, $sloodlepos)) {
        // OK
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
$sloodle->response->add_data_line('SUBMITTED OBJECT');
    } else {
        // Error
        $sloodle->response->set_status_code(-103);
        $sloodle->response->set_status_descriptor('SYSTEM');
        $sloodle->response->add_data_line('Failed to add assignment data into database.');
    }
    
    // Render the response
    $sloodle->response->render_to_output();
    exit();    
?>
