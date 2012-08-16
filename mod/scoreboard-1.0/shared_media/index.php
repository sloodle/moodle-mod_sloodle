<?php
    // This script is part of the Sloodle project

    /*
    * This script is intended to be shown on the surface of the scoreboard.
    *
    */ 
                  
    /**
    * @package sloodle
    * @copyright Copyright (c) 2011 various contributors (see below)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Paul Preibisch
    *
    */

    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../../init.php');
    /** Include the Sloodle PHP API. */
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    require_once(SLOODLE_DIRROOT.'/lib/db.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle course data. */
    require_once(SLOODLE_LIBROOT.'/course.php');
        require_once(SLOODLE_LIBROOT.'/io.php');

    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    require_once(SLOODLE_LIBROOT.'/currency.php');

     require_once('scoreboard_active_object.inc.php');

        $object_uuid = required_param('sloodleobjuuid', PARAM_RAW);
        $sao = SloodleScoreboardActiveObject::ForUUID( $object_uuid );

        //$is_admin = $is_logged_in && has_capability('moodle/course:manageactivities', $sao->context);

        $is_admin = ( isset($_REQUEST['mode']) && ($_REQUEST['mode'] == 'admin') );

        if ($is_admin) {
                require_login($sao->course->id);
        $is_logged_in = true;
        }

    if ($is_admin) {
        require_capability('moodle/course:manageactivities', $sao->context);
    }

    if (!$currencyid = $sao->currencyid) {
        print_error(('Currency ID missing'));
    }    

    $currency = SloodleCurrency::ForID( $currencyid );

    $student_scores = $sao->get_student_scores($include_scoreless_users = $is_admin);
    
    $full = false; 

/*
header('Cache-control: public');
header('Cache-Control: max-age=86400');
header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 60 * 60 * 24) . ' GMT');
header('Pragma: public');
*/

    if ($is_admin) {
        include('index.template.admin.php');
    }
    else{
        include('index.template.php');
    }
    

    print_html_top('', $is_logged_in);
    //print_toolbar( $baseurl, $is_logged_in ) ;

//    print_site_placeholder( $sitesURL );
//    print_round_list( $roundrecs );

//krumo($student_scores);
//krumo($score);

    print_score_list( 'scoreboard:allstudents', $student_scores, $object_uuid, $currency, $sao->roundid, $is_admin?5:$sao->refreshtime, $sao->objecttitle, $is_logged_in, $is_admin); 

    print_html_bottom();

?>
