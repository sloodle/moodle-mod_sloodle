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

    $object_uuid = required_param('sloodleobjuuid', PARAM_RAW);

    $ao = new SloodleActiveObject();

    // Register the set using URL parameters
    if (!$ao->loadByUUID($object_uuid)) {
        print "Scoreboard no longer available.";
        exit;
    }

    $configs = $ao->config_name_value_hash();

    if ( !isset($configs['sloodleustreamchannel']) || $configs['sloodleustreamchannel'] == '') {
        print "Error: ustream channel not set";
        exit;
    } 

    $channel = $configs['sloodleustreamchannel'];

    if ( !defined('SLOODLE_USTREAM_API_KEY') || (SLOODLE_USTREAM_API_KEY == '') ) {
        print "Error: No API key, could not get channel.";
        exit;
    }

    $url = 'http://api.ustream.tv/json/channel/'.urlencode($channel).'/getCustomEmbedTag?key='.SLOODLE_USTREAM_API_KEY.'&params=autoplay:true;mute:false;height:980;width:980';

    $ch = curl_init();    // initialize curl handle
    curl_setopt($ch, CURLOPT_URL, $url); // set url to post to
    curl_setopt($ch, CURLOPT_FAILONERROR,0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    $result = curl_exec($ch); // run the whole process
    $info = curl_getinfo($ch);
    curl_close($ch);

    $json = json_decode($result);
    if (!isset($json->results)) {
        print "Error: No stream available right now";
        exit;
    }

    $embed = $json->results;
    if ($embed == '') {
        print "Error: No stream available right now";
        exit;
    }

    print '<html>';
    print '<body style="background-color:black; border:0px; margin:0px; text-align:center; vertical-align:middle">';
    print '<div style="border:0px; background-color:black; text-align:center; vertical-align:middle; width:98%; height:98%">';
    print $embed;
    print '</div>';
    print '</body>';
    print '</html>';

?>
