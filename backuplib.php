<?php

    /**
    * This script contains all the functionality allowing SLOODLE data in Moodle to be backed-up.
    * The bulk of visible SLOODLE data resides in module instances.
    * Each module has a "primary" record in the "sloodle" database table.
    * However, there are several sub-types of modules, most of which have one or more "secondary" records elsewhere in the database.
    * This file directly backs-up the primary data, but then relies on individual module code (in "lib/modules") to backup secondary data.
    *
    * The current 'active objects' (i.e. objects which are authorised to access the course when the backup is initiated) will NOT currently be backed-up.
    * This is for security, since in the event that a course is being transfered it is not desirable to allow existing objects access to the new course.
    * An option may be added in future to allow object authorisations to be transferred in a safe way.
    *
    * NOTE: despite the above restriction, any objects relying on a prim password will still have access, since the prim password does not change during backup.
    *
    * @package sloodle
    * @todo Implement backup of site data, including avatar registrations
    * @todo Implement backup fo course data, including autoreg/enrol settings, and object layouts/configurations
    *
    */
    
    require_once($CFG->dirroot.'/mod/sloodle/sl_config.php');
    require_once(SLOODLE_LIBROOT.'/modules.php');
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    /**
    * Backs-up multiple modules of SLOODLE data.
    * @param $bf File handle for writing backup data to.
    * @param $preferences Contains the options controlling this backup.
    * @return bool True if successful or false on failure.
    */
    function sloodle_backup_mods($bf, $preferences)
    {
        $status = true;
        
        // Backup course-specific data
        //...
        
        // Go through each SLOODLE module in the specified course.
        $mods = sloodle_get_records('sloodle', 'course', $preferences->backup_course, 'id');
        if ($mods === false) return false;
        foreach ($mods as $mod) {
            // Is this module due for backup?
            if (backup_mod_selected($preferences, 'sloodle', $mod->id)) {
                // Backup this particular module
                if (!sloodle_backup_one_mod($bf, $preferences, $mod)) $status = false;
            }
        }
        
        return $status;
    }
 
    /**
    * Backs-up one instance of a SLOODLE module.
    * @param $bf Handle to the file to which backup data should be written.
    * @param $preferences Structure defining preferences which govern the backup.
    * @param object|int $mod If an object, then it is a record from the 'sloodle' db table. If it is a number, then it is the ID of a record in the 'sloodle' db table.
    * @return bool True if successful, or false if not.
    */
    function sloodle_backup_one_mod($bf, $preferences, $mod)
    {
        // Load a 'sloodle' record if necessary
        if (is_numeric($mod)) {
            $mod = sloodle_get_record('sloodle', 'id', $mod);
            if ($mod === false) return false;
        }
        
        $status = true;
        
        // Attempt to load the course module record from the database
        $cm = get_coursemodule_from_instance('sloodle', $mod->id);
        if ($cm === false) return false;
        
        // Attempt to get a SloodleModule object for this module sub-type
        $dummysession = new SloodleSession(false); // We need to provide this to keep the module happy!
        $moduleobj = sloodle_load_module($mod->type, $dummysession, $cm->id);
        if ($moduleobj == false) return false;
        
        // Start an element for this module instance, and backup the primary table data
        fwrite($bf, start_tag('MOD', 3, true));
        
        fwrite($bf, full_tag('ID', 4, false, $mod->id));        // Instance ID of this SLOODLE module
        fwrite($bf, full_tag('MODTYPE', 4, false, 'sloodle'));  // Main type of module (always 'sloodle' in this case)
        fwrite($bf, full_tag('SUBTYPE', 4, false, $mod->type));       // Sub-type of module (e.g. 'controller' or 'presenter')
        fwrite($bf, full_tag('NAME', 4, false, $mod->name));
        fwrite($bf, full_tag('INTRO', 4, false, $mod->intro));
        fwrite($bf, full_tag('TIMECREATED', 4, false, $mod->timecreated));
        fwrite($bf, full_tag('TIMEMODIFIED', 4, false, $mod->timemodified));
        
        // Backup any secondary data
        fwrite($bf, start_tag('SECONDARYDATA', 4, true));
        if (!$moduleobj->backup($bf, backup_userdata_selected($preferences, 'sloodle', $mod->id))) $status = false;
        fwrite($bf, end_tag('SECONDARYDATA', 4, true));
        
        // Finish off
        if (!fwrite($bf, end_tag('MOD', 3, true))) $status = false;
        
        return $status;
    }


    /**
    * Checks the specified course (or specific instances therein) for SLOODLE data that can be backed-up.
    * @param $course Identifies the Moodle course to be backed-up.
    * @param bool $user_data Indicates whether or not user data is to be included in the check.
    * @param $backup_unique_code A unique code identifying this backup.
    * @param array $instances Optional. An array of instances of SLOODLE modules which should be checked.
    * @return Array of information that can be backed up.
    */
    function sloodle_check_backup_mods($course, $user_data, $backup_unique_code, $instances = null)
    {
        // Has information about specified instances been requested?
        if (!empty($instances) && is_array($instances) && count($instances)) {
            // Yes - construct an array of information about those instances.
            $info = array();
            foreach ($instances as $id => $instance) {
                $info += sloodle_check_backup_mods_instances($instance, $backup_unique_code);
            }
            return $info;
        }
        
        // We're getting backup information about the whole course.
        
        // Return structural information about the whole course
        $info[0][0] = get_string('modulenameplural', 'sloodle');
        $ids = sloodle_ids($course);
        if ($ids) {
            $info[0][1] = count($ids);
        } else {
            $info[0][1] = 0;
        }
        
        // Now, if requested, the user_data
        if ($user_data) {
            $info[1][0] = get_string('userdata', 'sloodle');
            $info[1][1] = 0;
            // Go through each SLOODLE module in the course
            if (is_array($ids)) {
                foreach ($ids as $id) {
                    // Attempt to load a module object for this instance
                    $module = sloodle_quick_load_module_from_instance($id[0]);
                    if ($module) $info[1][1] += $module->get_user_data_count();
                }
            }
        }
        
        return $info;
    }
    
    /**
    * Check the backup infomation for a specific instance of the SLOODLE module.
    * @param $instance An object representing a record from the 'sloodle' table.
    * @param $backup_unique_code A unique code for this backup
    * @return array Backup information
    */
    function sloodle_check_backup_mods_instances($instance, $backup_unique_code) {
        // Add the course data
        $info[$instance->id.'0'][0] = '<b>'.$instance->name.'</b>';
        $info[$instance->id.'0'][1] = '';
        
        // Now, if requested, the user_data
        if (!empty($instance->userdata)) {
            $info[$instance->id.'1'][0] = get_string('userdata', 'sloodle');
            $info[$instance->id.'1'][1] = 0;
        
            // Attempt to load the module data for this instance
            $module = sloodle_quick_load_module_from_instance($instance->id);
            if ($module) {
                $info[$instance->id.'1'][0] = $module->get_user_data_name();
                $info[$instance->id.'1'][1] = $module->get_user_data_count();
            }
        }
        return $info;
    }
    
    /**
    * Return the given content, encoded to support interactivities linking.
    * This is necessary so that any links between activities remain intact after backup, since the instance IDs change.
    * Function is called automatically by Moodle backup functionality.
    * @param string $content The content to be encoded.
    * @param $preferences An object defining preferences in this encoding.
    * @return string The content with encoded links.
    */
    function sloodle_encode_content_links ($content,$preferences)
    {
        global $CFG;
        // Define the base link.
        $base = preg_quote($CFG->wwwroot,"/");

        // Link to the list of SLOODLE module instances
        $buscar = "/(".$base."\/mod\/sloodle\/index.php\?id\=)([0-9]+)/";
        $result = preg_replace($buscar,'$@SLOODLEINDEX*$2@$', $content);
        
        // Link to an implicit module view
        $buscar = "/(".$base."\/mod\/sloodle\/view.php\?id\=)([0-9]+)/";
        $result = preg_replace($buscar,'$@SLOODLEVIEWBYID*$2@$', $result);
        
        // Link to an explicit module view
        $buscar = "/(".$base."\/mod\/sloodle\/view.php\?_type=module&id\=)([0-9]+)/";
        $result = preg_replace($buscar,'$@SLOODLEVIEWBYID*$2@$', $result);
        
        // Link to an explicit module view with HTML entity for &
        $buscar = "/(".$base."\/mod\/sloodle\/view.php\?_type=module&amp;id\=)([0-9]+)/";
        $result = preg_replace($buscar,'$@SLOODLEVIEWBYID*$2@$', $result);
        
        // To pass through any view type, use the following line:
        // $buscar = "/(".$base."\/mod\/sloodle\/view.php\?_type=[a-zA-Z0-9.-]+&amp;id\=)([0-9]+)/";
        
        // It is not known whether Moodle provides the ability to encode for the following view scripts in SLOODLE:
        // - view_course.php
        // - view.php?_type=course   (course settings... same as view_course.php)
        // - view_layout.php

        return $result;
    }

    // INTERNAL FUNCTIONS. BASED IN THE MOD STRUCTURE

    /**
    * Gets an array of SLOODLE module instance IDs.
    * (Corresponding to the 'id' field of the 'sloodle' db table.)
    * @param int $course ID number of the course get the instances from
    * @return array An array of instance IDs of SLOODLE modules.
    */
    function sloodle_ids($course)
    {
        global $CFG;
        return sloodle_get_records_sql_params("
            SELECT s.id, s.course
            FROM {$CFG->prefix}sloodle s
            WHERE s.course = ?
        ", array($course));
    }
?>
