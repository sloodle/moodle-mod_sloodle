<?php
/**
 * Structure step to restore one choice activity
*/
class restore_sloodle_activity_structure_step extends restore_activity_structure_step {
       
    protected function define_structure() {
                    
        $paths = array();
        $userinfo = $this->get_setting_value('userinfo');

        $paths[] = new restore_path_element('sloodle', '/activity/sloodle');

        $paths[] = new restore_path_element('sloodle_controller', '/activity/sloodle/controllers/controller');

        $paths[] = new restore_path_element('sloodle_presenter', '/activity/sloodle/presenters/presenter');
        $paths[] = new restore_path_element('sloodle_presenter_entry', '/activity/sloodle/presenters/presenter_entry');

        $paths[] = new restore_path_element('sloodle_distributor', '/activity/sloodle/distributors/distributor');
        $paths[] = new restore_path_element('sloodle_distributor_entry', '/activity/sloodle/distributors/distributor_entry');

        $paths[] = new restore_path_element('sloodle_layout', '/activity/sloodle/layouts/layout');
        $paths[] = new restore_path_element('sloodle_layout_entry', '/activity/sloodle/layouts/layout/layout_entries/layout_entry');
        $paths[] = new restore_path_element('sloodle_layout_entry_config', '/activity/sloodle/layouts/layout/layout_entries/layout_entry/layout_entry_configs/layout_entry_config');

        /*
        if ($userinfo) {
            $paths[] = new restore_path_element('choice_answer', '/activity/choice/answers/answer');
        }
        */
                                                                                      
        // Return the paths wrapped into standard activity structure
        return $this->prepare_activity_structure($paths);

    }

    protected function process_sloodle($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;
        $data->course = $this->get_courseid();

        $data->timecreated = $this->apply_date_offset($data->timecreated);
        $data->timemodified = $this->apply_date_offset($data->timemodified);

        // insert the choice record
        $newitemid = $DB->insert_record('sloodle', $data);
        // immediately after inserting "activity" record, call this
        $this->apply_activity_instance($newitemid);

    }

    protected function process_sloodle_controller($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_controller', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_controller', $oldid, $newitemid);

    }

    protected function process_sloodle_presenter($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_presenter', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_presenter', $oldid, $newitemid);

    }

    protected function process_sloodle_presenter_entry($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_presenter_entry', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_presenter', $oldid, $newitemid);

    }

    protected function process_sloodle_distributor($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_distributor', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_distributor', $oldid, $newitemid);

    }

    protected function process_sloodle_distributor_entry($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_distributor_entry', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_distributor', $oldid, $newitemid);

    }

    protected function process_sloodle_layout($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->course = $this->get_courseid();
        //$data->controllerid = $this->get_moduleid();
        $data->controllerid = $this->get_new_parentid('sloodle'); // CHECK: Probably need to look for the course module ID instead
        $data->timeupdated = $this->apply_date_offset($data->timeupdated);

        $newitemid = $DB->insert_record('sloodle_layout', $data);
        $this->set_mapping('sloodle_layout', $oldid, $newitemid);

    }

    protected function process_sloodle_layout_entry($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->layout = $this->get_new_parentid('sloodle_layout');

        $newitemid = $DB->insert_record('sloodle_layout_entry', $data);
        $this->set_mapping('sloodle_layout_entry', $oldid, $newitemid);

    }

    protected function process_sloodle_layout_entry_config($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->layout_entry = $this->get_new_parentid('sloodle_layout_entry');

        $newitemid = $DB->insert_record('sloodle_layout_entry', $data);
        $this->set_mapping('sloodle_layout_entry_config', $oldid, $newitemid);

    }

    protected function after_execute() {
        // Add choice related files, no need to match by itemname (just internally handled context)
        //$this->add_related_files('mod_choice', 'intro', null);
    }

}
