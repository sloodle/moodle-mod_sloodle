<?php


/**
 * Define the complete sloodle structure for backup, with file and id annotations
 */     
class backup_sloodle_activity_structure_step extends backup_activity_structure_step {
     
    protected function define_structure() {
 
        // To know if we are including userinfo
        $userinfo = $this->get_setting_value('userinfo');

        // Define each element separated
        $sloodle = new backup_nested_element('sloodle', 
            array('id'),  
            array(
                'course',
                'type',
                'name',
                'intro',
                'introformat',
                'timecreated',
                'timemodified'
            )
        );

        $trackers = new backup_nested_element('trackers');
        $tracker = new backup_nested_element('tracker',
            array('id'),
            array(
                'sloodleid',
            )
        );


        $distributors = new backup_nested_element('distributors');
        $distributor = new backup_nested_element('distributor',
            array('id'),
            array(
                'sloodleid',
                'channel',
                'timeupdated'
            )
        );

        $presenters = new backup_nested_element('presenters');
        $presenter = new backup_nested_element('presenter',
            array('id'),
            array(
                'sloodleid',
                'framewidth',
                'frameheight'
            )
        );

        $presenterentries = new backup_nested_element('presenter_entries');
        $presenterentry = new backup_nested_element('presenter_entry',
            array('id'),
            array(
                'sloodleid',
                'name',
                'source',
                'type', 
                'ordering'
            )
        );

        $controllers = new backup_nested_element('controllers');
        $controller = new backup_nested_element('controller',
            array('id'),
            array(
                'sloodleid',
                'enabled',
                'password'
            )
        );

        $layouts = new backup_nested_element('layouts');
        $layout = new backup_nested_element('layout',
            array('id'),
            array(
                   'course',
                   'name',
                   'timeupdated',
                   'controllerid'
            )
        );

        $layoutentries = new backup_nested_element('layout_entries');
        $layoutentry = new backup_nested_element('layout_entry',
            array('id'),
            array(
                'layout',
                'name',
                'position',
                'rotation'
            )
        );

        $layoutentryconfigs = new backup_nested_element('layout_entry_configs');
        $layoutentryconfig = new backup_nested_element('layout_entry_config',
            array('id'),
            array(
                'layout_entry',
                'name',
                'value'   
            )
        );        

        $sloodlecurrencytypes = new backup_nested_element('currency_types');
        $sloodlecurrencytype = new backup_nested_element('currency_type',
            array('id'),
            array(
                'name',
                'timemodified',
                'imageurl',
                'displayorder'
            )
        );

        $sloodleusers = new backup_nested_element('users');
        $sloodleuser = new backup_nested_element('user',
            array('id'),
            array(
                'userid',
                'uuid',
                'avname',
                'profilepic',
                'lastactive'
            )
        );

        $sloodle->add_child($controllers);
        $controllers->add_child($controller);
        $controller->add_child($layouts);
        $layouts->add_child($layout);
        $layout->add_child($layoutentries);
        $layoutentries->add_child($layoutentry);

        $layoutentry->add_child($layoutentryconfigs);
        $layoutentryconfigs->add_child($layoutentryconfig);

        $distributors->add_child($distributor);
        $sloodle->add_child($distributors);

        $trackers->add_child($tracker);
        $sloodle->add_child($trackers);

        $presenterentries->add_child($presenterentry);
        $presenter->add_child($presenterentries);
        $presenters->add_child($presenter);
        $sloodle->add_child($presenters);


        if ($userinfo) {
            $sloodleusers->add_child($sloodleuser);
            $sloodle->add_child($sloodleusers);
        }

        $sloodlecurrencytypes->add_child($sloodlecurrencytype);
        $sloodle->add_child($sloodlecurrencytypes);

        // Build the tree
 
        // Define sources
        $sloodle->set_source_table('sloodle', array('id' => backup::VAR_ACTIVITYID));

        /*
        Neither of these tables link directly to a course or controller.
        However, they may be referenced by other things that are in a controller, so we can't leave them out.
        There will need to be some restore code in the to do something sensible with these on load.
        */
        $sloodleuser->set_source_table('sloodle_users', array());
        $sloodlecurrencytype->set_source_table('sloodle_currency_types', array());
        //$sloodleuser->set_source_sql("SELECT * FROM {sloodle_users} ORDER BY id", array());


        if ($userinfo) {
        }
        $distributor->set_source_table('sloodle_distributor', array('sloodleid' => backup::VAR_ACTIVITYID));
        $tracker->set_source_table('sloodle_tracker', array('sloodleid' => backup::VAR_ACTIVITYID));
        $presenter->set_source_table('sloodle_presenter', array('sloodleid' => backup::VAR_ACTIVITYID));
        $presenterentry->set_source_table('sloodle_presenter_entry', array('sloodleid' => backup::VAR_ACTIVITYID));
        $controller->set_source_table('sloodle_controller', array('sloodleid' => backup::VAR_ACTIVITYID));
        $layout->set_source_table('sloodle_layout', array('controllerid' => backup::VAR_MODID));
        $layoutentry->set_source_table('sloodle_layout_entry', array('layout' => backup::VAR_PARENTID));
        $layoutentryconfig->set_source_table('sloodle_layout_entry_config', array('layout_entry' => backup::VAR_PARENTID));

        /*
        $layout->set_source_sql(
            'SELECT * FROM {sloodle_layout} WHERE controllerid = ?',
            array(backup::VAR_MODID)
        );
        */

        // Define id annotations
        $sloodleuser->annotate_ids('sloodle_user', 'userid');
 
        // Define file annotations
        //mod_sloodle | presenter |      8 
        $presenter->annotate_files('mod_sloodle', 'presenter', null);
 
        // Return the root element (sloodle), wrapped into standard activity structure
        return $this->prepare_activity_structure($sloodle);
 
    }

}
