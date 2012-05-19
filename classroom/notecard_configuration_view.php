<?php
    // This file is part of the Sloodle project (www.sloodle.org)

    /**
    * This page lets an educator/admin view a configuration notecard.
    * The data will first arrive as POST data, but will be converted
    *  over to SESSION data, and the page reloaded.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    /** Sloodle/Moodle configuration script. */
    require_once('../init.php');
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

    // Fetch our required parameters
    $sloodlecontrollerid = required_param('sloodlecontrollerid', PARAM_INT);
    $sloodleobjtype = required_param('sloodleobjtype', PARAM_TEXT);
    
    
    // Has HTTP form data been submitted?
    if (isset($_REQUEST['formsubmitted'])) {
        // Convert all the form data to session data
        foreach ($_REQUEST as $k => $v) {
            // Ignore anything that doesn't start with 'sloodle'
            if (strpos($k, 'sloodle') !== 0) {
                continue;
            }
            // Store it in session data
            $_SESSION[$k] = $v;
        }
        
        // Make sure we know about the form in session data
        $_SESSION['formsubmitted'] = true;
        
        // Reload this page
        redirect("{$CFG->wwwroot}/mod/sloodle/classroom/notecard_configuration_view.php?sloodlecontrollerid=$sloodlecontrollerid&sloodleobjtype=$sloodleobjtype");
        exit();
        
    } else if (!isset($_SESSION['formsubmitted'])) {
        // No, and there is no session form data either.
        // Re-direct back to the notecard page
        redirect("{$CFG->wwwroot}/mod/sloodle/classroom/notecard_configuration_form.php?sloodlecontrollerid=$sloodlecontrollerid&sloodleobjtype=$sloodleobjtype");
        exit();
    }
    
    // Clear the form submission
    unset($_SESSION['formsubmitted']);
    
    
    // Fetch string table text
    $strsloodle = get_string('modulename', 'sloodle');
    $strsloodles = get_string('modulenameplural', 'sloodle');
    $pagename = get_string('cfgnotecard:header', 'sloodle');
    $strsavechanges = get_string('savechanges');
    $stryes = get_string('yes');
    $strno = get_string('no');
    
    
    // Attempt to fetch the course module instance
    if (! $cm = get_coursemodule_from_id('sloodle', $sloodlecontrollerid)) {
        error("Failed to load course module");
    }
    // Get the course data
    if (! $course = sloodle_get_record("course", "id", $cm->course)) {
        error("Course is misconfigured");
    }
    // Get the Sloodle instance
    if (! $sloodle = sloodle_get_record('sloodle', 'id', $cm->instance)) {
        error('Failed to find Sloodle module instance.');
    }
    
    // Get the Sloodle course data
    $sloodle_course = new SloodleCourse();
    if (!$sloodle_course->load($course)) error(get_string('failedcourseload','sloodle'));
    if (!$sloodle_course->controller->load($sloodlecontrollerid)) error('Failed to load Controller data');
    
    // Ensure that the user is logged-in for this course
    require_course_login($course, true, $cm);
    // Is the user allowed to edit the module?
    $module_context = get_context_instance(CONTEXT_MODULE, $cm->id);
    $course_context = get_context_instance(CONTEXT_COURSE, $course->id);
    require_capability('moodle/course:manageactivities', $module_context);

    // Display the page header
    //$navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/index.php?id=$course->id\">$strsloodles</a> ->";
    $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?id=$sloodlecontrollerid\">".format_string($sloodle->name)."</a> ->";
    print_header_simple($pagename, "&nbsp;", "$navigation ". $pagename, "", "", true, '', navmenu($course, $cm));

    // We can display the Sloodle module info... log the view
    add_to_log($course->id, 'sloodle', 'view sloodle config', "classroom/notecard_configuration.php?sloodlecontrollerid=$sloodlecontrollerid&sloodleobjtype=$sloodleobjtype", $sloodleobjtype, $cm->id);
    
    // Make sure the object type is recognised
    $objectpath = SLOODLE_DIRROOT."/mod/$sloodleobjtype";
    if (!file_exists($objectpath)) error("ERROR: object \"$sloodleobjtype\" is not installed.");
    // Determine if we have a custom configuration page
    $customconfig = $objectpath.'/object_config.php';
    $hascustomconfig = file_exists($customconfig);
    
    // Split up the object identifier into name and version number, then get the translated name
    list($objectname, $objectversion) = SloodleObjectConfig::ParseModIdentifier($sloodleobjtype);

    $strobjectname = get_string("object:$objectname", 'sloodle');
    
    
//---------------------------------------------------------------------------------
    
    // Display intro information
    print_box_start('generalbox boxwidthwide boxaligncenter');
    echo '<div style="text-align:center;">';
    
    echo "<h1>$pagename</h1>";
    echo "<h2>$strobjectname $objectversion</h2>";
    print_string('cfgnotecard:instructions', 'sloodle');
    echo '<br><br>';
    print_string('cfgnotecard:security', 'sloodle');
    echo '<br><br><br>';
    
    
    // Fetch all our custom configuration settings into a separate array
    $customsettings = array();
    if (count($_SESSION) > 0) {
        foreach ($_SESSION as $k => $v) {
            // Ignore anything that doesn't start with 'sloodle'
            if (strpos($k, 'sloodle') !== 0) continue;
            // Ignore anything we will add in later
            if ($k != 'sloodleobjtype' && $k != 'sloodlecontrollerid') $customsettings[$k] = $v;
            // Remove the setting so it doesn't appear later
            unset($_SESSION[$k]);
        }
    }
    // Figure out how many lines we need
    $numlines = count($customsettings) + 6;
    
    
    // The configuration text
    echo '<textarea cols="60" rows="'.$numlines.'" readonly="true" onclick="">';
    
    // Add the standard stuff in
    echo "set:sloodleobjtype|$sloodleobjtype\n";
    echo "set:sloodleserverroot|{$CFG->wwwroot}\n";
    echo "set:sloodlecontrollerid|$sloodlecontrollerid\n";
    echo "set:sloodlepwd|".$sloodle_course->controller->get_password()."\n";
    echo "set:sloodlecoursename_short|".$sloodle_course->get_short_name()."\n";
    echo "set:sloodlecoursename_full|".$sloodle_course->get_full_name()."\n";
    
    // Go through each session parameter
    foreach ($customsettings as $k => $v) {
        // Output the value
        echo "set:$k|$v\n";
    }
    
    echo '</textarea><br><br>';
    
    echo "<a href=\"notecard_configuration_form.php?sloodlecontrollerid=$sloodlecontrollerid&sloodleobjtype=$sloodleobjtype\">&lt;&lt; ".get_string('objectconfig:backtoform','sloodle')."</a>";
    
    echo '</div>';
    print_box_end();
    
    
//---------------------------------------------------------------------------------
    
    
    
    print_footer();
?>
