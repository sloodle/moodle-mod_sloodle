<?php
    /**
    * Sloodle quiz linker (for Sloodle 0.3).
    * Allows in-world objects to interact with Moodle quizzes.
    * Part of the Sloodle project (www.sloodle.org).
    *
    * @package sloodlequiz
    * @copyright Copyright (c) 2006-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor (various Moodle authors)
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    */

    // This script is expected to be requested by an in-world object.
    // The following parameters are required:
    //
    //   sloodlecontrollerid = ID of the controller through which to access Moodle
    //   sloodlepwd = password to authenticate the request
    //   sloodlemoduleid = the course module ID of the quiz to access
    //   sloodleuuid = UUID of the avatar making the request (optional if 'sloodleavname' is specified)
    //   sloodleavname = avatar name of the user making the request (optional if 'sloodleuuid' is specified)
    //
    //
    //
    // The following are the original quiz parameters:
    //
    //   q = ID of the quiz course module instance
    //   id = ID of the course which this request relates to
    //   page = ?
    //   questionids = ?
    //   finishattempt = ?
    //   timeup = true if submission was by timer
    //    forcenew = teacher has requested a new preview
    //    action = ??
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../sl_config.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    /** Include the Moodle quiz code.  */
    require_once($CFG->dirroot.'/mod/quiz/locallib.php');

//ini_set('display_errors','On'); 

    // Authenticate the request and login the user
    $sloodle = new SloodleSession();
    $sloodle->authenticate_request();
    $sloodle->validate_user();
    $sloodle->user->login();

    $sloodle->validate_requirements();

    
    // Grab our additional parameters
    $id = $sloodle->request->get_module_id();
    $limittoquestion = optional_param('ltq', 0, PARAM_INT);

    $output = array();

    $courseid = optional_param('courseid', 0, PARAM_INT);               // Course Module ID
    //$id = optional_param('id', 0, PARAM_INT);               // Course Module ID
    $q = optional_param('q', 0, PARAM_INT);                 // or quiz ID
    $page = optional_param('page', 0, PARAM_INT);
    $questionids = optional_param('questionids', '');
    $finishattempt = optional_param('finishattempt', 0, PARAM_BOOL);
    $timeup = optional_param('timeup', 0, PARAM_BOOL); // True if form was submitted by timer.
    $forcenew = optional_param('forcenew', false, PARAM_BOOL); // Teacher has requested new preview

    $isnotify = ( optional_param( 'action', false, PARAM_RAW ) == 'notify' ) ;

    // remember the current time as the time any responses were submitted
    // (so as to make sure students don't get penalized for slow processing on this page)
    $timestamp = time();

    // We treat automatically closed attempts just like normally closed attempts
    if ($timeup) {
        $finishattempt = 1;
    }

    if ( ($courseid != 0) && ($id == 0) && ($q == 0) ) {
        // fetch a quiz with the id for the course
         if (! $mod = sloodle_get_record("modules", "name", "quiz") ) {
             $sloodle->response->quick_output(-712, 'MODULE_INSTANCE', 'Could not find quiz module', FALSE);
             exit;
         }

         //if (! $coursemod = sloodle_get_record("course_modules", "courseid", $courseid, "module", $mod->id)) {
         if (! $coursemod = sloodle_get_record("course_modules", "course", $courseid, "module", $mod->id)) {
             $sloodle->response->quick_output(-712, 'MODULE_INSTANCE', 'Could not find course module instance', FALSE);
             exit;
         }

         $id = $coursemod->id;

    }
    if ($id) {
        if (! $cm = get_coursemodule_from_id('quiz', $id)) {
            $sloodle->response->quick_output(-701, 'MODULE_INSTANCE', 'Identified module instance is not a quiz', FALSE);
            exit();
        }

        if (! $course = sloodle_get_record("course", "id", $cm->course)) {
            $sloodle->response->quick_output(-701, 'MODULE_INSTANCE', 'Quiz module is misconfigured', FALSE);
            exit();
        }

        if (! $quiz = sloodle_get_record("quiz", "id", $cm->instance)) {
            $sloodle->response->quick_output(-712, 'MODULE_INSTANCE', 'Part of quiz module instance is missing', FALSE);
            exit();
        }

    } else {
        if (! $quiz = sloodle_get_record("quiz", "id", $q)) {
            $sloodle->response->quick_output(-712, 'MODULE_INSTANCE', 'Could not find quiz module', FALSE);
            exit();
        }
        if (! $course = sloodle_get_record("course", "id", $quiz->course)) {
            $sloodle->response->quick_output(-712, 'MODULE_INSTANCE', 'Part of quiz module instance is missing', FALSE);
            exit();
        }
        if (! $cm = get_coursemodule_from_instance("quiz", $quiz->id, $course->id)) {
            $sloodle->response->quick_output(-701, 'MODULE_INSTANCE', 'Unable to resolve course module instance', FALSE);
            exit();
        }
    }


