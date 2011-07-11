<?php
    /**
    * This script contains all the functionality allowing SLOODLE data in Moodle to be restored from a backup.
    *
    * @package sloodle
    *
    */
    
    require_once($CFG->dirroot.'/mod/sloodle/sl_config.php');
    require_once(SLOODLE_LIBROOT.'/modules.php');
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    /**
    * Restore everything from the given backup.
    */
    function sloodle_restore_mods($mod, $restore)
    {

        global $CFG;

        $status = true;

        //Get record from backup_ids
        $data = backup_getid($restore->backup_unique_code,$mod->modtype,$mod->id);

        if ($data) {
            // Get the XML backup data as an array
            $info = $data->info;

            // Build our SLOODLE DB record
            $sloodle = new object();
            $sloodle->course = $restore->course_id;
            $sloodle->type = backup_todb($info['MOD']['#']['SUBTYPE']['0']['#']);
            $sloodle->name = backup_todb($info['MOD']['#']['NAME']['0']['#']);
            $sloodle->intro = backup_todb($info['MOD']['#']['INTRO']['0']['#']);
            $sloodle->timecreated = backup_todb($info['MOD']['#']['TIMECREATED']['0']['#']);
            $sloodle->timemodified = backup_todb($info['MOD']['#']['TIMEMODIFIED']['0']['#']);

            $newid = sloodle_insert_record("sloodle", $sloodle);
            
            // Inform the user what we are restoring
            if (!defined('RESTORE_SILENTLY')) {
                echo "<li>".get_string("modulename", "sloodle")." \"".format_string(stripslashes($sloodle->name),true)."\"</li>";
            }
            backup_flush(300);

            if ($newid) {
                // We have the newid, update backup_ids
                backup_putid($restore->backup_unique_code, $mod->modtype, $mod->id, $newid);
                
                // Should we restore userdata?
                $includeuserdata = restore_userdata_selected($restore, 'sloodle', $mod->id);
                
                // Attempt to get a SloodleModule object for this module sub-type
                $dummysession = new SloodleSession(false); // We need to provide this to keep the module happy!
                $moduleobj = sloodle_load_module($sloodle->type, $dummysession);
                if ($moduleobj != false) {
                    // Attempt to restore this module's secondary data
                    if (!$moduleobj->restore($newid, $info['MOD']['#']['SECONDARYDATA']['0']['#'], $includeuserdata)) $status = false;
                } else {
                    echo "<li>Failed to fully restore SLOODLE module type {$sloodle->type}. This type may not be available on your installation.</li>";
                }
                
            } else {
                $status = false;
            }
        } else {
            $status = false;
        }

        return $status;
    }

    /**
    * Return content decoded to support interactivities linking. Every module
    * should have its own. They are called automatically from
    * sloodle_decode_content_links_caller() function in each module
    * in the restore process.
    * @todo This probably needs to be expanded to account for non-standard view URLs (notably those starting with parameter "_type")
    */
    function sloodle_decode_content_links ($content,$restore) {
            
        global $CFG;
            
        $result = $content;
                
        //Link to the list of chats
                
        $searchstring='/\$@(SLOODLEINDEX)\*([0-9]+)@\$/';
        //We look for it
        preg_match_all($searchstring,$content,$foundset);
        //If found, then we are going to look for its new id (in backup tables)
        if ($foundset[0]) {
            //print_object($foundset);                                     //Debug
            //Iterate over foundset[2]. They are the old_ids
            foreach($foundset[2] as $old_id) {
                //We get the needed variables here (course id)
                $rec = backup_getid($restore->backup_unique_code,"course",$old_id);
                //Personalize the searchstring
                $searchstring='/\$@(SLOODLEINDEX)\*('.$old_id.')@\$/';
                //If it is a link to this course, update the link to its new location
                if($rec->new_id) {
                    //Now replace it
                    $result= preg_replace($searchstring,$CFG->wwwroot.'/mod/sloodle/index.php?id='.$rec->new_id,$result);
                } else { 
                    //It's a foreign link so leave it as original
                    $result= preg_replace($searchstring,$restore->original_wwwroot.'/mod/chat/index.php?id='.$old_id,$result);
                }
            }
        }

        //Link to chat view by moduleid

        $searchstring='/\$@(SLOODLEVIEWBYID)\*([0-9]+)@\$/';
        //We look for it
        preg_match_all($searchstring,$result,$foundset);
        //If found, then we are going to look for its new id (in backup tables)
        if ($foundset[0]) {
            //print_object($foundset);                                     //Debug
            //Iterate over foundset[2]. They are the old_ids
            foreach($foundset[2] as $old_id) {
                //We get the needed variables here (course_modules id)
                $rec = backup_getid($restore->backup_unique_code,"course_modules",$old_id);
                //Personalize the searchstring
                $searchstring='/\$@(SLOODLEVIEWBYID)\*('.$old_id.')@\$/';
                //If it is a link to this course, update the link to its new location
                if($rec->new_id) {
                    //Now replace it
                    $result= preg_replace($searchstring,$CFG->wwwroot.'/mod/sloodle/view.php?id='.$rec->new_id,$result);
                } else {
                    //It's a foreign link so leave it as original
                    $result= preg_replace($searchstring,$restore->original_wwwroot.'/mod/sloodle/view.php?id='.$old_id,$result);
                }
            }
        }

        return $result;
    }

    
    /**
    * This function makes all the necessary calls to xxxx_decode_content_links()
    * function in each module, passing them the desired contents to be decoded
    * from backup format to destination site/course in order to mantain inter-activities
    * working in the backup/restore process. It's called from restore_decode_content_links()
    * function in restore process
    */
    function sloodle_decode_content_links_caller($restore)
    {
        global $CFG;
        $status = true;
        
        $sloodles = sloodle_get_records_sql("
            SELECT s.id, s.intro
            FROM {$CFG->prefix}sloodle s
            WHERE s.course = {$restore->course_id}
        ");
        
        if ($sloodles) {
            $i = 0;   //Counter to send some output to the browser to avoid timeouts
            foreach ($sloodles as $sloodle) {
                //Increment counter
                $i++;
                $content = $sloodle->intro;
                $result = restore_decode_content_links_worker($content,$restore);
                if ($result != $content) {
                    //Update record
                    $sloodle->intro = $result;
                    $status = sloodle_update_record("sloodle", $sloodle);
                    if (debugging()) {
                        if (!defined('RESTORE_SILENTLY')) {
                            echo '<br /><hr />'.s($content).'<br />changed to<br />'.s($result).'<hr /><br />';
                        }
                    }
                }
                //Do some output
                if (($i+1) % 5 == 0) {
                    if (!defined('RESTORE_SILENTLY')) {
                        echo ".";
                        if (($i+1) % 100 == 0) {
                            echo "<br />";
                        }
                    }
                    backup_flush(300);
                }
            }
        }

        return $status;
    }

    /**
    * This function returns a log record with all the necessay transformations done.
    * It's used by restore_log_module() to restore modules log.
    * This has not been modified for SLOODLE -- it comes from the chat module.
    * SLOODLE doesn't really use logs correctly all the time, so this may not work anyway.
    */
    function sloodle_restore_logs($restore,$log)
    {

        $status = false;

        //Depending of the action, we recode different things
        switch ($log->action) {
        case "add":
            if ($log->cmid) {
                //Get the new_id of the module (to recode the info field)
                $mod = backup_getid($restore->backup_unique_code,$log->module,$log->info);
                if ($mod) {
                    $log->url = "view.php?id=".$log->cmid;
                    $log->info = $mod->new_id;
                    $status = true;
                }
            }
            break;
        case "update":
            if ($log->cmid) {
                //Get the new_id of the module (to recode the info field)
                $mod = backup_getid($restore->backup_unique_code,$log->module,$log->info);
                if ($mod) {
                    $log->url = "view.php?id=".$log->cmid;
                    $log->info = $mod->new_id;
                    $status = true;
                }
            }
            break;
        case "talk":
            if ($log->cmid) {
                //Get the new_id of the module (to recode the info field)
                $mod = backup_getid($restore->backup_unique_code,$log->module,$log->info);
                if ($mod) {
                    $log->url = "view.php?id=".$log->cmid;
                    $log->info = $mod->new_id;
                    $status = true;
                }
            }
            break;
        case "view":
            if ($log->cmid) {
                //Get the new_id of the module (to recode the info field)
                $mod = backup_getid($restore->backup_unique_code,$log->module,$log->info);
                if ($mod) {
                    $log->url = "view.php?id=".$log->cmid;
                    $log->info = $mod->new_id;
                    $status = true;
                }
            }
            break;
        case "view all":
            $log->url = "index.php?id=".$log->course;
            $status = true;
            break;
        case "report":
            if ($log->cmid) {
                //Get the new_id of the module (to recode the info field)
                $mod = backup_getid($restore->backup_unique_code,$log->module,$log->info);
                if ($mod) {
                    $log->url = "report.php?id=".$log->cmid;
                    $log->info = $mod->new_id;
                    $status = true;
                }
            }
            break;
        default:
            if (!defined('RESTORE_SILENTLY')) {
                echo "action (".$log->module."-".$log->action.") unknown. Not restored<br />";                 //Debug
            }
            break;
        }

        if ($status) {
            $status = $log;
        }
        return $status;
    }
?>
