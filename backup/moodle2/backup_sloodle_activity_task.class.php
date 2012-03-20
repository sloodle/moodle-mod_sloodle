<?php
require_once($CFG->dirroot . '/mod/sloodle/backup/moodle2/backup_sloodle_stepslib.php'); 
require_once($CFG->dirroot . '/mod/sloodle/backup/moodle2/backup_sloodle_settingslib.php'); 
 
/**
 * sloodle backup task that provides all the settings and steps to perform one
 * complete backup of the activity
 */
class backup_sloodle_activity_task extends backup_activity_task {
 
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
        // Choice only has one structure step
        $this->add_step(new backup_sloodle_activity_structure_step('sloodle_structure', 'sloodle.xml'));
    }
 
    /**
     * Code the transformations to perform in the activity in
     * order to get transportable (encoded) links
     */
    static public function encode_content_links($content) {
        return $content;
    }

}
