<?php
    /**
    * Sloodle scoreboard
    *
    * @package sloodlepwreset
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    // This script should be called with the following parameters:
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodleuuid = the UUID of a user agent
    //  sloodleavname = the name of an avatar
    //
    // The following parameter is optional:
    //  sloodleserveraccesslevel = indicates what access level to enforce: 0 = public, 1 = course, 2 = site, 3 = staff
    //
    //
    // If successful, the script will reset the user's password, returning status code 1.
    // The data line will contain: username|password
    //
    // If the user has an active email account associated with their Moodle account, then
    //  status code -341 is returned, and the password is unchanged.
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');



    
    // Authenticate the request, and validate the user, but do not allow auto-registration/enrolment
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();

    $ao = $sloodle->active_object;
    $def = $ao->objectDefinition();

    $roundid = $sloodle->course->controller->get_active_roundid($force_create = true);

    global $CFG;

    $currencyid = $ao->config_value( 'sloodlecurrencyid' );

    $currencyname = '';

    if ($currencyid) {
        // Ge the name of the currency
        $currency_recs = sloodle_get_records_sql_params( "select id, name as currency_name from {$CFG->prefix}sloodle_currency_types where id = ?;", array($currencyid));
        $currency_rec = array_shift($currency_recs);
        $currencyname = $currency_rec->currency_name;
    }

    $user_point_total_recs = sloodle_get_records_sql_params( "select p.userid as userid, sum(amount) as balance, su.avname as avname, su.uuid as uuid from {$CFG->prefix}sloodle_award_points p inner join {$CFG->prefix}sloodle_users su on p.userid=su.userid where currencyid=? and roundid=? group by userid order by balance desc;", array($currencyid, $roundid));

    //$sloodle->response->set_status_code($success_code);
    //$sloodle->response->set_status_code(1639271140);
    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('SCORES');
    $sloodle->response->set_request_descriptor('SCORES');


    $linesperpage = 10;
    if ( isset($def->fixed_parameters) && isset($def->fixed_parameters['linesperpage']) ) {
        $linesperpage = $def->fixed_parameters['linesperpage'];
    }
    $charactersperline = 40;
    if ( isset($def->fixed_parameters) && isset($def->fixed_parameters['charactersperline']) ) {
            $charactersperline = $def->fixed_parameters['charactersperline'];
    }

    $page = $ao->config_value( 'sloodleactivepage' );
    if (!$page) {
        $page = 1;
    }

    $scoreboardtitle= $ao->config_value('sloodleobjecttitle');

    /*
    foreach($params as $n=>$v) {
        $sloodle->response->add_data_line($n.'|'.$v);
    }
    */

    $num_pages = ceil( count($user_point_total_recs) / $linesperpage );
    $sloodle->response->add_data_line("status|$page|$num_pages|$scoreboardtitle||$currencyid|$currencyname");

    $offset = ( ($page-1) * $linesperpage );
    $page_points = array_slice( $user_point_total_recs, $offset, $linesperpage );
    foreach($page_points as $up) {
        $uuid = $up->uuid;
        $avname = $up->avname;
        $score = $up->balance;
        $availablechars = $charactersperline - ( strlen($score) + 1 ); // leave room for a space folowed by the score
        $displayavname = substr($avname, 0, $availablechars); // truncate the name if it's too long to fit.
        $displayavname = str_pad( $displayavname, $availablechars, " ");
        $displayline = $displayavname." ".$score;
        $sloodle->response->add_data_line("$uuid|$score|$displayline");
    }

    $renderStr = '';
    $sloodle->response->render_to_output($renderStr);
    
    exit;
    //$sloodle->response->render_to_output();
    
?>