// Get number for the next or unfinished attempt
    if(!$attemptnumber = (int)sloodle_get_field_sql_params('SELECT MAX(attempt)+1 FROM ' .
     "{$CFG->prefix}quiz_attempts WHERE quiz = ? AND " .
     "userid = ? AND timefinish > 0 AND preview != 1", array($quiz->id, $USER->id))) {
        $attemptnumber = 1;
    }

    $strattemptnum = get_string('attempt', 'quiz', $attemptnumber);
    $strquizzes = get_string("modulenameplural", "quiz");

    // course id: $course->id
    // course id: $course->id
    // course name: $quiz->id
    // attempts: $quiz->attempts
    if ($limittoquestion == 0) $output[] = array('course',$course->id,$course->fullname);

    $numberofpreviousattempts = sloodle_count_records_select_params('quiz_attempts', "quiz = ? AND " .
        "userid = ? AND timefinish > 0 AND preview != 1", array($quiz->id, $USER->id));
    if ($quiz->attempts and $numberofpreviousattempts >= $quiz->attempts) {
        $sloodle->response->quick_output(-10301, 'QUIZ', 'You do not have any attempts left', FALSE);
        exit();
    }

/// Check subnet access
    if ($quiz->subnet and !address_in_subnet(getremoteaddr(), $quiz->subnet)) {
        $sloodle->response->quick_output(-1, 'MISC', 'A subnet error occurred', FALSE);
        exit();
    }

/// Check password access
    if ($quiz->password) {
        $sloodle->response->quick_output(-10302, 'QUIZ', 'Quiz requires password - not supported by Sloodle', FALSE);
        exit();
    }


    if ($quiz->delay1 or $quiz->delay2) {
        //quiz enforced time delay
        if ($attempts = quiz_get_user_attempts($quiz->id, $USER->id)) {
            $numattempts = count($attempts);
        } else {
            $numattempts = 0;
        }
        $timenow = time();
        $lastattempt_obj = sloodle_get_record_select_params('quiz_attempts', "quiz = ? AND attempt = ? AND userid = ?", array($quiz->id, $numattempts, $USER->id), 'timefinish');
        if ($lastattempt_obj) {
            $lastattempt = $lastattempt_obj->timefinish;
        }
        if ($numattempts == 1 && $quiz->delay1) {
            if ($timenow - $quiz->delay1 < $lastattempt) {
                $sloodle->response->quick_output(-701, 'QUIZ', 'You need to wait until the time delay has expired.', FALSE);
                exit();
            }
        } else if($numattempts > 1 && $quiz->delay2) {
            if ($timenow - $quiz->delay2 < $lastattempt) {
                $sloodle->response->quick_output(-701, 'QUIZ', 'You need to wait until the time delay has expired.', FALSE);
                exit();
            }
        }
    }

//  sloodle_prim_render_output($output);
//  exit;

