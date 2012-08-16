<?php
    // This script is part of the Sloodle project
    // Created for Avatar Classroom, with the intention of eventually being ported back to regular Sloodle.
    // Some assumptions that are true for Avatar Classroom won't be true for arbitrary Moodle sites.
    // I'll try to comment these REGULAR SLOODLE TODO.

    /*
    * This script is intended to be shown on the surface of the Set.
    *
    * It will need to be passed all the paramters necessary to register the set in Authorized Objects.
    * This will include an http-in channel, it will use to send instructions to the set.
    * 
    * It will allow the user to browse their courses, layouts and objects.
    * They will then be able to rez layouts by creating AJAX requests which the server will then pass on to the rezzer object.
    *
    * When used for regular Sloodle, it will have the user login before showing them anything.
    * With Avatar Classroom the user will instead login to the Avatar Classroom site.
    * The Avatar Classroom site will then proxy to this page, attaching a token which will be used to authenticate the user.
    */

    /**
    * @package sloodle
    * @copyright Copyright (c) 2011 various contributors (see below)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    *
    */

	/** Grab the Sloodle/Moodle configuration. */
	require_once('../../../sl_config.php');
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

	require_once('scoreboard_active_object.inc.php');

	require_once '../../../lib/json/json_encoding.inc.php';
	//ini_set('display_errors', 1);
	//error_reporting(E_ALL);

	// Register the set using URL parameters

	$content = array();

        $object_uuid = required_param('sloodleobjuuid', PARAM_RAW);
        $sao = SloodleScoreboardActiveObject::ForUUID( $object_uuid );

        $is_logged_in = isset($USER) && ($USER->id > 0);
        $is_admin = $is_logged_in && has_capability('moodle/course:manageactivities', $sao->context);


        $student_scores = $sao->get_student_scores($include_scoreless_users = $is_admin);

	$result = 'refreshed';

	$content = array(
		'result' => $result,
		'error' => $error,
		'updated_scores' => $student_scores
	);

	print json_encode($content);
	exit;

function error_output($error) {
        $content = array(
                'result' => 'failed',
                'error' => $error,
        );
        print json_encode($content);
        exit;
}
?>
