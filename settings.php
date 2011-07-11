<?php

require_once($CFG->dirroot.'/mod/sloodle/sl_config.php');


// // VERSION INFO // //

// Construct the version info
// Sloodle version
$str = print_heading(get_string('sloodleversion','sloodle').': '.(string)SLOODLE_VERSION, 'center', 4, 'main', true);
// Release number
$sloodlemodule = sloodle_get_record('modules', 'name', 'sloodle');
$releasenum = 0;
if ($sloodlemodule !== FALSE) $releasenum = $sloodlemodule->version;
$str .= print_heading(get_string('releasenum','sloodle').': '.(string)$releasenum, 'center', 5, 'main', true);

// Construct a help button to
$hlp = helpbutton('version_numbers', get_string('help:versionnumbers', 'sloodle'), 'sloodle', true, false, '', true);

// Add the version info section
$settings->add(new admin_setting_heading('sloodle_version_header', "Version Info ".$hlp, $str));



// // GENERAL SETTINGS // //

// General settings section
$settings->add(new admin_setting_heading('sloodle_settings_header', "Sloodle Settings", ''));

// Get some localization strings
$stryes = get_string('yes');
$strno = get_string('no');

    
// This selection box determines whether or not auto-registration is allowed on the site
$settings->add( new admin_setting_configselect(
                'sloodle_allow_autoreg',
                '',
                get_string('autoreg:allowforsite','sloodle').helpbutton('auto_registration', get_string('help:autoreg','sloodle'), 'sloodle', true, false, '', true),
                0,
                array(0 => $strno, 1 => $stryes)
));

    
// This selection box determines whether or not auto-enrolment is allowed on the site
$settings->add( new admin_setting_configselect(
                'sloodle_allow_autoenrol',
                '',
                get_string('autoenrol:allowforsite','sloodle').helpbutton('auto_enrolment', get_string('help:autoenrol','sloodle'), 'sloodle', true, false, '', true),
                0,
                array(0 => $strno, 1 => $stryes)
));

// This text box will let the user set a number of days after which active objects should expire
$settings->add( new admin_setting_configtext(
                'sloodle_active_object_lifetime',
                get_string('activeobjectlifetime', 'sloodle'),
                get_string('activeobjectlifetime:info', 'sloodle').helpbutton('object_authorization', get_string('activeobjects','sloodle'), 'sloodle', true, false, '', true),
                7));
                

// This text box will let the user set a number of days after which user objects should expire
$settings->add( new admin_setting_configtext(
                'sloodle_user_object_lifetime',
                get_string('userobjectlifetime', 'sloodle'),
                get_string('userobjectlifetime:info', 'sloodle').helpbutton('user_objects', get_string('userobjects','sloodle'), 'sloodle', true, false, '', true),
                21));
// This selection box determines whether or not auto-enrolment is allowed on the site

$settings->add( new admin_setting_configselect(
                'sloodle_gridtype',
                get_string('gridtype:specifygridtype','sloodle'),
                '',
                "OpenSim",
                array("OpenSim" => "OpenSim", "SecondLife"=> "SecondLife")
));  
?>