/// Load attempt or create a new attempt if there is no unfinished one

    $attempt = sloodle_get_record('quiz_attempts', 'quiz', $quiz->id,
     'userid', $USER->id, 'timefinish', 0);

    $newattempt = false;
    if (!$attempt) {
        $newattempt = true;
        // Start a new attempt and initialize the question sessions
        $attempt = quiz_create_attempt($quiz, $attemptnumber);
        // If this is an attempt by a teacher mark it as a preview
        // Save the attempt

    if (!$attempt->timestart) { // shouldn't really happen, just for robustness
        $attempt->timestart = time();
    }
    if (!$attempt->timemodified) { // shouldn't really happen, just for robustness
        $attempt->timemodified = time();
    }

        if (!$attempt->id = sloodle_insert_record('quiz_attempts', $attempt)) {
            $sloodle->response->quick_output(-701, 'QUIZ', 'Could not create new attempt.', FALSE);
            exit();
        }
        // make log entries
        add_to_log($course->id, 'quiz', 'attempt',
                       "review.php?attempt=$attempt->id",
                       "$quiz->id", $cm->id);

    } else {
        // log continuation of attempt only if some time has lapsed
        if (($timestamp - $attempt->timemodified) > 600) { // 10 minutes have elapsed
             add_to_log($course->id, 'quiz', 'continue attemp', // this action used to be called 'continue attempt' but the database field has only 15 characters
                           "review.php?attempt=$attempt->id",
                           "$quiz->id", $cm->id);
        }
    }
    if (!$attempt->timestart) { // shouldn't really happen, just for robustness
        $attempt->timestart = time();
    }

/// Load all the questions and states needed by this script

    ///// SLOODLE MODIFICATION /////
    // For SLOODLE to work properly, it needs the entire list of questions at all times.
    // It ignores the "page" structure of a Moodle quiz.
    $questionlist = quiz_questions_in_quiz($attempt->layout);

    $pagelist = $questionlist;
    ///// END SLOODLE MODIFICATION /////

    $questionlistids = explode(',', $questionlist);
    if ($questionids != '') {
        $questionids = explode(',', $questionids);
    }

    // add all questions that are on the submitted form
    if ($questionids && (count($questionids) > 0) ) {
        $questionlistids = array_merge($questionlistids, $questionids);
    }
  
    $params = array($quiz->id);
    $questioninstr = '';
    $delim = '';
    foreach($questionlistids as $qlid) {
        $params[] = $qlid;
        $questioninstr .= $delim.'?';
        $delim = ','; 
    }

    if ( !$questionlistids || (count($questionlistids) == 0) ) {
        $sloodle->response->quick_output(-10303, 'QUIZ', 'No questions found.', FALSE);
        exit();
    }

    $sql = "SELECT q.*, i.grade AS maxgrade, i.id AS instance".
           "  FROM {$CFG->prefix}question q,".
           "       {$CFG->prefix}quiz_question_instances i".
           " WHERE i.quiz = ? AND q.id = i.question".
           "   AND q.id IN ($questioninstr) ;";

    // Load the questions
    $questions = sloodle_get_records_sql_params($sql, $params); 
    if ( !$questions || (count($questions) == 0) ) {
        $sloodle->response->quick_output(-10303, 'QUIZ', 'No questions found.'.$sql.join(':',$params), FALSE);
exit;
        $sloodle->response->quick_output(-10303, 'QUIZ', 'No questions found.', FALSE);
        exit();
    }

    // Load the question type specific information
    if (!get_question_options($questions)) {
        $sloodle->response->quick_output(-10303, 'QUIZ', 'Could not load question options.', FALSE);
        exit();
    }

    // Restore the question sessions to their most recent states
    // creating new sessions where required
    if (!$states = get_question_states($questions, $quiz, $attempt)) {
        $sloodle->response->quick_output(-701, 'QUIZ', 'Could not restore questions sessions.', FALSE);
        exit();
    }

    // Save all the newly created states
    if ($newattempt) {
        foreach ($questions as $i => $question) {
            save_question_session($questions[$i], $states[$i]);
        }
    }

    // If the new attempt is to be based on a previous attempt copy responses over
    if ($newattempt and $attempt->attempt > 1 and $quiz->attemptonlast and !$attempt->preview) {
        // Find the previous attempt
        if (!$lastattemptid = sloodle_get_field('quiz_attempts', 'uniqueid', 'quiz', $attempt->quiz, 'userid', $attempt->userid, 'attempt', $attempt->attempt-1)) {
            $sloodle->response->quick_output(-701, 'QUIZ', 'Could not find previous attempt to build on.', FALSE);
            exit();
        }
        // For each question find the responses from the previous attempt and save them to the new session
        foreach ($questions as $i => $question) {
            // Load the last graded state for the question
            $statefields = 'n.questionid as question, s.*, n.sumpenalty';
            $sql = "SELECT $statefields".
                   "  FROM {$CFG->prefix}question_states s,".
                   "       {$CFG->prefix}question_sessions n".
                   " WHERE s.id = n.newgraded".
                   "   AND n.attemptid = ?".
                   "   AND n.questionid = ?";
            if (!$laststate = sloodle_get_record_sql_params($sql, array($lastattemptid, $i))) {
                // Only restore previous responses that have been graded
                continue;
            }
            // Restore the state so that the responses will be restored
            restore_question_state($questions[$i], $laststate);
            // prepare the previous responses for new processing
            $action = new stdClass;
            $action->responses = $laststate->responses;
            $action->timestamp = $laststate->timestamp;
            $action->event = QUESTION_EVENTOPEN;

            // Process these responses ...
            question_process_responses($questions[$i], $states[$i], $action, $quiz, $attempt);

            // Fix for Bug #5506: When each attempt is built on the last one,
            // preserve the options from any previous attempt. 
            if ( isset($laststate->options) ) {
                $states[$i]->options = $laststate->options;
            }

            // ... and save the new states
            save_question_session($questions[$i], $states[$i]);
        }
    }

