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
    require_once('../../init.php');
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
    $questionids = optional_param('questionids', '', PARAM_RAW);
    $finishattempt = optional_param('finishattempt', 0, PARAM_BOOL);
    $timeup = optional_param('timeup', 0, PARAM_BOOL); // True if form was submitted by timer.
    $forcenew = optional_param('forcenew', false, PARAM_BOOL); // Teacher has requested new preview

    $isnotify = ( optional_param( 'action', false, PARAM_RAW ) == 'notify' ) ;

    // Prior to Moodle 2.1 this information had to be passed in through an obscure $_POST var called $resp.
    // We didn't handle it - we just called the relevant functions that did.
    // TODO: Update the quiz to set "response" instead of making this crazy variable name.
    $quizresponse = optional_param('response', -1, PARAM_RAW);

    // Backwards compatibility for old LSL scripts that send us data the < 2.0 way:
    if ( $isnotify && ($quizresponse < 0) ) {
            $responseparam = 'resp'.$questionids.'_';
            $quizresponse = optional_param($responseparam, -1, PARAM_RAW);
    }
    // Remove the above when we no longer need to support old objects
    // ...belonging to SLOODLE 2.0.13-alpha or earlier.



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

    // Anything below Moodle 2.1 should use the old version.
    // In case we're wrong about the cut-off point,
    // ...we'll also check for the existence of get_question_states, 
    // ...which went away in the new quiz engine.
    if ( ( $CFG->version < 2011070100 ) && ( function_exists('get_question_states') ) ) {
        require_once(SLOODLE_DIRROOT.'/mod/quiz-1.0/'.'linker_moodle_2_0_down.php');
    } else {
        require_once(SLOODLE_DIRROOT.'/mod/quiz-1.0/'.'linker_moodle_2_1_up.php');
    }

?>
