<?php
    // This file is part of the Sloodle project (www.sloodle.org)

    /**
    * This page lets an educator/admin create a configuration notecard.
    * It will be accessed by a link from a Controller page, and will
    *  display a form based on scripts in the Sloodle "mod" folder.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    /** Sloodle/Moodle configuration script. */
    require_once('../sl_config.php');
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    require_once(SLOODLE_LIBROOT.'/object_configs.php');

    // Fetch our required parameters
    $sloodlecontrollerid = required_param('sloodlecontrollerid', PARAM_INT);
    $sloodleobjtype = required_param('sloodleobjtype', PARAM_TEXT);
    
    // Fetch string table text
    $strsloodle = get_string('modulename', 'sloodle');
    $strsloodles = get_string('modulenameplural', 'sloodle');
    $pagename = get_string('objectconfig:header', 'sloodle');
    $strsavechanges = get_string('savechanges');
    $stryes = get_string('yes');
    $strno = get_string('no');
    
    
    // Attempt to fetch the course module instance
    if (! $cm = get_coursemodule_from_id('sloodle', $sloodlecontrollerid)) {
        error("Failed to load course module");
    }
    // Get the course data
    if (! $course = get_record("course", "id", $cm->course)) {
        error("Course is misconfigured");
    }
    // Get the Sloodle instance
    if (! $sloodle = get_record('sloodle', 'id', $cm->instance)) {
        error('Failed to find Sloodle module instance.');
    }
    
    // Get the Sloodle course data
    $sloodle_course = new SloodleCourse();
    if (!$sloodle_course->load($course)) error(get_string('failedcourseload','sloodle'));
    if (!$sloodle_course->controller->load($sloodlecontrollerid)) error('Failed to load Sloodle Controller.');
    
    // Ensure that the user is logged-in for this course
    require_course_login($course, true, $cm);
    // Is the user allowed to edit the module?
    $module_context = get_context_instance(CONTEXT_MODULE, $cm->id);
    $course_context = get_context_instance(CONTEXT_COURSE, $course->id);
    require_capability('moodle/course:manageactivities', $module_context);

    // Display the page header
    //$navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/index.php?id=$course->id\">$strsloodles</a> ->";
    $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?id=$sloodlecontrollerid\">".format_string($sloodle->name)."</a> ->";
    print_header_simple($pagename, "", "$navigation ". $pagename, "", "", true, '', navmenu($course, $cm));

    // We can display the Sloodle module info... log the view
    add_to_log($course->id, 'sloodle', 'view sloodle config', "classroom/notecard_configuration.php?sloodlecontrollerid=$sloodlecontrollerid&sloodleobjtype=$sloodleobjtype", $sloodleobjtype, $cm->id);
    
    
    // Make sure the object type is recognised
    $objectpath = SLOODLE_DIRROOT."/mod/$sloodleobjtype";
    if (!file_exists($objectpath)) error("ERROR: object \"$sloodleobjtype\" is not installed.");
    // Determine if we have a custom configuration page
    
    // Split up the object identifier into name and version number, then get the translated name
    list($objectname, $objectversion) = sloodle_parse_object_identifier($sloodleobjtype);
    $strobjectname = get_string("object:$objectname", 'sloodle');
    
//---------------------------------------------------------------------------------
    
    // Display intro information
    print_box_start('generalbox boxwidthwide boxaligncenter');
    echo '<div style="text-align:center;">';
    
    echo "<h1>$pagename</h1>";
    echo "<h2>$strobjectname $objectversion</h2>";
    
    // Display our configuration form
    echo '<form action="'.SLOODLE_WWWROOT.'/classroom/notecard_configuration_view.php" method="POST">';
    echo '<input type="hidden" name="formsubmitted" value="true">';
    
    
    // We need to create some dummy data for the form
    // (basically pretend we have an authorised object, and hope nobody tries to use the missing data anywhere!)
    // (not the best idea, I know, but the notecard stuff was added late... :-\)
    $sloodleauthid = 0;
    $auth_obj = new SloodleActiveObject();
    $auth_obj->course = $sloodle_course;
    $auth_obj->type = $sloodleobjtype;
    $hascustomconfig = $auth_obj->has_custom_config();
       
    // Are there any custom configuration options?
    if ($hascustomconfig) {

	// TODO: Do I really need all this?
        $dummysession = new SloodleSession(false);
        $dummysession->user->load_user($USER->id);
        $dummysession->user->load_linked_avatar();
        $auth_obj->user = $dummysession->user;
 
	include('object_configuration_form_template.php');
        // Include the form elements
        //require($customconfig);
        
    } else {
        // No configuration settings for this object
        print_string('noobjectconfig','sloodle');
        echo '<br><br>';
    }
    
    // Add our other necessary form elements
    echo '<input type="hidden" name="sloodlecontrollerid" value="'.$sloodlecontrollerid.'">';
    echo '<input type="hidden" name="sloodleobjtype" value="'.$sloodleobjtype.'">';
    echo '<input type="submit" value="'.get_string('cfgnotecard:generate','sloodle').'">';
    echo '</form>';
    
    echo '</div>';
    print_box_end();
    
//---------------------------------------------------------------------------------    
    
    print_footer();
?>