/// Process form data /////////////////////////////////////////////////

    if ($isnotify) {
                SloodleDebugLogger::log('DEBUG', "in is notify");



        $responses = (object)$_REQUEST; // GET version of data_submitted (see lib/weblib) used in original web version

        // set the default event. This can be overruled by individual buttons.
        $event = (array_key_exists('markall', $responses)) ? QUESTION_EVENTSUBMIT :
         ($finishattempt ? QUESTION_EVENTCLOSE : QUESTION_EVENTSAVE);

                SloodleDebugLogger::log('DEBUG', "checked finish attempt");
        // Unset any variables we know are not responses
        unset($responses->id);
        unset($responses->q);
        unset($responses->oldpage);
        unset($responses->newpage);
        unset($responses->review);
        unset($responses->questionids);
        unset($responses->saveattempt); // responses get saved anway
        unset($responses->finishattempt); // same as $finishattempt
        unset($responses->markall);
        unset($responses->forcenewattempt);

        // extract responses
        // $actions is an array indexed by the questions ids
        $actions = question_extract_responses($questions, $responses, $event);

                SloodleDebugLogger::log('DEBUG', "extracted");
        // Process each question in turn

        foreach($questionids as $i) {
            if (!isset($actions[$i])) {
                $actions[$i]->responses = array('' => '');
            }
            $actions[$i]->timestamp = $timestamp;
            question_process_responses($questions[$i], $states[$i], $actions[$i], $quiz, $attempt);
            save_question_session($questions[$i], $states[$i]);
        }

        $attempt->timemodified = $timestamp;

    // We have now finished processing form data

    // With post sloodle-2.0 quiz chairs, we should be told what happened to the score.
    // In theory we should be able to get this from the data we already have, but it seems complex...
    // The process_interactions allows us to award points if there is an instruction to do so in the object config.
	$scorechange = floatval(optional_param( 'scorechange', 0, PARAM_TEXT));
	if ($scorechange == 0) {
		$scorechange = 1;
	}
                SloodleDebugLogger::log('DEBUG', "active object check");
	if (!is_null($sloodle->active_object)) {
                SloodleDebugLogger::log('DEBUG', "quiz has an active object");


		$sloodle->active_object->process_interactions( 'SloodleModuleAwards', 'answerquestion', $scorechange, $sloodle->user->get_user_id() );
		/*
		if ($scorechange > 0) {
		} else if ($scorechange < 0) {
			//$sloodle->active_object->process_interactions( 'SloodleModuleAwards', 'answerincorrect', 1, $sloodle->user->get_user_id() );
		}
		*/
		// TODO: Maybe we should set a side effect code here?
	} else {
                SloodleDebugLogger::log('DEBUG', "quiz has no active object");
	} 

		

    } else {
	SloodleDebugLogger::log('DEBUG', 'quiz is not notify');
    }


