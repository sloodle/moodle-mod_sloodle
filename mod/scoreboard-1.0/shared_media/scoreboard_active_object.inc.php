<?php
class SloodleScoreboardActiveObject extends SloodleActiveObject {

	var $roundid;
	var $currencyid;
	var $refreshtime;
	var $context;
	var $courseid;

	function ForUUID($object_uuid) {

		$ao = new SloodleScoreboardActiveObject();

		// Register the set using URL parameters
		if (!$ao->loadByUUID($object_uuid)) {
			return false;
		}

		$ao->initialize();

		return $ao;

	}

	function initialize() {

		$configs = $this->config_name_value_hash();
		$this->currencyid = intval($configs['sloodlecurrencyid']);

		if ( isset($configs['sloodleroundid']) && $configs['sloodleroundid'] > 0) {
			$this->roundid = intval($configs['sloodleroundid']);
		} else {
			$this->roundid = $this->course->controller->get_active_roundid();
		}

		$this->refreshtime = isset($configs['sloodlerefreshtime']) ? $configs['sloodlerefreshtime'] : 60;

		$this->context = get_context_instance(CONTEXT_COURSE, $this->course->course_object->id);
		$this->courseid = $this->course->course_object->id;

		return true;

	}

	function get_student_scores($is_admin) {

		global $CFG;	
		$prefix = $CFG->prefix;

		$contextid = intval($this->context->id);
		$roundid = intval($this->roundid);
		$currencyid = intval($this->currencyid);

		$scoresql = "select userid as userid, sum(amount) as balance from {$prefix}sloodle_award_points p where p.roundid = {$roundid} and p.currencyid = {$currencyid} group by p.userid order by balance desc;";

		$usersql = "select max(u.id) as userid, u.firstname as firstname, u.lastname as lastname, su.avname as avname from {$prefix}user u inner join ${prefix}role_assignments ra on u.id left outer join ${prefix}sloodle_users su on u.id=su.userid where ra.contextid={$contextid} group by u.id order by avname asc;";

		$scores = sloodle_get_records_sql( $scoresql );
		$students = sloodle_get_records_sql( $usersql);

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
			$student->name_html = ($student->avname != '') ? s($student->avname) : s($student->firstname.' '.$student->lastname);
			$student_scores[$userid] = $student;
		}

		// students without scores
		if ($is_admin) {
			foreach($students_by_userid as $userid => $student) {
				if (isset($student_scores[ $userid ] )) {
					continue; // already done
				}
				$student->has_scores = false;
				$student->balance = 0;
				$student_scores[ $userid ] = $student;
			}
		}

		return $student_scores;

	}

	function modify_score($userid, $userscore) {

                $award = new stdClass();
                $award->userid = $userid;
                $award->currencyid = $this->currencyid;
                $award->amount = $userscore;
                $award->timeawarded = time();
                $award->roundid = $this->roundid;

                sloodle_insert_record( 'sloodle_award_points', $award);

                SloodleActiveObject::NotifySubscriberObjects( 'awards_points_change', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );

		return true;	

	}

	function delete_scores( $userid ) {

                SloodleActiveObject::NotifySubscriberObjects( 'awards_points_deletion', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );

		return sloodle_delete_records( 'sloodle_award_points', 'roundid', $this->roundid, 'userid', $userid );
		
	}

	function make_new_round() {
		
                SloodleActiveObject::NotifySubscriberObjects( 'awards_points_round_change', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );

		return $this->course->controller->make_new_round( $clone_active_participation = true);

	}

}
?>
