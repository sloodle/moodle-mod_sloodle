<?php
require_once($CFG->dirroot . '/mod/sloodle/backup/moodle2/restore_sloodle_stepslib.php');
/**
 * sloodle restore task that provides all the settings and steps to perform one
* complete restore of the activity
*/
class restore_sloodle_activity_task extends restore_activity_task {

    /**
    * Define (add) particular settings this activity can have
    */
    protected function define_my_settings() {
    // No particular settings for this activity
    }

    /**
    * Define (add) particular steps this activity can have
    */
    protected function define_my_steps() {
        // Sloodle only has one structure step
        $this->add_step(new restore_sloodle_activity_structure_step('sloodle_structure', 'sloodle.xml'));
    }

    /**
    * Define the contents in the activity that must be
    * processed by the link decoder
    */
    static public function define_decode_contents() {
        $contents = array();

        //$contents[] = new restore_decode_content('sloodle', array('intro'), 'sloodle');

        return $contents;
    }

    /**
    * Define the decoding rules for links belonging
    * to the activity to be executed by the link decoder
    */
    static public function define_decode_rules() {
        $rules = array();

        /*
        $rules[] = new restore_decode_rule('CHOICEVIEWBYID', '/mod/choice/view.php?id=$1', 'course_module');
        $rules[] = new restore_decode_rule('CHOICEINDEX', '/mod/choice/index.php?id=$1', 'course');
        */

        return $rules;

    }

    /**
    * Define the restore log rules that will be applied
    * by the {@link restore_logs_processor} when restoring
    * choice logs. It must return one array
    * of {@link restore_log_rule} objects
    */
    static public function define_restore_log_rules() {

        $rules = array();

        /*
        $rules[] = new restore_log_rule('choice', 'add', 'view.php?id={course_module}', '{choice}');
        $rules[] = new restore_log_rule('choice', 'update', 'view.php?id={course_module}', '{choice}');
        $rules[] = new restore_log_rule('choice', 'view', 'view.php?id={course_module}', '{choice}');
        $rules[] = new restore_log_rule('choice', 'choose', 'view.php?id={course_module}', '{choice}');
        $rules[] = new restore_log_rule('choice', 'choose again', 'view.php?id={course_module}', '{choice}');
        $rules[] = new restore_log_rule('choice', 'report', 'report.php?id={course_module}', '{choice}');
        */

        return $rules;
    }

    /**
    * Define the restore log rules that will be applied
    * by the {@link restore_logs_processor} when restoring
    * course logs. It must return one array
    * of {@link restore_log_rule} objects
    *
    * Note this rules are applied when restoring course logs
    * by the restore final task, but are defined here at
    * activity level. All them are rules not linked to any module instance (cmid = 0)
    */
    static public function define_restore_log_rules_for_course() {
        $rules = array();

        /*
        // Fix old wrong uses (missing extension)
        $rules[] = new restore_log_rule('choice', 'view all', 'index?id={course}', null,
        null, null, 'index.php?id={course}');
        $rules[] = new restore_log_rule('choice', 'view all', 'index.php?id={course}', null);
        */

        return $rules;
    }
 
    public function after_restore() {
        global $DB;
        print "in after_restore";

        // Get a list of inserted layout entries

        /*
        // Get this repeatactivity
        $cm = $DB->get_record('repeatactivity', array('id' => $this->get_activityid()));

        // get mapping to determine new item id.
        $mapcm = restore_structure_step::get_mapping('course_module', $repeat->originalcmid);

        if ($mapcm && $mapcm->newitemid !== null) {
            // if new item id available, then update originalcmid with this value
            $DB->update_record('repeatactivity',
                    (object)array('id'=>$repeat->id, 'originalcmid'=>$mapcm->newitemid));
        } else {
            $this->get_logger()->process('Repeat activity ' . $repeat->id . ' (' .
                    $repeat->name . '): skipping, cannot find target activity ' . $repeat->originalcmid,
                    backup::LOG_WARNING);
            // Get cm and section
            $cm = $DB->get_record('course_modules', array('id' => $this->get_moduleid()),
                    '*', MUST_EXIST);
            $section = $DB->get_record('course_sections', array('id' => $cm->section),
                    '*', MUST_EXIST);
            // Delete records
            $DB->delete_records('repeatactivity', array('id' => $cm->instance));
            $DB->delete_records('course_modules', array('id' => $cm->id));
            // Update section; add commas to each end and do replace...
            $newsequence = str_replace(',' . $cm->id . ',', ',',
                ',' . $section->sequence . ',');
            // ...then remove commas from each end
            $newsequence = substr($newsequence, 1, strlen($newsequence)-2);
            $DB->set_field('course_sections', 'sequence', $newsequence,
                    array('id' => $section->id));
            rebuild_course_cache($cm->course, true);
        }
        */
    }


}
