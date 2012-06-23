<?php
/**
 * Structure step to restore one choice activity
*/
class restore_sloodle_activity_structure_step extends restore_activity_structure_step {
       
    protected function define_structure() {
                    
        $paths = array();
        $userinfo = $this->get_setting_value('userinfo');

        $paths[] = new restore_path_element('sloodle', '/activity/sloodle');

        $paths[] = new restore_path_element('sloodle_currency_type', '/activity/sloodle/currency_types/currency_type');
        if ($userinfo) {
            $paths[] = new restore_path_element('sloodle_user', '/activity/sloodle/users/user');
        }

        $paths[] = new restore_path_element('sloodle_controller', '/activity/sloodle/controllers/controller');

        $paths[] = new restore_path_element('sloodle_tracker', '/activity/sloodle/trackers/tracker');

        $paths[] = new restore_path_element('sloodle_presenter', '/activity/sloodle/presenters/presenter');
        $paths[] = new restore_path_element('sloodle_presenter_entry', '/activity/sloodle/presenters/presenter/presenter_entries/presenter_entry');

        $paths[] = new restore_path_element('sloodle_distributor', '/activity/sloodle/distributors/distributor');
        $paths[] = new restore_path_element('sloodle_distributor_entry', '/activity/sloodle/distributor/distributors/distributor_entries/distributor_entry');

        $paths[] = new restore_path_element('sloodle_layout', '/activity/sloodle/controllers/controller/layouts/layout');
        $paths[] = new restore_path_element('sloodle_layout_entry', '/activity/sloodle/controllers/controller/layouts/layout/layout_entries/layout_entry');
        $paths[] = new restore_path_element('sloodle_layout_entry_config', '/activity/sloodle/controllers/controller/layouts/layout/layout_entries/layout_entry/layout_entry_configs/layout_entry_config');

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

    protected function process_sloodle_tracker($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->sloodleid = $this->get_new_parentid('sloodle'); 

        $newitemid = $DB->insert_record('sloodle_tracker', $data);
        // immediately after inserting "activity" record, call this

        $this->set_mapping('sloodle_tracker', $oldid, $newitemid);

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

        $this->set_mapping('sloodle_presenter_entry', $oldid, $newitemid);

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

        $this->set_mapping('sloodle_distributor_entry', $oldid, $newitemid);

    }

    protected function process_sloodle_layout($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $data->course = $this->get_courseid();
        $data->controllerid = $this->task->get_moduleid();
        //$data->controllerid = $this->get_moduleid();
        //var_dump($this);
        //exit;
        //$data->controllerid = $this->get_new_parentid('sloodle'); // CHECK: Probably need to look for the course module ID instead
        $data->timeupdated = $this->apply_date_offset($data->timeupdated);

        $newitemid = $DB->insert_record('sloodle_layout', $data);
        $this->set_mapping('sloodle_layout', $oldid, $newitemid);

    }

    protected function process_sloodle_user($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $newitemid = 0;

        // If the avatar is already there, map the record ID to the existing user.
        if ( $existing = $DB->get_record('sloodle_users', array( 'uuid' => $data->uuid ) ) ) {
            $newitemid = $existing->id;
        } else {
            // If the Moodle user is already there, create an avatar for them.
            $data->userid = $this->get_mappingid('user', $data->userid);
            // Only import avatars if we know which user they are.
            if ($data->userid > 0) {
                $newitemid = $DB->insert_record('sloodle_users', $data);
            }
        }

        $this->set_mapping('sloodle_user', $oldid, $newitemid);

    }

    protected function process_sloodle_currency_type($data) {

        global $DB;

        $data = (object)$data;
        $oldid = $data->id;

        $newitemid = 0;

        // If the avatar is already there, map the record ID to the existing user.
        if ( $existing = $DB->get_record('sloodle_currency_types', array( 'name' => $data->name) ) ) {
            $newitemid = $existing->id;
        } else {
            $newitemid = $DB->insert_record('sloodle_currency_types', $data);
        }

        $this->set_mapping('sloodle_currency_types', $oldid, $newitemid);

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

        $newitemid = $DB->insert_record('sloodle_layout_entry_config', $data);
        $this->set_mapping('sloodle_layout_entry_config', $oldid, $newitemid);

    }

    protected function after_execute() {

        global $DB;

        // Add sloodle related files, no need to match by itemname (just internally handled context)
        $this->add_related_files('mod_sloodle', 'presenter', null);

        /*
        Presenter files have the context ID in the path.
        This needs to be replaced with the new context ID.
        We'll get the files directly from the files table and fix any context IDs.
        This is almost definitely the wrong way to do this, but I'm buggered if I know what the right one is.
        */

        $contextid = $this->task->get_contextid();

        $files = $DB->get_records('files', array('contextid'=>$contextid, 'component'=>'mod_sloodle', 'filearea'=>'presenter'));

        if (count($files) > 0) {

            foreach($files as $fr) {

                $fs = get_file_storage();

                if (!preg_match('#^(/)\d+(/.*)$#', $fr->filepath, $matches)) {
                    continue;
                }

                $fr->filepath = $matches[1].$contextid.$matches[2];

                $fr->pathnamehash = $fs->get_pathname_hash($fr->contextid, $fr->component, $fr->filearea, $fr->itemid, $fr->filepath, $fr->filename);
                $DB->update_record('files', $fr);

            }

        }

    }

}