/// Finish attempt if requested
    if ($finishattempt) {

        // Set the attempt to be finished
        $attempt->timefinish = $timestamp;

        // Find all the questions for this attempt for which the newest
        // state is not also the newest graded state
        if ($closequestions = sloodle_get_records_select_params('question_sessions',
         "attemptid = ? AND newest != newgraded", array($attempt->uniqueid),'', 'questionid, questionid')) {

            // load all the questions
            $closequestionlist = implode(',', array_keys($closequestions));
            $params = array($quiz->id);
            $instr = '';
            $delim = '';
            foreach(array_keys($closequestions) as $cq) {
                $params[] = $cq;
                $instr .= $delim.'?';
                $delim = ',';
            }
            $sql = "SELECT q.*, i.grade AS maxgrade, i.id AS instance".
                   "  FROM {$CFG->prefix}question q,".
                   "       {$CFG->prefix}quiz_question_instances i".
                   " WHERE i.quiz = ? AND q.id = i.question".
                   "   AND q.id IN ($instr)";
            if (!$closequestions = sloodle_get_records_sql_params($sql, $params)) {
                $sloodle->response->quick_output(-10303, 'QUIZ', 'Questions missing.', FALSE);
                exit();
            }

            // Load the question type specific information
            if (!get_question_options($closequestions)) {
                $sloodle->response->quick_output(-10303, 'QUIZ', 'Could not load question options.', FALSE);
                exit();
            }

            // Restore the question sessions
            if (!$closestates = get_question_states($closequestions, $quiz, $attempt)) {
                $sloodle->response->quick_output(-701, 'QUIZ', 'Could not restore question sessions.', FALSE);
                exit();
            }

            foreach($closequestions as $key => $question) {
                $action->event = QUESTION_EVENTCLOSE;
                $action->responses = $closestates[$key]->responses;
                $action->timestamp = $closestates[$key]->timestamp;
                question_process_responses($question, $closestates[$key], $action, $quiz, $attempt);
                            save_question_session($question, $closestates[$key]);
            }
        }
        add_to_log($course->id, 'quiz', 'close attempt',
                           "review.php?attempt=$attempt->id",
                           "$quiz->id", $cm->id);
    }

/// Update the quiz attempt and the overall grade for the quiz
    if ((isset($responses) && $responses) || $finishattempt) {
        if (!sloodle_update_record('quiz_attempts', $attempt)) {
            $sloodle->response->quick_output(-701, 'QUIZ', 'Failed to save current quiz attempt.', FALSE);
            exit();
        }
        if (($attempt->attempt > 1 || $attempt->timefinish > 0) and !$attempt->preview) {
            quiz_save_best_grade($quiz);
        }
    }

