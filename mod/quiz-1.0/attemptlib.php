<?php
/**
 * SLOODLE version of:
 * Back-end code for handling data about quizzes and the current user's attempt.
 *
 * The original Moodle 2.2 quiz won't let us pass our own results data in
 * ... except in the shape it expects to get it from its self-generated HTML form.
 * (It probably should, because the way it is it must be hard to unit-test.)
 *
 * We want to use different parameters than the ones used by the HTML version.
 *
 * Its internal quba class will let us pass those in, but we can't access it from here because it's protected.
 * So we sub-class quiz_attempt and create function that can accept data in the form we want to give it.
 *
 * @package    mod
 * @subpackage sloodle
 * @copyright  2008 onwards Tim Hunt (original code) modified for SLOODLE by Edmund Edgar 2012
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

class sloodle_quiz_attempt extends quiz_attempt {

    // create and create_helper are duplicated here to persuade attempt::create to give us a sloodle_quiz_attempt
    // They are otherwise unchanged from the original quiz_attempt.

    /**
     * Static function to create a new quiz_attempt object given an attemptid.
     *
     * @param int $attemptid the attempt id.
     * @return quiz_attempt the new quiz_attempt object
     */
    public static function create($attemptid) {
        return self::create_helper(array('id' => $attemptid));
    }

    /**
     * Used by {create()} and {create_from_usage_id()}.
     * @param array $conditions passed to $DB->get_record('quiz_attempts', $conditions).
     */
    protected static function create_helper($conditions) {
        global $DB;

        $attempt = $DB->get_record('quiz_attempts', $conditions, '*', MUST_EXIST);
        $quiz = quiz_access_manager::load_quiz_and_settings($attempt->quiz);
        $course = $DB->get_record('course', array('id' => $quiz->course), '*', MUST_EXIST);
        $cm = get_coursemodule_from_instance('quiz', $quiz->id, $course->id, false, MUST_EXIST);

        // Update quiz with override information
        $quiz = quiz_update_effective_access($quiz, $attempt->userid);

        return new sloodle_quiz_attempt($attempt, $quiz, $cm, $course);
    }

    /**
     * Process all the actions that were submitted as part of the current request.
     * Based on process_all_actions(), but targetted at a particular slot.
     *
     * @param int $timestamp the timestamp that should be stored as the modifed
     * time in the database for these actions. If null, will use the current time.
     */
    public function process_all_actions_for_slot($slot, $submitteddata, $timestamp) {
        global $DB;

        // Moodle's process_all_actions originally did:
        // $this->quba->process_all_actions($timestamp, $postdata);
        // ...extracted submitteddata, figured out which slots it wanted to deal with and for each one called:
        //$DB->set_debug(true);
        $this->quba->process_action($slot, $submitteddata, $timestamp);

        question_engine::save_questions_usage_by_activity($this->quba);

        $this->attempt->timemodified = $timestamp;
        if ($this->attempt->timefinish) {
            $this->attempt->sumgrades = $this->quba->get_total_mark();
        }
        $DB->update_record('quiz_attempts', $this->attempt);

        if (!$this->is_preview() && $this->attempt->timefinish) {
            quiz_save_best_grade($this->get_quiz(), $this->get_userid());
        }
    }

}
