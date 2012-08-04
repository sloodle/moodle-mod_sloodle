<?php  // $Id: lib.php,v 1.4 2006/08/28 16:41:20 mark-nielsen Exp $
/**
* Freemail v1.1 with SL patch
*
* @package freemail
* @copyright Copyright (c) 2008 Serafim Panov
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @author Serafim Panov
* 
*
*/


function freemail_add_instance($freemail) {
   
    global $DB;
    $freemail->timemodified = time();

    # May have to add extra stuff in here #
   
    return $DB->insert_record("freemail", $freemail);
}


/**
 * Given an object containing all the necessary data, 
 * (defined by the form in mod.html) this function 
 * will update an existing instance with new data.
 *
 * @param object $instance An object from the form in mod.html
 * @return boolean Success/Fail
 **/
function freemail_update_instance($freemail) {

    global $DB;

    $freemail->timemodified = time();
    $freemail->id = $freemail->instance;

    # May have to add extra stuff in here #

    return $DB->update_record('freemail', $freemail);
}

/**
 * Given an ID of an instance of this module, 
 * this function will permanently delete the instance 
 * and any data that depends on it. 
 *
 * @param int $id Id of the module instance
 * @return boolean Success/Failure
 **/
function freemail_delete_instance($id) {

    global $DB;
    if (!$freemail = $DB->get_record('freemail', array("id"=>$id))) {
        return false;
    }

    $result = true;

    # Delete any dependent records here #

    if (! $DB->delete_records('freemail', array("id"=>"$freemail->id"))) {
        $result = false;
    }

    return $result;
}

/**
 * Return a small object with summary information about what a 
 * user has done with a given particular instance of this module
 * Used for user activity reports.
 * $return->time = the time they did it
 * $return->info = a short text description
 *
 * @return null
 * @todo Finish documenting this function
 **/
function freemail_user_outline($course, $user, $mod, $freemail) {
    return $return;
}

/**
 * Print a detailed representation of what a user has done with 
 * a given particular instance of this module, for user activity reports.
 *
 * @return boolean
 * @todo Finish documenting this function
 **/
function freemail_user_complete($course, $user, $mod, $freemail) {
    return true;
}

/**
 * Given a course and a time, this module should find recent activity 
 * that has occurred in freemail activities and print it out. 
 * Return true if there was output, or false is there was none. 
 *
 * @uses $CFG
 * @return boolean
 * @todo Finish documenting this function
 **/
function freemail_print_recent_activity($course, $isteacher, $timestart) {
    global $CFG;

    return false;  //  True if anything was printed, otherwise false 
}

/**
 * Function to be run periodically according to the moodle cron
 * This function searches for things that need to be done, such 
 * as sending out mail, toggling flags etc ... 
 *
 * @uses $CFG
 * @return boolean
 * @todo Finish documenting this function
 **/
function freemail_cron () {

    global $CFG;

    require_once 'freemail_imap_message_handler.php'; 
    require_once 'freemail_email_processor.php'; 
    require_once 'freemail_moodle_importer.php';

    freemail_email_processor::read_mail($CFG, false, false, null, false, true);

    return true;

}

/**
 * Must return an array of grades for a given instance of this module, 
 * indexed by user.  It also returns a maximum allowed grade.
 * 
 * Example:
 *    $return->grades = array of grades;
 *    $return->maxgrade = maximum allowed grade;
 *
 *    return $return;
 *
 * @param int $freemailid ID of an instance of this module
 * @return mixed Null or object with an array of grades and with the maximum grade
 **/
function freemail_grades($freemailid) {
   return NULL;
}

/**
 * Must return an array of user records (all data) who are participants
 * for a given instance of freemail. Must include every user involved
 * in the instance, independient of his role (student, teacher, admin...)
 * See other modules as example.
 *
 * @param int $freemailid ID of an instance of this module
 * @return mixed boolean/array of students
 **/
function freemail_get_participants($freemailid) {
    return false;
}

/**
 * This function returns if a scale is being used by one freemail
 * it it has support for grading and scales. Commented code should be
 * modified if necessary. See forum, glossary or journal modules
 * as reference.
 *
 * @param int $freemailid ID of an instance of this module
 * @return mixed
 * @todo Finish documenting this function
 **/
function freemail_scale_used ($freemailid,$scaleid) {
    $return = false;

    //$rec = get_record('freemail',"id","$freemailid","scale","-$scaleid");
    //
    //if (!empty($rec)  && !empty($scaleid)) {
    //    $return = true;
    //}
   
    return $return;
}

//////////////////////////////////////////////////////////////////////////////////////
/// Any other freemail functions go here.  Each of them must have a name that 
/// starts with freemail_

function freemail_get_types() {
    return array();
}
?>
