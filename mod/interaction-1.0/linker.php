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
    * Edmund Edgar
    * Peter R. Bloomfield  
    *

    /**
    * 
    *
    */
    
    // This script should be called with the following parameters:
    //  sloodlemoduleid = ID of a SecondLife Tracker in MOODLE
    //  sloodleobjuuid = UUID of the object
    //  sloodleavuuid = UUID of the avatar
    //
 
    
    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, and load a tracker module
    $sloodle_session = new SloodleSession();
    $sloodle_session->authenticate_request();

    // Authenticate the user
    $sloodle_session->validate_user(true);
    $sloodle_session->user->login();

    $task = optional_param('task', 'default', PARAM_TEXT);

    // If the config for this object specifies something that we haven't done, this will return an error to the calling LSL script and exit.
    $sloodle_session->validate_requirements($task,1);

    $ok = $sloodle_session->process_interaction($task, 1);
    
    // Was it successful?
    if ($ok) {
            $sloodle_session->response->set_status_code(1);
            $sloodle_session->response->set_status_descriptor('OK');
            $sloodle_session->response->add_data_line($task);
    } else {
            $sloodle_session->response->set_status_code(-201);
            $sloodle_session->response->set_status_descriptor('OBJECT_AUTH');
            $sloodle_session->response->add_data_line('Failed to register the action.');
    }
    
    // Render the output
    $sloodle_session->response->render_to_output();

?>