/// Check access to quiz page

    // check the quiz times
    //TODO: Figure out what this does...
    if ($timestamp < $quiz->timeopen || ($quiz->timeclose and $timestamp > $quiz->timeclose)) {
        $sloodle->response->quick_output(-701, 'QUIZ', 'Quiz not available.', FALSE);
        exit();
    }

    if ($finishattempt) {
        // redirect('review.php?attempt='.$attempt->id);
        //$sloodle->response->quick_output(-701, 'QUIZ', 'Got to finishattempt - but do not yet have Sloodle code to handle it.', FALSE);
        //exit();
    }

/// Print the quiz page ////////////////////////////////////////////////////////

    if (!$isnotify) {

        $pagequestions = explode(',', $pagelist);
        $lastquestion = count($pagequestions);

        // Only output quiz data if a question has not been requetsed
        if ($limittoquestion == 0) {
            $output[] = array('quiz',$quiz->attempts,$quiz->name,$quiz->timelimit,$quiz->id,$lastquestion);
            $output[] = array('quizpages',quiz_number_of_pages($attempt->layout),$page,$pagelist);
        }

        // We will keep track of question numbers local to this quiz
        $localqnum = 0;
        /// Print all the questions
        $number = quiz_first_questionnumber($attempt->layout, $pagelist);
        foreach ($pagequestions as $i) {
            $options = quiz_get_renderoptions($quiz->review, $states[$i]);
            // Print the question
            // var_dump($questions[$i]);
            $q = $questions[$i];
            $localqnum++;
            
            if ($limittoquestion == $q->id) {
                //echo "<hr>"; print_r($q); echo "<hr>";                
 
                // Make sure the variables exist (avoids warnings!)
                if (!isset($q->single)) $q->single = 0;
                $shuffleanswers = 0;
                if (isset($q->options->shuffleanswers) && $q->options->shuffleanswers) $shuffleanswers = 1;
            
                $output[] = array(
                    'question',
                    $localqnum, //$i, // The value in $i is equal to $q->id, rather than being sequential in the quiz
                    $q->id,
                    $q->parent,
                    sloodle_clean_for_output($q->questiontext),
                    $q->defaultgrade,
                    $q->penalty,
                    $q->qtype,
                    $q->hidden,
                    $q->maxgrade,
                    $q->single,
                    $shuffleanswers,
                    0 //$deferred   // This variable doesn't seem to be mentioned anywhere else in the file
                );

                // Create an output array for our options (available answers) so that we can shuffle them later if necessary
                $outputoptions = array();
                // Go through each option
                $ops = $q->options;             
                foreach($ops as $opkey=>$op) {
                   
                   if (!is_array($op)) continue; // Ignore this if there are no options (Prevents nasty PHP notices!)
                   foreach($op as $ok=>$ov) {
                      $outputoptions[] = array(
                        'questionoption',
                        $i,
                        $ov->id,
                        $ov->question,
                        sloodle_clean_for_output($ov->answer),
                        $ov->fraction,
                        sloodle_clean_for_output($ov->feedback)
                      );
                   }
                }
                
                // Shuffle the options if necessary
                if ($shuffleanswers) shuffle($outputoptions);
                // Append our options to the main output array
                $output = array_merge($output, $outputoptions);
            }
            //print_question($questions[$i], $states[$i], $number, $quiz, $options);
            save_question_session($questions[$i], $states[$i]);
            $number += $questions[$i]->length;
        }

        $secondsleft = ($quiz->timeclose ? $quiz->timeclose : 999999999999) - time();
        //if ($isteacher) {
        //  // For teachers ignore the quiz closing time
        //  $secondsleft = 999999999999;
        //}
        // If time limit is set include floating timer.
        if ($quiz->timelimit > 0) {
            $output[] = array('seconds left',$secondsleft);
        }
    }

    $sloodle->response->set_status_code(1);
    $sloodle->response->set_status_descriptor('QUIZ');
    $sloodle->response->set_data($output);
    
    $sloodle->response->render_to_output();
    
    exit;

?>
