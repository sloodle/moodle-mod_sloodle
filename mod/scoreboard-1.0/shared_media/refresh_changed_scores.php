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
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle course data. */
    require_once(SLOODLE_LIBROOT.'/course.php');

    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');

    require_once '../../../lib/json/json_encoding.inc.php';
//ini_set('display_errors', 1);
//error_reporting(E_ALL);

	// Register the set using URL parameters

	$content = array();

	// Register the set using URL parameters
	$ao = new SloodleActiveObject();
	$object_uuid = required_param('sloodleobjuuid');
	if (!$ao->loadByUUID($object_uuid)) {
		print "not found";
		exit;
	}

	$configs = $ao->config_name_value_hash();

	$roundid = 1;
	$currencyid = 0;

	$context = get_context_instance(CONTEXT_COURSE,$ao->course->course_object->id);
	$contextid = $context->id;
	$courseid = $ao->course->course_object->id;

	$is_logged_in = isset($USER) && ($USER->id > 0);
        $is_admin = $is_logged_in && has_capability('moodle/course:manageactivities', $context); 

	$scoresql = "select userid as userid, sum(amount) as balance from mdl_sloodle_award_points p where p.roundid = {$roundid} and p.currencyid = {$currencyid} group by p.userid order by balance desc;";
	//$scoresql = "select userid as userid, sum(amount) as balance from mdl_sloodle_award_points p inner join mdl_sloodle_award_rounds ro on p.roundid=ro.id where p.roundid = {$roundid} and ro.courseid = {$courseid} and p.currencyid = {$currencyid} group by p.userid order by balance desc;";

 	$usersql = "select max(u.id) as userid, u.firstname as firstname, u.lastname as lastname, su.avname as avname from mdl_user u inner join mdl_role_assignments ra on u.id left outer join mdl_sloodle_users su on u.id=su.userid where ra.contextid={$contextid} group by u.id order by avname asc;";

//select max(u.userid) as userid, sum(p.amount) as balance from mdl_sloodle_award_points p left outer join mdl_sloodle_users u on p.userid=u.userid inner join mdl_groups_members m on u.userid=m.userid where m.groupid=2 group by u.userid;

	$scores = get_records_sql( $scoresql );
	$students = get_records_sql( $usersql);

	$students_by_userid = array();
	foreach($students as $student) {
		$students_by_userid[ $student->userid ] = $student;
	}

	// students with scores, in score order
	$student_scores = array();
	foreach($scores as $score) {
		$userid = $score->userid;
		if (!isset($students_by_userid[ $userid ])) { // student deleted but their score is still there.
			continue;
		}
		$student = $students_by_userid[ $userid ];
		$student->has_scores = true;
		$student->balance = $score->balance;
		$student->name_html = s( $student->avname ? $student->avname : $student->firstname.' '.$student->lastname );
		$student_scores[$userid] = $student;
	}

	if (true || $is_admin) {
		// students without scores
		foreach($students_by_userid as $userid => $student) {
			if (isset($student_scores[ $userid ] )) {
				continue; // already done
			}
			$student->has_scores = false;
			$student->balance = 0;
			$student->name_html = s( $student->avname );
			$student_scores[ $userid ] = $student;
		}
	}

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
