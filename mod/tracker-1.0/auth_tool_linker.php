<?php

    /**
    * This file is part of SLOODLE Tracker.
    * Copyright (c) 2009 Sloodle
    *
    * SLOODLE Tracker is free software: you can redistribute it and/or modify
    * it under the terms of the GNU General Public License as published by
    * the Free Software Foundation, either version 3 of the License, or
    * (at your option) any later version.
    *
    * SLOODLE Tracker is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    * GNU General Public License for more details.
    *
    * You should have received a copy of the GNU General Public License.
    * If not, see <http://www.gnu.org/licenses/>
    *
    * Contributors:
    * Peter R. Bloomfield  
    * Julio Lopez (SL: Julio Solo)
    * Michael Callaghan (SL: HarmonyHill Allen)
    * Kerri McCusker  (SL: Kerri Macchi)
    *
    * A project developed by the Serious Games and Virtual Worlds Group.
    * Intelligent Systems Research Centre.
    * University of Ulster, Magee	
    */

    /**
    * Sloodle object authorization linker.
    * Allows authorised objects in SL to initiate the comunication 
    * with a SLOODLE Second Life Tracker module.
    * (Creates a new entry in the 'sloodle_activity_tool' DB table.)
    */
        
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Attempt to authenticate the request (only require authentication if controller ID and/or password is set)
    // PRB: not sure why authentication is optional here -- should be required
    //$authrequired = (isset($_REQUEST['sloodlecontrollerid']) || isset($_REQUEST['sloodlepwd']));
    $sloodle = new SloodleSession();
    //$request_auth = $sloodle->authenticate_request($authrequired);
    $sloodle->authenticate_request();
    
    // Get the extra parameters
    $sloodleobjuuid = $sloodle->request->required_param('sloodleobjuuid');
    $sloodleobjname = $sloodle->request->required_param('sloodleobjname');
    $sloodleobjtype = $sloodle->request->required_param('sloodleobjtype', '');
    $sloodlemoduleid = $sloodle->request->required_param('sloodlemoduleid');
    $sloodledescription = $sloodle->request->required_param('sloodledescription');
    $sloodletaskname = $sloodle->request->required_param('sloodletaskname');
    
    // Create a SloodleModuleTracker instance and a new entry in the 'sloodle_activity_tool' DB table.
    $tracker = new SloodleModuleTracker($sloodle);
    
    $authid = $tracker->record_object($sloodleobjuuid,$sloodleobjname,$sloodleobjtype,$sloodlemoduleid,$sloodledescription,$sloodletaskname);
    
    if ($authid) {
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        $sloodle->response->add_data_line($authid);
    } else {
        $sloodle->response->set_status_code(-201);
        $sloodle->response->set_status_descriptor('OBJECT_AUTH');
        $sloodle->response->add_data_line('Failed to register new active object.');
    }

    // Render the output
    $sloodle->response->render_to_output();

?>
