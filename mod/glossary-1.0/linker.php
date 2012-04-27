<?php
    /**
    * Sloodle glossary linker (for Sloodle 0.3).
    * Allows a Sloodle MetaGloss to search a Moodle glossary.
    *
    * @package sloodleglossary
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @todo Implement ability to add new entries?
    *
    * @contributor (various)
    * @contributor Peter R. Bloomfield
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = ID of a glossary
    //
    // If requested with only the above parameters, then the glossary name will be returned on the first data line (status code 1).
    // The 'intro' (description), if available, will be provided on the second line, without any HTML markup.
    //
    // In order to search the glossary, the following parameters must also be specified:
    //  sloodleterm = a string to search by
    //  sloodleuuid = UUID of the avatar searching
    //  sloodleavname = name of the avatar searching
    //
    // The following parameters are optional:
    //  sloodlepartialmatches = if 'true' or '1' then searches will show partial matches too (defaults to true)
    //  sloodlesearchaliases = if 'true' or '1' then searches will search by aliases too (defaults to false)
    //  sloodlesearchdefinitions = if 'true' or '1' then searches will search by definitions too (defaults to false)
    //
    //  sloodleserveraccesslevel = defines the access level to the resource (ignored if unspecified)
    //
    // The following parameter is optional:
    //  sloodledebug = if 'true', then Sloodle debugging mode is activated    
    
    // If successful, status code 1 will be returned.
    // Each data line will contain a concept and definition separated by a pipe: <concept>|<definition>
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Authenticate the request, and load a glossary module
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->load_module('glossary', true);

    // Has a search term been specified?
    $sloodleterm = $sloodle->request->optional_param('sloodleterm', null);
    if (empty($sloodleterm)) {
        // Just fetch the name of the glossary
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        $sloodle->response->add_data_line($sloodle->module->get_name());
        $sloodle->response->add_data_line(strip_tags($sloodle->module->get_intro()));
        $sloodle->response->render_to_output();
        exit();
    }
    
    // If the server access level has been specified, then validate the user
    $serveraccesslevel = $sloodle->request->get_server_access_level(false);
    if ($serveraccesslevel !== null && $serveraccesslevel != 0) $sloodle->validate_user();
    else $sloodle->validate_user(false);
    
    // Get our other parameters
    $sloodleterm = addslashes($sloodleterm);
    $sloodlepartialmatches = $sloodle->request->optional_param('sloodlepartialmatches', 'true');
    $sloodlesearchaliases = $sloodle->request->optional_param('sloodlesearchaliases', 'false');
    $sloodlesearchdefinitions = $sloodle->request->optional_param('sloodlesearchdefinitions', 'false');
    
    // Convert our incoming parameters as necessary
    if (strcasecmp($sloodlepartialmatches, 'true') == 0 || $sloodlepartialmatches == '1') $sloodlepartialmatches = true;
    else $sloodlepartialmatches = false;
    if (strcasecmp($sloodlesearchaliases, 'true') == 0 || $sloodlesearchaliases == '1') $sloodlesearchaliases = true;
    else $sloodlesearchaliases = false;
    if (strcasecmp($sloodlesearchdefinitions, 'true') == 0 || $sloodlesearchdefinitions == '1') $sloodlesearchdefinitions = true;
    else $sloodlesearchdefinitions = false;
    
    // Search the glossary
    $results = $sloodle->module->search($sloodleterm, $sloodlepartialmatches, $sloodlesearchaliases, $sloodlesearchdefinitions);
    if (is_array($results)) {
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('OK');
        // Go through each result
        foreach ($results as $r) {
            $concept = sloodle_clean_for_output($r->concept);
            $def = sloodle_clean_for_output($r->definition);
            $sloodle->response->add_data_line(array($concept, $def));
        }
    } else {
        $sloodle->response->set_status_code(-103);
        $sloodle->response->set_status_descriptor('SYSTEM');
        $sloodle->response->add_data_line('Failed to search glossary');
    }
    
    // Output our response
    sloodle_debug('<pre>'); // For debug mode, lets us see the response in a browser
    $sloodle->response->render_to_output();
    sloodle_debug('</pre>');
    
?>
