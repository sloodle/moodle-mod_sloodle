<?php
class SloodleScoreboardActiveObject extends SloodleActiveObject {

	var $roundid;
	var $currencyid;
	var $refreshtime;
	var $context;
	var $courseid;
	var $objecttitle;

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

		if ( isset($configs['sloodleroundid']) && $configs['sloodleroundid'] > 0) {
			$this->roundid = intval($configs['sloodleroundid']);
		} else {
			$this->roundid = $this->course->controller->get_active_roundid($force_create = true);
		}

		$this->currencyid =  isset($configs['sloodlecurrencyid']) ? intval($configs['sloodlecurrencyid']) : 0; 
		$this->refreshtime = isset($configs['sloodlerefreshtime']) ? intval($configs['sloodlerefreshtime']) : 60;
		$this->objecttitle = isset($configs['sloodleobjecttitle']) ? $configs['sloodleobjecttitle'] : '';

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

		$scoresql = "select userid as userid, sum(amount) as balance from {$prefix}sloodle_award_points p where p.roundid = ? and p.currencyid = ? group by p.userid order by balance desc;";

		$usersql = "select max(u.id) as userid, u.username as username, su.avname as avname from {$prefix}user u inner join ${prefix}role_assignments ra on u.id = ra.userid inner join ${prefix}sloodle_users su on u.id=su.userid where ra.contextid=? group by u.id order by avname asc;";

		$scores = sloodle_get_records_sql_params( $scoresql, array($roundid, $currencyid) );
		$students = sloodle_get_records_sql_params( $usersql, array($contextid) );

		$students_by_userid = array();

		// Add any admin users that have avatars.
		$admin_users = SloodleUser::SiteAdminUserIDsToAvatarNames();
		foreach($admin_users as $userid => $avname) {
			$rec = new stdClass();
			$rec->avname = $avname;
			$rec->userid = $userid;
			$students_by_userid[$userid] = $rec;	
		}


		foreach($students as $student) {
			// Make a moodle user object with enough info for isguestuser to tell us if they're a guest or not.
			// Looking at the isguestuser() function, it looks like the userid and username should be enough to check this without needing any more db lookups.
			// This may blow up in future versions if Moodle starts expecting a properly loaded moodle user object.
			// When we drop < Moodle 2 support, we can start just passing the userid rather than a user object.
			$mdluser = new stdClass();
			$mdluser->id = $student->userid;
			$mdluser->username = $student->username;
			if (isguestuser($mdluser)) {
				continue;	
			}
			unset($student->username);
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
			$student->name_html = s($student->avname);
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

                SloodleModuleAwards::NotifyRealtimeBroadcastClients('awards_points_change', 10601, $controllerid, $userid, array('balance' => $balance, 'roundid' => $roundid, 'userid' => $userid, 'currencyid' => $currencyid, 'timeawarded' => $time ) );;
                SloodleActiveObject::NotifySubscriberObjects( 'awards_points_change', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );

		return true;	

	}

	function delete_scores( $userid ) {

		if (!sloodle_delete_records( 'sloodle_award_points', 'roundid', $this->roundid, 'userid', $userid )) {
			return false;
        }

        SloodleModuleAwards::NotifyRealtimeBroadcastClients('awards_points_change', 10601, $controllerid, $userid, array('balance' => $balance, 'roundid' => $roundid, 'userid' => $userid, 'currencyid' => $currencyid, 'timeawarded' => $time ) );;
        SloodleActiveObject::NotifySubscriberObjects( 'awards_points_deletion', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );
	
		return true;
		
	}

	function make_new_round() {

		if (!$this->course->controller->make_new_round( $clone_active_participation = true)) {
			return false;
		}
		
        SloodleModuleAwards::NotifyRealtimeBroadcastClients('awards_points_change', 10601, $controllerid, $userid, array('balance' => $balance, 'roundid' => $roundid, 'userid' => $userid, 'currencyid' => $currencyid, 'timeawarded' => $time ) );;
        SloodleActiveObject::NotifySubscriberObjects( 'awards_points_round_change', 10601, $this->controllerid, $userid, array('balance' => $userscore, 'roundid' => $this->roundid, 'userid' => $userid, 'currencyid' => $this->currencyid, 'timeawarded' => time() ), true );

		return true;

	}

}
?>
