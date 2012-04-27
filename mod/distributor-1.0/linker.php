<?php
    /**
    * Sloodle distributor linker (for Sloodle 0.3).
    * Allows a Sloodle Vending Machine to update its inventory and XMLRPC channel details.
    *
    * @package sloodledistributor
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = ID of a chatroom
    //  sloodleinventory = a pipe-separated list of names of items in the obect's inventory
    //  sloodlechannel = the UUID of an XMLRPC channel which can be used to request object distribution
    //
    // The following parameter is optional:
    //  sloodledebug = if 'true', then Sloodle debugging mode is activated    
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, and load a chat module
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->load_module('distributor', true);
    
    // Fetch the required additional parameters
    $sloodleinventory = $sloodle->request->required_param('sloodleinventory');
    $sloodlechannel = $sloodle->request->required_param('sloodlechannel');
    
    // Attempt to update the inventory
    $objects = explode('|', $sloodleinventory);
    if (!$sloodle->module->set_objects($objects)) {
        // Update failed
        $sloodle->response->quick_output(-101, 'SYSTEM', 'Failed to update list of objects', false);
        exit();
    }
    
    // Attempt to update the channel
    if (!$sloodle->module->set_channel($sloodlechannel)) {
        // Update failed
        $sloodle->response->quick_output(-101, 'SYSTEM', 'Failed to update XMLRPC channel UUID', false);
        exit();
    }
    
    // Everything seems fine
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('OK');
    
    // Output our response
    $sloodle->response->render_to_output();
    
?>
