<?php
    /**
    * Sloodle choice linker (for Sloodle 0.3).
    * Allows an SL object to access a Moodle choice instance.
    *
    * @package sloodlechoice
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = ID of a choice
    //
    // If called with only the above parameters, then summary information about the choice is fetched.
    // Status code 10001 will be returned, with the first few data lines having the following format:
    //   <choice_name>
    //   <choice_text>
    //   <is_available>|<timestamp_open>|<timestamp_close>
    //   <num_unanswered>
    //
    // Following that will be one line for each available option, with the following format:
    //   <option_id>|<option_text>|<num_selected>
    //  
    // The "num_unanswered" and "num_selected" values will be -1 if they are not allowed to be shown.
    // The "is_available" will be 1 if the choice is open and accepting answers, or 0 otherwise.
    // The timestamp values indicate when the choice opens and closes respectively, but will be 0 if there is no opening or closing time.
    //
    //
    // An option can be selected by including the following parameters
    //  sloodleuuid = UUID of the avatar
    //  sloodleavname = name of the avatar
    //  sloodleoptionid = the ID of a particular option (unique site-wide)
    //
    // If successful, the return code will be 10011, 10012, or 10013, depending what has been done. No data.
    // See the status codes list for further information.
    //
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../sl_config.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    ///// HORRIBLE HACK! /////
    // I've copied this function from Moodle 1.9.
    // Adding it here makes it work for Moodle 1.8 too.

    if (!function_exists('choice_get_response_data')) {
function choice_get_response_data($choice, $cm, $groupmode) {
    global $CFG, $USER;

    $context = get_context_instance(CONTEXT_MODULE, $cm->id);

/// Get the current group
    if ($groupmode > 0) {
        $currentgroup = groups_get_activity_group($cm);
    } else {
        $currentgroup = 0;
    }

/// Initialise the returned array, which is a matrix:  $allresponses[responseid][userid] = responseobject
    $allresponses = array();

/// First get all the users who have access here
/// To start with we assume they are all "unanswered" then move them later
    $allresponses[0] = get_users_by_capability($context, 'mod/choice:choose', 'u.id, u.picture, u.firstname, u.lastname, u.idnumber', 'u.firstname ASC', '', '', $currentgroup, '', false, true);

/// Get all the recorded responses for this choice
    $rawresponses = get_records('choice_answers', 'choiceid', $choice->id);

/// Use the responses to move users into the correct column

    if ($rawresponses) {
        foreach ($rawresponses as $response) {
            if (isset($allresponses[0][$response->userid])) {   // This person is enrolled and in correct group
                $allresponses[0][$response->userid]->timemodified = $response->timemodified;
                $allresponses[$response->optionid][$response->userid] = clone($allresponses[0][$response->userid]);
                unset($allresponses[0][$response->userid]);   // Remove from unanswered column
            }
        }
    }

    return $allresponses;

}
}

    ///// END HORRIBLE HACK! /////
    
    // Authenticate the request, and load a choice module
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->load_module('choice', true);

    // Has an option been specified?
    $sloodleoptionid = $sloodle->request->optional_param('sloodleoptionid');
    if ($sloodleoptionid === null) {
        // No - we are simply querying for choice data
        $sloodle->response->set_status_code(10001);
        $sloodle->response->set_status_descriptor('CHOICE_QUERY');
        
        // Check availability and results
        $isavailable = '0';
        if ($sloodle->module->is_open()) $isavailable = '1';
        $canshowresults = $sloodle->module->can_show_results();

        // Fetch the intro (question) text, but cut everything after the first line
        $qtext = trim($sloodle->module->get_intro());
        $qlines = explode("<br />", $qtext);
        if (is_array($qlines) && count($qlines) > 0) $qtext = stripslashes(strip_tags($qlines[0]));
        else $qtext = '';
        // Whatever happens, make sure the question text isn't too long
        $maxqtextlen = 128;
        if (strlen($qtext) > $maxqtextlen) {
            $qlines = str_split($qtext, $maxqtextlen);
            if (is_array($qlines) && count($qlines) > 0) $qtext = trim($qlines[0]).'...';
        }
        
        // Add the data to the response
        $sloodle->response->add_data_line($sloodle->module->get_name());
        $sloodle->response->add_data_line($qtext);
        $sloodle->response->add_data_line(array($isavailable, $sloodle->module->get_opening_time(), $sloodle->module->get_closing_time()));
        if ($canshowresults) $sloodle->response->add_data_line($sloodle->module->get_num_unanswered());
        else $sloodle->response->add_data_line('-1');
        // Go through each option
        foreach ($sloodle->module->options as $optionid => $option) {
            // Prepare a data array for this option
            $optiondata = array();
            $optiondata[] = $optionid;
            $optiondata[] = stripslashes(strip_tags($option->text));
            if ($canshowresults) $optiondata[] = $option->numselections;
            else $optiondata[] = -1;
            
            $sloodle->response->add_data_line($optiondata);
        }
        
    } else {
        // Yes - validate the user, and permit auto-registration/enrolment
        $sloodle->validate_user();
        $sloodle->response->set_status_descriptor('CHOICE_SELECT');
        
        // Attempt to select the option
        $result = $sloodle->module->select_option($sloodleoptionid);
        if (!$result) {
            $sloodle->response->set_status_code(-10016);
            $sloodle->response->add_data_line('Unknown error selecting option.');
        } else {
            $sloodle->response->set_status_code($result);
        }
    }
    
    // Output our response
    $sloodle->response->render_to_output();
    
?>
